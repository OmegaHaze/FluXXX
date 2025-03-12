# Updated Dockerfile
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip python3 python3-pip aria2 npm supervisor net-tools iproute2 jq && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Fix Node.js installation
RUN apt-get remove -y nodejs libnode-dev npm && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    node -v && npm -v

# Clone repositories
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    git clone --depth 1 https://github.com/open-webui/open-webui.git /workspace/open-webui

# Install ComfyUI Python dependencies using its official requirements.txt
WORKDIR /workspace/ComfyUI
RUN pip install -r requirements.txt

# Optionally, install additional packages not in requirements.txt (if needed)
# For example, if safetensors isn’t included or you need to force numpy<2:
RUN pip install safetensors "numpy<2"

# Fix OpenWebUI build
WORKDIR /workspace/open-webui
# Increase Node memory, install and build, then update package.json via jq
RUN export NODE_OPTIONS="--max-old-space-size=8192" && \
    npm install && npm run build && \
    jq '.scripts.start = "vite"' package.json > package_tmp.json && \
    mv package_tmp.json package.json && \
    rm -rf /root/.npm

# Install Ollama using the official install script and verify installation
RUN curl -fsSL https://ollama.com/install.sh | sh && \
    ollama --version

# Copy additional scripts and supervisor configuration
WORKDIR /workspace
COPY provisioning_fluxx.sh download_models.sh /workspace/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /workspace/*.sh

# Ensure logs directory exists
RUN mkdir -p /workspace/logs

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
