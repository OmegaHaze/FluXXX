#!/bin/bash

echo "🚀 Initializing provisioning script for FluXXX..."

# Lock file to prevent multiple executions
LOCK_FILE="/workspace/provisioning.lock"
if [ -f "$LOCK_FILE" ]; then
    echo "⚠️ Provisioning script already ran. Exiting..."
    exit 0
fi
touch "$LOCK_FILE"

# Ensure necessary directories exist
mkdir -p /workspace/logs

# Check if Supervisor is already running
if pgrep supervisord > /dev/null; then
    echo "⚠️ Supervisor is already running. Skipping restart..."
else
    echo "✅ Starting Supervisor..."
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
fi

# Remove lock file on exit (ensures clean state on restart)
trap 'rm -f $LOCK_FILE' EXIT

# Download entrypoint script ONLY if it's missing
if [[ ! -f /workspace/entrypoint.sh ]]; then
    echo "🔽 Downloading entrypoint script..."
    curl -fsSL -o /workspace/entrypoint.sh https://raw.githubusercontent.com/OmegaHaze/FluXXX/main/entrypoint.sh
fi

# Verify the file exists after download
if [[ ! -f /workspace/entrypoint.sh ]]; then
    echo "❌ ERROR: entrypoint.sh was not downloaded!"
    exit 1
fi

# Make it executable
chmod +x /workspace/entrypoint.sh

# Run the entrypoint script
echo "🚀 Running FluXXX entrypoint script..."
nohup /workspace/entrypoint.sh > /workspace/logs/entrypoint.log 2>&1 &

# Validate Supervisor
sleep 5
if ! pgrep supervisord > /dev/null; then
    echo "❌ ERROR: Supervisor failed to start!"
    exit 1
fi

echo "✅ Supervisor running!"
tail -f /workspace/logs/*.log
