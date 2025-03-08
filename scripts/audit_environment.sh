#!/bin/bash
# audit_environment.sh
# This script performs an audit of system hardware, software, and network configurations.
# Output is written to environment_setup.txt

OUTPUT_FILE="environment_setup.txt"
echo "==== Environment Setup Audit ====" > "$OUTPUT_FILE"
echo "Timestamp: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 1. Host & OS Information
echo "=== Host & OS Information ===" >> "$OUTPUT_FILE"
echo "Hostname: $(hostname)" >> "$OUTPUT_FILE"
echo "OS Information:" >> "$OUTPUT_FILE"
uname -a >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. CPU & Memory Details
echo "=== CPU Information ===" >> "$OUTPUT_FILE"
lscpu >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "=== Memory Information ===" >> "$OUTPUT_FILE"
free -h >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 3. Disk and Storage Information
echo "=== Disk Information ===" >> "$OUTPUT_FILE"
lsblk >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 4. BIOS/Firmware Information
echo "=== BIOS/Firmware Information ===" >> "$OUTPUT_FILE"
sudo dmidecode -t bios >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

# 5. Container Host Details
echo "=== Docker Information ===" >> "$OUTPUT_FILE"
echo "Docker Version:" >> "$OUTPUT_FILE"
docker version >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

echo "Docker Info:" >> "$OUTPUT_FILE"
docker info >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

echo "Docker Compose Version:" >> "$OUTPUT_FILE"
docker-compose version >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

# 6. Network Information
echo "=== Network Interfaces ===" >> "$OUTPUT_FILE"
ip addr >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 7. Recent System Logs (Last 50 lines)
echo "=== Recent System Logs (Last 50 lines) ===" >> "$OUTPUT_FILE"
dmesg | tail -n 50 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Final Message
echo "Audit completed. See '$OUTPUT_FILE' for details."
