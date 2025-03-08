#!/bin/bash
# audit_file_structure.sh
# This script captures a summary of the project file structure for the /home/richard/projects/elroy directory.
# It lists all directories and provides a file count for each.

PROJECT_DIR="/home/richard/projects/elroy"
OUTPUT_FILE="project_file_structure_summary.txt"

echo "Project File Structure Summary" > "$OUTPUT_FILE"
echo "Base Directory: $PROJECT_DIR" >> "$OUTPUT_FILE"
echo "----------------------------------------" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# List all directories with a file count summary
find "$PROJECT_DIR" -type d | while read -r dir; do
    file_count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    echo "$dir: $file_count files" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "Total directories: $(find "$PROJECT_DIR" -type d | wc -l)" >> "$OUTPUT_FILE"
echo "Total files: $(find "$PROJECT_DIR" -type f | wc -l)" >> "$OUTPUT_FILE"

echo "Summary complete. See '$OUTPUT_FILE' for details."
