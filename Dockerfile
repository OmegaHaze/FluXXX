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

# Install essential utilities + Python 3.11
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip netcat-traditional aria2 jq supervisor net-tools iproute2 \
    python3.11 python3.11-venv python3.11-dev python3-pip npm ffmpeg && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --set python /usr/bin/python3.11 && \
    update-alternatives --set python3 /usr/bin/python3.11 && \
    rm -rf /var/lib/apt/lists/* /tmp/*


# Ensure pip is up to date
RUN python --version && pip install --upgrade pip setuptools wheel

# ========================
# 🔹 COMFYUI (Using Official Image)
# ========================
FROM ghcr.io/lecode-official/comfyui-docker:latest AS comfyui

# ========================
# 🔹 OLLAMA (Using Official Image)
# ========================
FROM ollama/ollama:latest AS ollama

# ========================
# 🔹 OPENWEBUI (Using Official Image)
# ========================
FROM ghcr.io/open-webui/open-webui:git-d84e7d1-cuda AS openwebui

# ========================
# 🔥 FINAL IMAGE (Combining All Services)
# ========================
FROM base AS final

# Copy services
COPY --from=comfyui /opt/comfyui /workspace/ComfyUI
COPY --from=ollama /usr/bin/ollama /usr/bin/ollama
COPY --from=openwebui /app /workspace/open-webui

# Copy scripts
COPY provisioning_fluxx.sh download_models.sh install_dependencies.sh /workspace/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /workspace/entrypoint.sh

# Ensure permissions
RUN chmod +x /workspace/*.sh /workspace/entrypoint.sh

# Install dependencies
RUN /workspace/install_dependencies.sh

# ✅ Install missing dependencies
RUN pip install --no-cache-dir -r /workspace/open-webui/backend/requirements.txt \
                 -r /workspace/ComfyUI/requirements.txt \
                 pyyaml

# Ensure logs directory exists
RUN mkdir -p /workspace/logs

# Set the entrypoint
ENTRYPOINT ["/workspace/entrypoint.sh"]

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
