# Use CUDA base image
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# 1. Install all dependencies in a single step
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip python3 python3-pip sudo aria2 npm supervisor && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# 2. Fix Node.js Installation Issues
RUN apt-get remove -y nodejs libnode-dev npm && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# 3. Clone repositories (shallow clone for speed)
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    git clone --depth 1 https://github.com/open-webui/open-webui.git /workspace/open-webui

# 4. Install PyTorch with CUDA compatibility
RUN pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --extra-index-url https://download.pytorch.org/whl/cu121

# 5. Fix JavaScript Heap Out of Memory (Increase Node.js Memory)
WORKDIR /workspace/open-webui
RUN npm install && \
    NODE_OPTIONS="--max-old-space-size=4096" npm run build && \
    rm -rf /root/.npm

# 6. Install Ollama (Fix missing Ollama)
RUN curl -fsSL https://ollama.com/install.sh | sh

# 7. Copy provisioning + entrypoint scripts and set permissions
WORKDIR /workspace
COPY provisioning_fluxx.sh download_models.sh supervisord.conf /workspace/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /workspace/*.sh

# 8. Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
