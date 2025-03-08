#!/bin/bash
# reorganize_elroy.sh
# This script reorganizes the Elroy project directory to align with our agreed file structure.
# It creates the following directories (if not already present):
#   - src, config, containers, docker, logs, docs, and database.
# It then moves existing items into these folders where appropriate.

BASE_DIR=~/projects/elroy

echo "Reorganizing project structure under $BASE_DIR ..."

# Create missing directories
mkdir -p "$BASE_DIR/src"
mkdir -p "$BASE_DIR/config"
mkdir -p "$BASE_DIR/containers"
mkdir -p "$BASE_DIR/docker"
mkdir -p "$BASE_DIR/logs"
mkdir -p "$BASE_DIR/docs"
mkdir -p "$BASE_DIR/database"

# If a directory named "db" exists, move its contents to "database" and remove it.
if [ -d "$BASE_DIR/db" ]; then
    echo "Moving contents from 'db' to 'database'..."
    mv "$BASE_DIR/db/"* "$BASE_DIR/database/"
    rmdir "$BASE_DIR/db"
fi

# Move any tracking CSV files into the "database" folder.
if [ -f "$BASE_DIR/ka1_import.csv" ]; then
    echo "Moving ka1_import.csv into the 'database' folder..."
    mv "$BASE_DIR/ka1_import.csv" "$BASE_DIR/database/"
fi

# Move the setup log into the "logs" folder.
if [ -f "$BASE_DIR/setup_output.log" ]; then
    echo "Moving setup_output.log into the 'logs' folder..."
    mv "$BASE_DIR/setup_output.log" "$BASE_DIR/logs/"
fi

# Move system assessment files/folder into the "docs" folder.
if [ -d "$BASE_DIR/system_assessment" ]; then
    echo "Moving system_assessment folder into the 'docs' folder..."
    mv "$BASE_DIR/system_assessment" "$BASE_DIR/docs/"
fi

echo "Reorganization complete."

# Optional: display the updated directory structure (requires 'tree' command)
if command -v tree >/dev/null 2>&1; then
    tree "$BASE_DIR"
else
    echo "Use 'tree ~/projects/elroy' to view the directory structure."
fi

echo "Your project now follows the agreed file structure."
