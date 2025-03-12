#!/bin/bash

COMFYUI_DIR="/workspace/ComfyUI"

# Install main ComfyUI dependencies (prevents missing packages)
echo "Installing ComfyUI dependencies..."
pip install --no-cache-dir -r "${COMFYUI_DIR}/requirements.txt"

# ComfyUI custom nodes to install
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
)

# Workflow examples
WORKFLOWS=(
    "https://gist.githubusercontent.com/robballantyne/f8cb692bdcd89c96c0bd1ec0c969d905/raw/flux_dev_example.json"
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

# Download example workflows
echo "Downloading FLUX workflows..."
mkdir -p "${COMFYUI_DIR}/user/default/workflows"
for url in "${WORKFLOWS[@]}"; do
    file_name="$(basename "$url")"
    echo "Downloading workflow: ${file_name}"
    wget -q -O "${COMFYUI_DIR}/user/default/workflows/${file_name}" "$url"
done

echo "ComfyUI plugins and workflows installation complete."
