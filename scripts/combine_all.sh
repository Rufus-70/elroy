#!/bin/bash
# combine_txt_files.sh
# This script concatenates all .txt files in the current directory into one file named all_texts_combined.txt.

OUTPUT_FILE="all_texts_combined.txt"

# Empty the output file if it exists
> "$OUTPUT_FILE"

# Loop through each .txt file and append its contents with a header indicating the filename.
for file in *.txt; do
    if [ -f "$file" ]; then
        echo "----- $file -----" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "Combined all .txt files into $OUTPUT_FILE."
	
