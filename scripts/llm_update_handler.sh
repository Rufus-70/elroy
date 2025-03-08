#!/bin/bash

# Define database path
db_file="$HOME/projects/elroy/db/agendic_agent.db"

echo "🔄 Awaiting batch update file from external LLM..."

# Read user input for table selection
echo "Which table do you want to update? (KA1, KO1, OB1)"
read table

# Prompt for CSV file path
echo "Enter the path to the CSV file containing updates:"
read csv_file

# Validate file exists
if [ ! -f "$csv_file" ]; then
    echo "❌ Error: File not found!"
    exit 1
fi

echo "🔄 Processing updates from $csv_file..."

# Read CSV line by line and apply updates
while IFS=',' read -r id column new_value
do
    update_query="UPDATE $table SET $column = '$new_value' WHERE id = $id;"
    echo "Executing: $update_query"
    sqlite3 "$db_file" "$update_query"
done < "$csv_file"

echo "✅ All updates applied successfully."

# Display updated rows for verification
echo "🔍 Verifying updates..."
sqlite3 "$db_file" "SELECT * FROM $table WHERE id IN (SELECT id FROM $table ORDER BY id DESC LIMIT 10);"

echo "🔄 Database update complete!"
