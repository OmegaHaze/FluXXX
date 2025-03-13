#!/bin/bash

echo "🚀 Initializing provisioning script for FluXXX..."

# Ensure necessary directories exist
mkdir -p /workspace/logs

# Kill existing Supervisor process (if any)
if pgrep supervisord > /dev/null; then
    echo "⚠️ Stopping existing Supervisor instance..."
    pkill supervisord
    sleep 2
fi

# Download the actual entrypoint script
echo "🔽 Downloading entrypoint script..."
curl -fsSL -o /workspace/entrypoint.sh https://raw.githubusercontent.com/OmegaHaze/FluXXX/main/entrypoint.sh

# Verify the file exists after download
if [[ ! -f /workspace/entrypoint.sh ]]; then
    echo "❌ ERROR: entrypoint.sh was not downloaded!"
    exit 1
fi

# Make it executable
chmod +x /workspace/entrypoint.sh

# Run the entrypoint script
echo "🚀 Running FluXXX entrypoint script..."
/workspace/entrypoint.sh &

echo "🚀 Starting FluXXX environment..."

# Trap SIGTERM for clean shutdown
trap 'echo "Stopping FluXXX..."; supervisorctl shutdown; exit 0' SIGTERM

# Start Supervisor
echo "✅ Starting Supervisor..."
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Wait for Supervisor to fully initialize
sleep 5  

# Ensure Supervisor socket is ready
count=0
while [ ! -S /var/run/supervisor.sock ]; do
    if [[ $count -ge 15 ]]; then
        echo "❌ ERROR: Supervisor socket never appeared!"
        exit 1
    fi
    echo "⏳ Waiting for Supervisor socket..."
    sleep 1
    ((count++))
done

echo "✅ Supervisor socket detected."

# Validate services
echo "🔍 Checking service status..."
if ! supervisorctl status | grep -q "RUNNING"; then
    echo "❌ ERROR: One or more services failed to start!"
    supervisorctl status
    exit 1
fi

echo "✅ All services running successfully!"
tail -f /workspace/logs/*.log
