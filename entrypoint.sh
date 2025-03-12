#!/bin/bash

echo "Starting FluXXX environment..."
mkdir -p /workspace/logs

# Trap SIGTERM for clean shutdown
trap 'echo "Stopping FluXXX..."; supervisorctl shutdown; exit 0' SIGTERM

# Start Supervisor
echo "Starting supervisor..."
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Wait for Supervisor to start
sleep 10  # Increased from 5 to 10 seconds

# Check if Supervisor is running
if [ ! -S /var/run/supervisor.sock ]; then
    echo "❌ ERROR: Supervisor socket missing! Checking logs..."
    cat /workspace/logs/supervisord.log
    exit 1
fi

# Check if all services are running
echo "Checking service status..."
if ! supervisorctl status | grep -q "RUNNING"; then
    echo "❌ ERROR: One or more services failed to start!"
    supervisorctl status
    exit 1
fi

echo "✅ All services running successfully!"
tail -f /workspace/logs/*.log
