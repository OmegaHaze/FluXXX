#!/bin/bash
set -e  # 🚨 Exit immediately if any command fails

echo "🛠 Installing dependencies..."

# Install system packages
apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip aria2 jq supervisor net-tools iproute2 \
    python3-pip npm ffmpeg && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Verify Python installation
python3 --version || { echo "❌ Python is not installed correctly!"; exit 1; }

# Install Python requirements
pip install --no-cache-dir -r /workspace/ComfyUI/requirements.txt \
                           -r /workspace/open-webui/backend/requirements.txt \
                           pyyaml

echo "✅ Dependencies installed successfully!"
