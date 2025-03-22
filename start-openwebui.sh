#!/bin/bash
set -e
echo "🧠 [OpenWebUI] Start script triggered by Supervisor"
echo "🔁 [OpenWebUI] Boot sequence initiated...bossmode shit happening..."

# Load env vars from .env (if any)
if [[ -f /workspace/.env ]]; then
    echo "📦 [OpenWebUI] Loading environment variables from boss ass .env..."
    export $(grep -v '^#' /workspace/.env | xargs)
fi

# Wait for Ollama (port 11434)
echo "⏳ [OpenWebUI] Waiting for Ollama on port 11434..."
while ! nc -z localhost 11434; do
    echo "❌ Ollama not up yet...hopefully it's not bitching out"
    sleep 1
done
echo "✅ [OpenWebUI] Ollama is ready.Fuck yeah."

# Check if OpenWebUI is already running
echo "🔍 [OpenWebUI] Checking if port 7500 is free...this port is frequesntly a bitch"
if lsof -i :7500 &>/dev/null; then
    echo "🚫 [OpenWebUI] Port 7500 already in use — not starting another instance.Gay..."
    exit 0
fi

# Launch OpenWebUI
echo "🚀 [OpenWebUI] Launching backend...BOSS MODE ENABLED"
export PORT=7500
bash /workspace/open-webui/backend/start.sh

echo "✅ [OpenWebUI] Started successfully. You are officially a Boss."
