FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=7500 \
    WEBUI_HOST=0.0.0.0 \
    OLLAMA_CUDA=1 \
    OLLAMA_API_BASE_URL=http://localhost:11434 \
    OPENWEBUI_BACKEND_URL=http://localhost:7501 \
    COMFYUI_API_BASE_URL=http://localhost:8188 \
    CUDA_VISIBLE_DEVICES=0

WORKDIR /workspace

# Install essential utilities and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip netcat-traditional aria2 jq supervisor net-tools iproute2 ca-certificates \
    python3.11 python3.11-venv python3.11-dev python3-pip npm ffmpeg && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# ========================
# 🔹 COMFYUI
# ========================
FROM ghcr.io/lecode-official/comfyui-docker:latest AS comfyui

# ========================
# 🔹 OPENWEBUI
# ========================
FROM ghcr.io/open-webui/open-webui:git-d84e7d1-cuda AS openwebui

# ========================
# 🔥 FINAL IMAGE
# ========================
FROM base AS final

# Copy ComfyUI and OpenWebUI from official images
COPY --from=comfyui /opt/comfyui /workspace/ComfyUI
COPY --from=openwebui /app /workspace/open-webui

# 🔥 Install Ollama via the official installation script (CUDA-enabled)
RUN curl -fsSL https://ollama.com/install.sh | sh && \
    ln -sf /usr/local/bin/ollama /usr/bin/ollama

# Copy scripts
COPY provisioning_fluxx.sh download_models.sh install_dependencies.sh /workspace/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /workspace/entrypoint.sh

# Permissions
RUN chmod +x /workspace/*.sh /workspace/entrypoint.sh

# Install additional dependencies
RUN /workspace/install_dependencies.sh

# Python requirements for OpenWebUI and ComfyUI
RUN pip install --no-cache-dir -r /workspace/open-webui/backend/requirements.txt \
                               -r /workspace/ComfyUI/requirements.txt \
                               pyyaml

# Logs directory
RUN mkdir -p /workspace/logs

# Set entrypoint
ENTRYPOINT ["/workspace/entrypoint.sh"]

# Supervisor as CMD
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
