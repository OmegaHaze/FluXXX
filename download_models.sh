#!/bin/bash

MODEL_DIR="/workspace/models"
mkdir -p "$MODEL_DIR"

MODELS=(
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors"
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
)

for url in "${MODELS[@]}"; do
    file_name="$(basename "$url")"
    file_path="${MODEL_DIR}/${file_name}"

    if [[ ! -f "${file_path}" ]]; then
        echo "Downloading: ${file_name}"
        aria2c --max-tries=5 --retry-wait=10 -x 16 -s 16 -d "${MODEL_DIR}" "${url}"
    else
        echo "File already exists: ${file_name}, skipping..."
    fi
done

echo "✅ Model downloads complete."
