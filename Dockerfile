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

# Copy additional scripts before execution
COPY provisioning_fluxx.sh download_models.sh /workspace/
RUN chmod +x /workspace/provisioning_fluxx.sh

# Install ComfyUI dependencies inside provisioning script
WORKDIR /workspace
RUN /workspace/provisioning_fluxx.sh

# Fix OpenWebUI build
WORKDIR /workspace/open-webui

# 🔹 Remove this (no need to force `vite` mode, let Supervisor handle it)
# RUN jq '.scripts.start = "vite"' package.json > package_tmp.json && \
#     mv package_tmp.json package.json

# 🔹 Increase Node memory, install dependencies, and build frontend
RUN export NODE_OPTIONS="--max-old-space-size=8192" && \
    npm install && npm run build

# 🔹 Ensure OpenWebUI respects `--port 7500 --host 0.0.0.0`
RUN echo "PORT=7500" > /workspace/open-webui/.env && \
    echo "HOST=0.0.0.0" >> /workspace/open-webui/.env

# 🔹 Install OpenWebUI backend dependencies
WORKDIR /workspace/open-webui/backend
RUN pip install -r requirements.txt

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

# Copy entrypoint script and set permissions
COPY entrypoint.sh /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh

# 🔹 Set default environment variables
ENV PORT=7500 \
    HOST=0.0.0.0 \
    PYTHONUNBUFFERED=1

# Set the entrypoint and default command
ENTRYPOINT ["/workspace/entrypoint.sh"]

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
