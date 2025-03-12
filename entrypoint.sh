#!/bin/bash

echo "Starting FluXXX environment..."
mkdir -p /workspace/logs

# Trap SIGTERM for clean shutdown
trap 'echo "Stopping FluXXX..."; supervisorctl shutdown; exit 0' SIGTERM

# Forward CMD arguments as the main process (this will launch Supervisor)
exec "$@"
