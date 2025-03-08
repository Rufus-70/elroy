#!/bin/bash

# Dynamically get absolute path to the database
DB_FILE="$HOME/projects/elroy/db/agendic_agent.db"
EXPORT_DIR="$HOME/projects/elroy/exports"
mkdir -p "$EXPORT_DIR"

# Export Database Schema
echo "🔹 Fetching Database Schema..."
sqlite3 "$DB_FILE" ".schema" > "$EXPORT_DIR/database_schema.sql"
echo "✅ Database schema exported to $EXPORT_DIR/database_schema.sql"

# Export KA-1 Data
echo "🔹 Exporting KA-1 (KATA Cycle Tracking) Data..."
sqlite3 -header -csv "$DB_FILE" "SELECT * FROM KA1;" > "$EXPORT_DIR/KA1_export.csv"
echo "✅ KA-1 data exported to $EXPORT_DIR/KA1_export.csv"

# Export KO-1 Data
echo "🔹 Exporting KO-1 (Knowns & Assumptions) Data..."
sqlite3 -header -csv "$DB_FILE" "SELECT * FROM KO1;" > "$EXPORT_DIR/KO1_export.csv"
echo "✅ KO-1 data exported to $EXPORT_DIR/KO1_export.csv"

# Export OB-1 Data
echo "🔹 Exporting OB-1 (Observations & Anomalies) Data..."
sqlite3 -header -csv "$DB_FILE" "SELECT * FROM OB1;" > "$EXPORT_DIR/OB1_export.csv"
echo "✅ OB-1 data exported to $EXPORT_DIR/OB1_export.csv"

# Export System Status Data
echo "🔹 Exporting System Status Data..."
sqlite3 -header -csv "$DB_FILE" "SELECT * FROM system_info;" > "$EXPORT_DIR/system_status_export.csv"
echo "✅ System status data exported to $EXPORT_DIR/system_status_export.csv"

# Log System Data Updates
echo "🔹 Updating System Database with Export Log..."
sqlite3 "$DB_FILE" "INSERT INTO system_updates (timestamp, action, details) VALUES (CURRENT_TIMESTAMP, 'EXPORT', 'Exported KA-1, KO-1, OB-1, System Status, and Database Schema.');"
echo "✅ System database updated with export log."

# Instructions for the external LLM
echo -e "\n=========================="
echo -e "📌 INSTRUCTIONS FOR EXTERNAL LLM SESSION 📌"
echo -e "=========================="
echo -e "\nYou are starting a new session analyzing the structured KATA methodology."
echo -e "- KA-1 contains iterative improvements and learnings."
echo -e "- KO-1 tracks verified knowledge and assumptions under evaluation."
echo -e "- OB-1 logs observations and anomalies that may need investigation."
echo -e "- System Status provides the latest system performance and health insights."
echo -e "- Database Schema details the structure of all tables for reference."

echo -e "\nUse these documents to:"
echo -e "✅ Provide insights based on trends and historical learnings."
echo -e "✅ Update assumptions and knowledge as new data emerges."
echo -e "✅ Suggest next actions based on known issues and past iterations."
echo -e "✅ Correlate system performance with observations to identify potential issues."
echo -e "✅ Reference table structures when needed."

echo -e "\nThis data should be treated as structured reference material to enhance AI-driven troubleshooting."
