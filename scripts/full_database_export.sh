#!/bin/bash

# Set database path
DB_FILE="$HOME/projects/elroy/db/agendic_agent.db"

# Function to display table data
function display_table() {
    local table_name=$1
    echo "\n🔹 Displaying data from table: $table_name"
    sqlite3 -column -header "$DB_FILE" "SELECT * FROM $table_name LIMIT 10;"
    echo "------------------------------------------------------"
}

# Fetch all table names
TABLES=$(sqlite3 "$DB_FILE" ".tables")

# Loop through each table and display its contents
for TABLE in $TABLES; do
    display_table "$TABLE"
done
