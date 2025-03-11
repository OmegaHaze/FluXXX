#!/bin/bash

COMFYUI_DIR="/workspace/ComfyUI"

# Dependencies
APT_PACKAGES=( "git" "wget" "curl" "unzip" "python3" "python3-pip" )
PIP_PACKAGES=( "torch" "torchvision" "torchaudio" "numpy" )

# ComfyUI Nodes
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
)

WORKFLOWS=( "https://gist.githubusercontent.com/robballantyne/f8cb692bdcd89c96c0bd1ec0c969d905/raw/2d969f732d7873f0e1ee23b2625b50f201c722a5/flux_dev_example.json" )

### **Provisioning Functions** ###

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_pip_packages
    provisioning_get_nodes
    provisioning_get_files "${COMFYUI_DIR}/user/default/workflows" "${WORKFLOWS[@]}"
    # REMOVE MODEL DOWNLOAD PROMPT
    provisioning_print_end
}

function provisioning_get_apt_packages() {
    sudo apt update && sudo apt install -y "${APT_PACKAGES[@]}"
}

function provisioning_get_pip_packages() {
    pip install --no-cache-dir "${PIP_PACKAGES[@]}"
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="${COMFYUI_DIR}/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            echo "Updating node: ${repo}..."
            (cd "$path" && git pull)
            [[ -e $requirements ]] && pip install --no-cache-dir -r "$requirements"
        else
            echo "Cloning node: ${repo}..."
            git clone "${repo}" "${path}" --recursive
            [[ -e $requirements ]] && pip install --no-cache-dir -r "$requirements"
        fi
    done
}

function provisioning_get_files() {
    [[ -z $2 ]] && return 1
    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    for url in "${arr[@]}"; do
        wget --content-disposition --show-progress -e dotbytes="4M" -P "$dir" "$url"
    done
}

function provisioning_print_header() {
    echo -e "\n##############################"
    echo -e "#        FLUXXX SETUP        #"
    echo -e "#  Installing Dependencies   #"
    echo -e "##############################\n"
}

function provisioning_print_end() {
    echo -e "\nFLUXXX provisioning complete!"
    echo -e "ComfyUI will start now.\n"
}

### **Start Provisioning** ###
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
