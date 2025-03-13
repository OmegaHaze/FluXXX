#!/bin/bash
set -e  # 🚨 Exit immediately if any command fails

echo "🚀 Running New FluXXX Provisioning Script..."

# Step 1: Run old provisioning script
if [[ -f "/workspace/provisioning_fluxx.sh" ]]; then
    echo "🔄 Running old provisioning_fluxx.sh..."
    bash /workspace/provisioning_fluxx.sh
else
    echo "❌ ERROR: provisioning_fluxx.sh not found!"
    exit 1
fi

# Step 2: Install dependencies
echo "🛠 Installing system & Python dependencies..."
bash /workspace/install_dependencies.sh

# Step 3: Start the entrypoint script to launch services
echo "🚀 Starting FluXXX services..."
exec bash /workspace/entrypoint.sh

