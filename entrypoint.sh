#!/bin/bash

echo "Starting FluXXX environment..."
mkdir -p /workspace/logs  # ✅ Ensure logs directory exists

# Trap SIGTERM for clean shutdown
trap 'echo "Stopping FluXXX..."; supervisorctl shutdown; exit 0' SIGTERM

# Start Supervisor
echo "Starting supervisor..."
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

# Wait for all services to be ready
sleep 2

echo "Checking service status..."
if ! supervisorctl status | grep -q "RUNNING"; then
    echo "Error: One or more services failed to start!"
    exit 1
fi

echo "All services running successfully!"
tail -f /workspace/logs/*.log
