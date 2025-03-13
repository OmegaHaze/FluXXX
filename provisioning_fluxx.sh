#!/bin/bash

COMFYUI_DIR="/workspace/ComfyUI"

# Install main ComfyUI dependencies (prevents missing packages)
echo "Installing ComfyUI dependencies..."
pip install --no-cache-dir -r "${COMFYUI_DIR}/requirements.txt"

# ComfyUI custom nodes to install
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
)

# Install or update custom nodes for ComfyUI
echo "Installing ComfyUI custom nodes..."
for repo in "${NODES[@]}"; do
    dir="${repo##*/}"
    path="${COMFYUI_DIR}/custom_nodes/${dir}"
    requirements="${path}/requirements.txt"
    if [[ -d $path ]]; then
        echo "Updating node: ${repo}"
        (cd "$path" && git pull)
    else
        echo "Downloading node: ${repo}"
        git clone "${repo}" "${path}" --recursive
    fi
    # Install node-specific requirements if they exist
    if [[ -e $requirements ]]; then
        echo "Installing requirements for: ${dir}"
        pip install --no-cache-dir -r "$requirements"
    fi
done

echo "ComfyUI plugins installation complete."
