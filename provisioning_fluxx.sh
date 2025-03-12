#!/bin/bash

COMFYUI_DIR="/workspace/ComfyUI"

APT_PACKAGES=(git wget curl unzip python3 python3-pip aria2)
PIP_PACKAGES=(torch==2.2.0 torchvision==0.17.0 safetensors)
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
)
WORKFLOWS=(
    "https://gist.githubusercontent.com/robballantyne/f8cb692bdcd89c96c0bd1ec0c969d905/raw/flux_dev_example.json"
)

# Install system dependencies
echo "Installing system dependencies..."
apt-get update && apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}" && apt-get clean

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --no-cache-dir "${PIP_PACKAGES[@]}"

# Install or update custom nodes
echo "Installing custom nodes..."
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
    
    [[ -e $requirements ]] && pip install --no-cache-dir -r "$requirements"
done

# Download workflows
echo "Downloading workflows..."
mkdir -p "${COMFYUI_DIR}/user/default/workflows"
for url in "${WORKFLOWS[@]}"; do
    file_name="$(basename "$url")"
    wget -q -O "${COMFYUI_DIR}/user/default/workflows/${file_name}" "$url"
done

echo "Provisioning complete."
