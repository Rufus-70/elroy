#!/bin/bash
# full_system_info.sh
# This script collects a full system test and report, including:
# - Installed Python packages in the venv
# - All Docker containers and images
# - The location and version (if available) for critical binaries (ollama and r1)
# - A process snapshot for critical services (ollama and r1)
# - Basic system resource information (uptime, disk usage, etc.)
#
# The report is saved in the logs folder as full_system_info_report.txt

BASE_DIR=~/projects/elroy
LOG_DIR="$BASE_DIR/logs"
REPORT_FILE="$LOG_DIR/full_system_info_report.txt"

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Start report
{
    echo "========== Full System Information Report =========="
    echo "Date: $(date)"
    echo "---------------------------------------------------"

    echo "### Python Virtual Environment Libraries"
    if [ -d "$BASE_DIR/venv" ] && [ -f "$BASE_DIR/venv/bin/activate" ]; then
        source "$BASE_DIR/venv/bin/activate"
        echo "Python version: $(python --version 2>&1)"
        echo "Installed packages (pip freeze):"
        pip freeze
        deactivate
    else
        echo "Virtual environment not found at $BASE_DIR/venv"
    fi
    echo "---------------------------------------------------"

    echo "### Docker Containers and Images"
    echo "All Docker Containers (running and stopped):"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    echo ""
    echo "Docker Images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
    echo "---------------------------------------------------"

    echo "### Critical Binaries Information"
    for bin in ollama r1; do
        echo "Checking for binary: $bin"
        BIN_PATH=$(which $bin 2>/dev/null)
        if [ -n "$BIN_PATH" ]; then
            echo "Location: $BIN_PATH"
            # Attempt to get version information (customize this per binary if needed)
            $bin --version 2>&1 || echo "Version info not available"
        else
            echo "Binary '$bin' not found in PATH."
        fi
        echo "---------------------------------------------------"
    done

    echo "### Process Snapshot for Critical Services"
    echo "Processes matching 'ollama' and 'r1':"
    ps aux | grep -E "(ollama|r1)" | grep -v grep
    echo "---------------------------------------------------"

    echo "### Data Directory Contents"
    if [ "$(ls -A $BASE_DIR/data)" ]; then
        echo "Data directory ($BASE_DIR/data) contents:"
        ls -l "$BASE_DIR/data"
    else
        echo "Data directory ($BASE_DIR/data) is empty."
    fi
    echo "---------------------------------------------------"

    echo "### System Resource Information"
    echo "Uptime:"
    uptime
    echo ""
    echo "Disk usage:"
    df -h
    echo "---------------------------------------------------"

} > "$REPORT_FILE" 2>&1

echo "Full system information report saved to $REPORT_FILE"
