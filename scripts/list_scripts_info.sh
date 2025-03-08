#!/bin/bash
# list_scripts_info.sh
# This script generates a summary file (scripts_info.txt) with details (e.g., file size, permissions) for all .txt, .py, and .sh files.

OUTPUT_FILE="scripts_info.txt"

echo "Scripts File Information:" > "$OUTPUT_FILE"
echo "Directory: $(pwd)" >> "$OUTPUT_FILE"
echo "----------------------------------------" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Loop through each .txt, .py, and .sh file and output detailed info using stat.
for file in *.txt *.py *.sh; do
    if [ -f "$file" ]; then
        echo "File: $file" >> "$OUTPUT_FILE"
        stat "$file" >> "$OUTPUT_FILE"
        echo "----------------------" >> "$OUTPUT_FILE"
    fi
done

echo "Generated file $OUTPUT_FILE with detailed information about the scripts."
