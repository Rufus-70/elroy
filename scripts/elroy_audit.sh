#!/bin/bash
# Elroy Audit Script: Reviews Docker configurations, optimizes settings,
# verifies storage drivers, and sets up a sample orchestration using Docker Compose V2.
# All output is redirected to "elroy_audit.txt".

OUTPUT_FILE="elroy_audit.txt"
COMPOSE_FILE="docker-compose.sample.yml"

# Clear the output file or create it if it doesn't exist.
echo "Elroy Audit Script - Container Runtime and Orchestration Check" > "$OUTPUT_FILE"
echo "Date: $(date)" >> "$OUTPUT_FILE"
echo "-------------------------------------" >> "$OUTPUT_FILE"

# --- 3.1 Reviewing Existing Docker Configurations ---
echo "Step 3.1: Reviewing Existing Docker Configurations" >> "$OUTPUT_FILE"
echo "1. Docker Version:" >> "$OUTPUT_FILE"
docker version >> "$OUTPUT_FILE" 2>&1

echo "-------------------------------------" >> "$OUTPUT_FILE"
echo "2. Docker Info:" >> "$OUTPUT_FILE"
docker info >> "$OUTPUT_FILE" 2>&1

echo "-------------------------------------" >> "$OUTPUT_FILE"
echo "3. Docker Daemon Configuration (/etc/docker/daemon.json):" >> "$OUTPUT_FILE"
if [ -f /etc/docker/daemon.json ]; then
    cat /etc/docker/daemon.json >> "$OUTPUT_FILE" 2>&1
else
    echo "File /etc/docker/daemon.json not found." >> "$OUTPUT_FILE"
fi

echo "-------------------------------------" >> "$OUTPUT_FILE"
echo "4. Docker Logs (last 60 minutes):" >> "$OUTPUT_FILE"
sudo journalctl -u docker --since "60 minutes ago" >> "$OUTPUT_FILE" 2>&1

# --- 3.2 Optimizing Docker Engine Settings ---
echo "-------------------------------------" >> "$OUTPUT_FILE"
echo "Step 3.2: Optimizing Docker Engine Settings" >> "$OUTPUT_FILE"
echo "Backing up current /etc/docker/daemon.json to /etc/docker/daemon.json.bak" >> "$OUTPUT_FILE"
if [ -f /etc/docker/daemon.json ]; then
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
    echo "Backup complete." >> "$OUTPUT_FILE"
else
    echo "/etc/docker/daemon.json does not exist, skipping backup." >> "$OUTPUT_FILE"
fi

echo "Restarting Docker service..." >> "$OUTPUT_FILE"
sudo systemctl restart docker >> "$OUTPUT_FILE" 2>&1
echo "Docker service status:" >> "$OUTPUT_FILE"
sudo systemctl status docker --no-pager >> "$OUTPUT_FILE" 2>&1

# --- 3.3 Verifying Container Storage Drivers ---
echo "-------------------------------------" >> "$OUTPUT_FILE"
echo "Step 3.3: Verifying Container Storage Drivers" >> "$OUTPUT_FILE"
echo "Current Storage Driver:" >> "$OUTPUT_FILE"
docker info | grep "Storage Driver" >> "$OUTPUT_FILE" 2>&1

echo "Docker system disk usage:" >> "$OUTPUT_FILE"
docker system df >> "$OUTPUT_FILE" 2>&1

# --- 3.4 Setting Up Orchestration Tools (Docker Compose V2 Example) ---
echo "-------------------------------------" >> "$OUTPUT_FILE"
echo "Step 3.4: Setting Up Orchestration Tools (Docker Compose Example)" >> "$OUTPUT_FILE"
echo "Creating a sample docker-compose.yml file..." >> "$OUTPUT_FILE"

cat <<EOF > "$COMPOSE_FILE"
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    networks:
      - webnet

  app:
    image: hello-world
    depends_on:
      - web
    networks:
      - webnet

networks:
  webnet:
    driver: bridge
EOF

echo "Sample docker-compose.yml created at $COMPOSE_FILE" >> "$OUTPUT_FILE"
echo "Starting Docker Compose services..." >> "$OUTPUT_FILE"
docker compose -f "$COMPOSE_FILE" up -d >> "$OUTPUT_FILE" 2>&1
echo "Docker Compose service status:" >> "$OUTPUT_FILE"
docker compose -f "$COMPOSE_FILE" ps >> "$OUTPUT_FILE" 2>&1

echo "Elroy Audit Script Completed." >> "$OUTPUT_FILE"
