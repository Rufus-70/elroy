import sqlite3
import os

DB_PATH = os.path.expanduser("~/projects/elroy/database/erp.db")

def get_table_list(cursor):
    """Retrieve all table names from the database."""
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    return [row[0] for row in cursor.fetchall()]

def get_table_schema(cursor, table_name):
    """Retrieve column details for a given table."""
    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()
    schema = f"\n🔹 Table: {table_name}\n"
    schema += "-" * 40 + "\n"
    schema += "{:<20} {:<10} {:<10}\n".format("Column Name", "Type", "PK?")
    schema += "-" * 40 + "\n"
    
    for col in columns:
        schema += "{:<20} {:<10} {:<10}\n".format(col[1], col[2], "Yes" if col[5] else "No")
    
    return schema

def get_foreign_keys(cursor, table_name):
    """Retrieve foreign key relationships for a given table."""
    cursor.execute(f"PRAGMA foreign_key_list({table_name});")
    fks = cursor.fetchall()
    if not fks:
        return f"\n🔸 {table_name}: No foreign keys.\n"
    
    relationships = f"\n🔸 Foreign Keys in {table_name}\n"
    relationships += "-" * 40 + "\n"
    relationships += "{:<15} → {:<15} ({})\n".format("Column", "References Table", "References Column")
    relationships += "-" * 40 + "\n"
    
    for fk in fks:
        relationships += "{:<15} → {:<15} ({})\n".format(fk[3], fk[2], fk[4])
    
    return relationships

def generate_schema_report():
    """Generate and save a full database schema report."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    tables = get_table_list(cursor)
    
    report = "\n📌 **ERP Database Schema Report**\n" + "="*50
    
    for table in tables:
        report += get_table_schema(cursor, table)
        report += get_foreign_keys(cursor, table)
        report += "\n"
    
    conn.close()

    # Save report to file
    report_path = os.path.expanduser("~/projects/elroy/docs/erp_schema_report.txt")
    with open(report_path, "w") as f:
        f.write(report)

    print(f"✅ Schema report saved to: {report_path}")

if __name__ == "__main__":
    generate_schema_report()
