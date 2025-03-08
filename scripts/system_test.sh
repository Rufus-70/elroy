#!/bin/bash
# system_test.sh
# This script performs a full system test on the Elroy project.
# It checks for critical services (R1 and Ollama), validates the virtual environment,
# and gathers system information into a report.

# Define base directories
BASE_DIR=~/projects/elroy
LOG_DIR="$BASE_DIR/logs"
REPORT_FILE="$LOG_DIR/system_test_report.txt"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Start report
echo "========== Elroy Full System Test Report ==========" > "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "---------------------------------------------------" >> "$REPORT_FILE"

# Function to check a process is running by name
check_process() {
    local proc_name="$1"
    echo "Checking for process: $proc_name ..." | tee -a "$REPORT_FILE"
    if pgrep -f "$proc_name" > /dev/null; then
        echo "✅ Process '$proc_name' is running." | tee -a "$REPORT_FILE"
    else
        echo "❌ Process '$proc_name' is NOT running." | tee -a "$REPORT_FILE"
    fi
    echo "---------------------------------------------------" >> "$REPORT_FILE"
}

# Check R1 service
check_process "r1"

# Check Ollama service
check_process "ollama"

# Check Python Virtual Environment (venv)
echo "Checking for Python virtual environment..." | tee -a "$REPORT_FILE"
if [ -d "$BASE_DIR/venv" ] && [ -f "$BASE_DIR/venv/bin/activate" ]; then
    echo "✅ Virtual environment exists at $BASE_DIR/venv" | tee -a "$REPORT_FILE"
    # Activate venv and check Python version
    source "$BASE_DIR/venv/bin/activate"
    PY_VER=$(python --version 2>&1)
    echo "Python version in venv: $PY_VER" | tee -a "$REPORT_FILE"
    deactivate
else
    echo "❌ Virtual environment not found at $BASE_DIR/venv" | tee -a "$REPORT_FILE"
fi
echo "---------------------------------------------------" >> "$REPORT_FILE"

# Check Docker containers (if using Docker)
echo "Checking for running Docker containers..." | tee -a "$REPORT_FILE"
docker ps --format "table {{.Names}}\t{{.Status}}" >> "$REPORT_FILE"
echo "---------------------------------------------------" >> "$REPORT_FILE"

# Optionally run a quick data test (e.g., check that data directory is not empty)
echo "Verifying data directory contents..." | tee -a "$REPORT_FILE"
if [ "$(ls -A $BASE_DIR/data)" ]; then
    echo "✅ Data directory ($BASE_DIR/data) is not empty." | tee -a "$REPORT_FILE"
else
    echo "❌ Data directory ($BASE_DIR/data) is empty." | tee -a "$REPORT_FILE"
fi
echo "---------------------------------------------------" >> "$REPORT_FILE"

# Optionally run a sample script from src/ (if available)
SAMPLE_SCRIPT="$BASE_DIR/src/sample_test.py"
if [ -f "$SAMPLE_SCRIPT" ]; then
    echo "Running sample test script: $SAMPLE_SCRIPT ..." | tee -a "$REPORT_FILE"
    source "$BASE_DIR/venv/bin/activate"
    python "$SAMPLE_SCRIPT" >> "$REPORT_FILE" 2>&1
    EXIT_CODE=$?
    deactivate
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ Sample script ran successfully." | tee -a "$REPORT_FILE"
    else
        echo "❌ Sample script encountered errors (exit code: $EXIT_CODE)." | tee -a "$REPORT_FILE"
    fi
else
    echo "No sample test script found in $BASE_DIR/src/." | tee -a "$REPORT_FILE"
fi
echo "---------------------------------------------------" >> "$REPORT_FILE"

# Add system resource info (uptime, disk usage)
echo "Collecting system resource information..." | tee -a "$REPORT_FILE"
echo "Uptime:" | tee -a "$REPORT_FILE"
uptime >> "$REPORT_FILE"
echo "Disk usage:" | tee -a "$REPORT_FILE"
df -h >> "$REPORT_FILE"
echo "---------------------------------------------------" >> "$REPORT_FILE"

echo "System test completed. Report saved to $REPORT_FILE"
