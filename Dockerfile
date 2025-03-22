# ==========================
# 🔹 BASE IMAGE SETUP
# ==========================
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=7500 \
    WEBUI_HOST=0.0.0.0 \
    OLLAMA_CUDA=1 \
    OLLAMA_API_BASE_URL=http://localhost:11434 \
    OPENWEBUI_BACKEND_URL=http://localhost:7501 \
    COMFYUI_API_BASE_URL=http://localhost:8188 \
    QDRANT_API_BASE_URL=http://localhost:6333 \
    QDRANT_WEB_UI_BASE_URL=http://localhost:6335 \
    N8N_API_BASE_URL=http://localhost:5678 \
    CUDA_VISIBLE_DEVICES=0 \
    N8N_USER_FOLDER=/workspace/.n8n \
    N8N_RUNNERS_ENABLED=true \
    QDRANT_DASHBOARD_PORT=6335


WORKDIR /workspace

# Install system dependencies and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip netcat-traditional aria2 jq supervisor net-tools iproute2 ca-certificates \
    python3.11 python3.11-venv python3.11-dev python3-pip npm ffmpeg libunwind-dev gnupg lsb-release && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    rm -rf /var/lib/apt/lists/* /tmp/*

RUN pip install --upgrade pip setuptools wheel

# ==========================
# 🔹 MULTI-STAGE BUILDS
# ==========================
FROM ghcr.io/lecode-official/comfyui-docker:latest AS comfyui
FROM ghcr.io/open-webui/open-webui:git-d84e7d1-cuda AS openwebui
FROM qdrant/qdrant:latest AS qdrant

# ==========================
# 🔥 FINAL IMAGE BUILD
# ==========================
FROM base AS final

# Install Node.js 20 and n8n
RUN apt-get remove -y nodejs libnode-dev && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    mkdir -p /workspace/n8n && cd /workspace/n8n && \
    npm install n8n && npm rebuild sqlite3 && \
    ln -s /workspace/n8n/node_modules/n8n/bin/n8n /usr/local/bin/n8n && \
    chmod +x /workspace/n8n/node_modules/n8n/bin/n8n

# Build Qdrant Dashboard (served via port 6334)
RUN git clone https://github.com/qdrant/qdrant-web-ui.git /workspace/qdrant-web-ui && \
    cd /workspace/qdrant-web-ui && \
    npm install && npm run build && \
    npm install -g serve

# Copy application directories
COPY --from=comfyui /opt/comfyui /workspace/ComfyUI
COPY --from=openwebui /app /workspace/open-webui
COPY --from=qdrant /qdrant/qdrant /workspace/qdrant/qdrant

# ✅ Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Create directories and set permissions
RUN chmod -R 755 /workspace/qdrant && \
    mkdir -p /workspace/.n8n /workspace/logs && \
    chown -R root:root /workspace/.n8n

# Copy scripts and supervisor config
COPY provisioning_fluxx.sh \
     download_models.sh \
     install_dependencies.sh \
     start-openwebiu.sh \
     start-n8n.sh \
     /workspace/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /workspace/entrypoint.sh

RUN chmod +x /workspace/*.sh /workspace/entrypoint.sh

# Install additional Python requirements
RUN /workspace/install_dependencies.sh && \
    pip install --no-cache-dir -r /workspace/open-webui/backend/requirements.txt \
                               -r /workspace/ComfyUI/requirements.txt \
                               pyyaml

# Start all services
ENTRYPOINT ["/workspace/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
