#!/bin/bash

# Set database and export directory paths
DB_FILE="$HOME/projects/elroy/db/agendic_agent.db"
EXPORT_DIR="$HOME/projects/elroy/exports"
mkdir -p "$EXPORT_DIR"

# Tables to export
TABLES=("erp" "ka1" "ko1" "ob1" "qms" "sme")

# Export each table in lowercase filenames
for TABLE in "${TABLES[@]}"; do
    echo "🔹 Exporting $TABLE Data..."
    sqlite3 -header -csv "$DB_FILE" "SELECT * FROM $TABLE;" > "$EXPORT_DIR/${TABLE}_export.csv"
    echo "✅ $TABLE data exported to $EXPORT_DIR/${TABLE}_export.csv"
done

# Export Database Schema
echo "🔹 Fetching Database Schema..."
sqlite3 "$DB_FILE" ".schema" > "$EXPORT_DIR/database_schema.sql"
echo "✅ Database schema exported to $EXPORT_DIR/database_schema.sql"

# Log System Data Updates
echo "🔹 Updating System Database with Export Log..."
sqlite3 "$DB_FILE" "INSERT INTO system_updates (timestamp, action, details) VALUES (CURRENT_TIMESTAMP, 'EXPORT', 'Exported all tables (erp, ka1, ko1, ob1, qms, sme) and database schema.');"
echo "✅ System database updated with export log."
