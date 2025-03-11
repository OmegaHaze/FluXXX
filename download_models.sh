#!/bin/bash

########################################
# Manual Model Download Script
########################################

# Define model download locations
MODEL_DIR="/workspace/ComfyUI/models"
CLIP_DIR="${MODEL_DIR}/clip"
UNET_DIR="${MODEL_DIR}/unet"
VAE_DIR="${MODEL_DIR}/vae"

# Create directories if they don't exist
mkdir -p "${CLIP_DIR}" "${UNET_DIR}" "${VAE_DIR}"

# List of model URLs
CLIP_MODELS=(
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
)

UNET_MODELS=(
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
)

# Function to download models
function download_models() {
    local dir="$1"
    shift
    local urls=("$@")
    echo "Downloading models to: ${dir}"
    for url in "${urls[@]}"; do
        wget --content-disposition --show-progress -e dotbytes="4M" -P "${dir}" "${url}"
    done
}

# Start downloads
download_models "${CLIP_DIR}" "${CLIP_MODELS[@]}"
download_models "${UNET_DIR}" "${UNET_MODELS[@]}"
download_models "${VAE_DIR}" "${VAE_MODELS[@]}"

echo "All models downloaded successfully!"
