# Use a CUDA base image (adjust if you need a different CUDA version)
FROM nvidia/cuda:12.1.105-cudnn8-runtime-ubuntu22.04 as base

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl unzip python3 python3-pip sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone ComfyUI and OpenWebUI at build time
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN git clone https://github.com/open-webui/open-webui.git /workspace/open-webui

# 3. Install Ollama (example pinned version: v0.0.8)
RUN wget -qO /tmp/ollama.tar.gz https://github.com/jmorganca/ollama/releases/download/v0.0.8/ollama_linux_x86_64.tar.gz && \
    tar -xzf /tmp/ollama.tar.gz -C /usr/local/bin && \
    rm /tmp/ollama.tar.gz

# 4. Copy provisioning + entrypoint scripts and make them executable
COPY provisioning_fluxx.sh /workspace/provisioning_fluxx.sh
COPY entrypoint.sh /workspace/entrypoint.sh
COPY download_models.sh /workspace/download_models.sh
RUN chmod +x /workspace/*.sh

# 5. Default command: runs entrypoint.sh
CMD ["/workspace/entrypoint.sh"]
