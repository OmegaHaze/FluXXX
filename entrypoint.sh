#!/bin/bash
set -e

########################################
# 1. Run provisioning (NO automatic model download)
########################################
bash /workspace/provisioning_fluxx.sh

########################################
# 2. Start Ollama FIRST (background), so OpenWebUI can see it
########################################
ollama serve --port 11434 &

########################################
# 3. Start ComfyUI (background)
########################################
python3 /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 8188 &

########################################
# 4. Finally, run OpenWebUI in FOREGROUND
########################################
cd /workspace/open-webui
./webui.sh --listen 0.0.0.0 --port 7500

########################################
# 5. User must manually run model download script now:
# bash /workspace/download_models.sh
########################################
