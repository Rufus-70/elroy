import sqlite3
import os

# Path to your ERP database file
DB_PATH = os.path.expanduser("~/projects/elroy/database/erp.db")

# Define your SQL queries using the ERP schema columns.
queries = {
    "MTD_Shipments": {
         "query": """
            SELECT 
                strftime('%Y-%m', ShipDate) AS Month, 
                COUNT(*) AS TotalShipments
            FROM shipments
            WHERE ShipDate >= date('now', 'start of month')
            GROUP BY Month;
         """,
         "expected_rows": 1  # Typically one row for the current month
    },
    "Daily_Shipments": {
         "query": """
            SELECT 
                s.ShipDate, 
                r.RefCat, 
                s.PartNum
            FROM shipments s
            JOIN ref_cat r ON s.PartNum = r.PartNum
            WHERE s.ShipDate >= date('now', '-30 days')
            ORDER BY s.ShipDate DESC;
         """,
         "expected_rows": None  # Review output manually
    }
    # Add further queries as needed, ensuring you use only the defined columns.
}

def run_query(cursor, query):
    """Executes a SQL query and returns all results."""
    cursor.execute(query)
    return cursor.fetchall()

def validate_query(cursor, name, query, expected_rows):
    """Runs a query, prints a summary of results, and checks expected rows if provided."""
    print(f"Validating query: {name}")
    results = run_query(cursor, query)
    row_count = len(results)
    print(f"Rows returned: {row_count}")
    
    if expected_rows is not None:
        if row_count != expected_rows:
            print(f"❌ Mismatch: Expected {expected_rows} rows, but got {row_count}")
        else:
            print("✅ Row count matches expected.")
    else:
        print("No expected row count provided. Please review the output manually.")
    
    print("Sample output (first 3 rows):")
    for row in results[:3]:
        print(row)
    print("-" * 40)
    return results

def main():
    # Connect to the ERP database
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    validated_queries = {}
    
    # Loop over each query definition, validate, and store those that return data.
    for name, data in queries.items():
        results = validate_query(cursor, name, data["query"], data.get("expected_rows"))
        if len(results) > 0:
            validated_queries[name] = data["query"]
    
    # Save the validated query templates to a file for later use by the AI integration.
    templates_path = os.path.expanduser("~/projects/elroy/docs/validated_query_templates.txt")
    with open(templates_path, "w") as f:
        for name, query in validated_queries.items():
            f.write(f"--- {name} ---\n")
            f.write(query.strip() + "\n\n")
    
    print(f"✅ Validated query templates have been saved to: {templates_path}")
    
    conn.close()

if __name__ == "__main__":
    main()
