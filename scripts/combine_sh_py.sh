#!/bin/bash
# combine_py_sh_files.sh
# This script concatenates all .py and .sh files in the current directory into one file named all_scripts_combined.txt.

OUTPUT_FILE="all_scripts_combined.txt"

# Empty the output file if it exists
> "$OUTPUT_FILE"

# Loop through each .py and .sh file and append its contents with a header.
for file in *.py *.sh; do
    if [ -f "$file" ]; then
        echo "----- $file -----" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "Combined all .py and .sh files into $OUTPUT_FILE."
