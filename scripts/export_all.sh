#!/bin/bash

# Path to the ERP database
DB=~/projects/elroy/database/erp.db

# Output file name
OUTFILE=all_export.txt

# Remove any existing export file
rm -f "$OUTFILE"

# Export 100 rows from each table into the single text file.
echo "===== date_table =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM date_table LIMIT 100;" >> "$OUTFILE"

echo "===== employees =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM employees LIMIT 100;" >> "$OUTFILE"

echo "===== db19_old =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM db19_old LIMIT 100;" >> "$OUTFILE"

echo "===== ref_cat =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM ref_cat LIMIT 100;" >> "$OUTFILE"

echo "===== job_header =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM job_header LIMIT 100;" >> "$OUTFILE"

echo "===== search_input =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM search_input LIMIT 100;" >> "$OUTFILE"

echo "===== job_operations =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM job_operations LIMIT 100;" >> "$OUTFILE"

echo "===== labor_details =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM labor_details LIMIT 100;" >> "$OUTFILE"

echo "===== ncmr =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM ncmr LIMIT 100;" >> "$OUTFILE"

echo "===== db19 =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM db19 LIMIT 100;" >> "$OUTFILE"

echo "===== shipments =====" >> "$OUTFILE"
sqlite3 "$DB" -header -csv "SELECT * FROM shipments LIMIT 100;" >> "$OUTFILE"

# Delete any CSV files in the current directory (if previously created)
rm -f *.csv

echo "Export completed into $OUTFILE"
