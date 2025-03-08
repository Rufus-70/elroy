#!/usr/bin/env python3
"""
Quick test script for ERP database validation
This script focuses only on database validation without model dependencies
"""

import sqlite3
import pandas as pd
from datetime import datetime
import sys
import os
import glob

# Try several possible database paths
POSSIBLE_PATHS = [
    '/projects/elroy/database/erp.db',
    '~/projects/elroy/database/erp.db',
    os.path.expanduser('~/projects/elroy/database/erp.db'),
    './erp.db',
    '../database/erp.db'
]

# Look for SQLite database files in the project directory
def find_db_files():
    """Find potential SQLite database files"""
    project_dir = os.path.expanduser('~/projects/elroy')
    found_files = []
    
    for root, dirs, files in os.walk(project_dir):
        for file in files:
            if file.endswith('.db') or file.endswith('.sqlite') or file.endswith('.sqlite3'):
                found_files.append(os.path.join(root, file))
    
    return found_files

# Try to determine the correct database path
def get_database_path():
    """Try to determine the correct database path"""
    # First try the predefined paths
    for path in POSSIBLE_PATHS:
        expanded_path = os.path.expanduser(path)
        if os.path.exists(expanded_path):
            print(f"Found database at: {expanded_path}")
            return expanded_path
    
    # If not found, search for database files
    found_files = find_db_files()
    if found_files:
        print(f"Found {len(found_files)} potential database files:")
        for i, file in enumerate(found_files):
            print(f"{i+1}. {file} ({os.path.getsize(file) / (1024*1024):.2f} MB)")
        
        if len(found_files) == 1:
            print(f"Automatically selecting the only database found.")
            return found_files[0]
        else:
            try:
                choice = input("Enter the number of the database to use: ")
                idx = int(choice) - 1
                if 0 <= idx < len(found_files):
                    return found_files[idx]
            except (ValueError, IndexError):
                pass
    
    # Ask user for path
    user_path = input("Please enter the full path to your database file: ")
    if os.path.exists(user_path):
        return user_path
    
    print("Could not determine database path. Defaulting to /projects/elroy/database/erp.db")
    return '/projects/elroy/database/erp.db'

# Get database path
DATABASE_PATH = get_database_path()

def test_database_connection():
    """Test if we can connect to the database"""
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        print(f"✅ Successfully connected to: {DATABASE_PATH}")
        
        # Check if file exists and get size
        if os.path.exists(DATABASE_PATH):
            size_mb = os.path.getsize(DATABASE_PATH) / (1024 * 1024)
            print(f"  Database size: {size_mb:.2f} MB")
        
        conn.close()
        return True
    except sqlite3.Error as e:
        print(f"❌ Database connection error: {e}")
        return False

def list_database_tables():
    """List all tables in the database"""
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        
        if not tables:
            print("❌ No tables found in database!")
            return False
        
        print("\n📋 Database Tables:")
        print("-" * 50)
        for i, table_name in enumerate(tables):
            cursor.execute(f"SELECT COUNT(*) FROM {table_name[0]};")
            row_count = cursor.fetchone()[0]
            print(f"{i+1}. {table_name[0]} - {row_count:,} rows")
        
        conn.close()
        return True
    except sqlite3.Error as e:
        print(f"❌ Error listing tables: {e}")
        return False

def run_simple_query(query, description):
    """Run a simple query and show results"""
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        print(f"\n🔍 Testing: {description}")
        print("-" * 50)
        print(f"Query: {query}")
        
        df = pd.read_sql_query(query, conn)
        
        if df.empty:
            print("⚠️ Query returned no results!")
        else:
            print(f"\n✅ Query returned {len(df)} rows")
            print("\nSample Results:")
            print(df.head(5))
            
        conn.close()
        return df
    except sqlite3.Error as e:
        print(f"❌ Query error: {e}")
        return pd.DataFrame()

def quick_test():
    """Run a quick test of the database"""
    if not test_database_connection():
        return False
    
    if not list_database_tables():
        return False
    
    # Test some simple queries to verify database content
    
    # 1. Test date_table
    run_simple_query(
        "SELECT * FROM date_table LIMIT 5;",
        "Basic date_table query"
    )
    
    # 2. Test shipments
    run_simple_query(
        "SELECT * FROM shipments LIMIT 5;",
        "Basic shipments query"
    )
    
    # 3. Check columns in shipments
    run_simple_query(
        "PRAGMA table_info(shipments);",
        "Shipments table structure"
    )
    
    # 4. Test if ShipTotal exists
    ship_total_test = run_simple_query(
        "SELECT * FROM shipments WHERE ShipTotal IS NOT NULL LIMIT 5;",
        "Testing ShipTotal column"
    )
    
    # Adapt queries based on results
    if ship_total_test.empty:
        print("\n⚠️ ShipTotal column not found or contains no data")
        # Check column names in shipments
        print("\nAvailable columns in shipments:")
        columns = run_simple_query("PRAGMA table_info(shipments);", "")
        print(columns['name'].tolist())
    
    return True

if __name__ == "__main__":
    print("🚀 ERP Database Quick Test")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 50)
    
    quick_test()
    
    print("\n✅ Quick test completed!")
