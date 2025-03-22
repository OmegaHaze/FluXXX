#!/bin/bash
echo "🔁 [n8n] Boot sequence initiated..."

# Load environment variables from .env if it exists
if [ -f /workspace/.env ]; then
    echo "📦 [n8n] Loading environment variables from .env..."
    export $(grep -v '^#' /workspace/.env | xargs)
fi

# Check for existing config
CONFIG_PATH="/workspace/.n8n/.n8n/config"
if [ -f "$CONFIG_PATH" ]; then
    echo "🔐 [n8n] Config file exists. Ensure encryption keys match to avoid crash loops!"
    chmod 600 "$CONFIG_PATH"
fi

# Check if port is available
PORT=${N8N_PORT:-5678}
echo "🔍 [n8n] Checking if port $PORT is available..."
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "🚫 [n8n] Port $PORT already in use — aborting startup."
    exit 0
fi

echo "🚀 [n8n] Starting n8n on port $PORT..."
n8n start
