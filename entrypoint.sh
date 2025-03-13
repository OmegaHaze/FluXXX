#!/bin/bash

echo "🚀 Starting FluXXX environment..."
mkdir -p /workspace/logs

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
