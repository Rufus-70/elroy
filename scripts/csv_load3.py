import sqlite3
import pandas as pd
import os

db_path = os.path.expanduser("~/projects/elroy/database/erp.db")
csv_folder = os.path.expanduser("~/projects/elroy/database/csv/")

# Connect to SQLite database
conn = sqlite3.connect(db_path)

# Mapping of CSV filenames to table names
table_mapping = {
    "DB19.csv": "db19",
    "Shipments.csv": "shipments"
}

# Load each CSV into its respective table
for file in os.listdir(csv_folder):
    if file in table_mapping:
        table_name = table_mapping[file]
        csv_path = os.path.join(csv_folder, file)

        df = pd.read_csv(csv_path)
        df.to_sql(table_name, conn, if_exists="replace", index=False)

        print(f"✅ Loaded {file} into {table_name}")

conn.close()
print("✅ All tables reloaded successfully.")
