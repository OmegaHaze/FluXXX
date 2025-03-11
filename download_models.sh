#!/bin/bash

MODEL_DIR="/workspace/models"
mkdir -p "$MODEL_DIR"

# Model URLs and expected SHA256 hashes (optional for integrity verification)
MODELS=(
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors"
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
)

function download_models() {
    local dir="$1"
    shift
    local urls=("$@")

    mkdir -p "${dir}"
    
    for url in "${urls[@]}"; do
        file_name="$(basename "$url")"
        file_path="${dir}/${file_name}"

        if [[ -f "${file_path}" ]]; then
            echo "Verifying file integrity for: ${file_name}"
            if ! sha256sum -c "${file_path}.sha256" --status 2>/dev/null; then
                echo "Corrupt file detected, re-downloading: ${file_name}"
                rm -f "${file_path}"
                aria2c --max-tries=5 --retry-wait=10 -x 16 -s 16 -d "${dir}" "${url}"
            else
                echo "File verified: ${file_name}"
            fi
        else
            echo "Downloading: ${file_name}"
            aria2c --max-tries=5 --retry-wait=10 -x 16 -s 16 -d "${dir}" "${url}"
        fi
    done
}

download_models "${MODEL_DIR}" "${MODELS[@]}"
echo "Model downloads complete."
