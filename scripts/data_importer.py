#!/usr/bin/env python3
"""
ERP Data Import Script
This script imports data from CSV files into the ERP database tables
"""

import sqlite3
import pandas as pd
import os
import glob
import sys
from datetime import datetime

# Database path
DATABASE_PATH = '/home/richard/projects/elroy/database/erp.db'

def connect_db():
    """Connect to the database"""
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        print(f"✅ Connected to: {DATABASE_PATH}")
        return conn
    except sqlite3.Error as e:
        print(f"❌ Connection error: {e}")
        return None

def find_csv_files(directory=None):
    """Find CSV files in the specified directory or current directory"""
    if directory is None:
        # Default to current directory
        directory = os.getcwd()
    
    # Find all CSV files
    csv_files = glob.glob(os.path.join(directory, "*.csv"))
    
    if not csv_files:
        print(f"❌ No CSV files found in {directory}")
        return []
    
    print(f"✅ Found {len(csv_files)} CSV files in {directory}")
    for file in csv_files:
        size_kb = os.path.getsize(file) / 1024
        print(f"  - {os.path.basename(file)} ({size_kb:.1f} KB)")
    
    return csv_files

def preview_csv(file_path):
    """Preview a CSV file to understand its structure"""
    try:
        # Try to read with various parameters to handle different formats
        df = pd.read_csv(file_path)
        print(f"\n📋 Preview of {os.path.basename(file_path)}:")
        print(f"  - Rows: {len(df)}")
        print(f"  - Columns: {', '.join(df.columns.tolist())}")
        print("\nSample data (first 3 rows):")
        print(df.head(3))
        return df
    except Exception as e:
        print(f"❌ Error reading CSV file: {e}")
        
        # Try different encoding or delimiter
        try:
            print("Trying alternative parameters...")
            df = pd.read_csv(file_path, encoding='latin1', sep=';')
            print("✅ Successfully read with alternative parameters")
            print(f"  - Rows: {len(df)}")
            print(f"  - Columns: {', '.join(df.columns.tolist())}")
            return df
        except Exception as e2:
            print(f"❌ Still unable to read CSV: {e2}")
            return None

def get_table_schema(conn, table_name):
    """Get the schema of a table"""
    try:
        cursor = conn.cursor()
        cursor.execute(f"PRAGMA table_info({table_name});")
        columns = cursor.fetchall()
        return [col[1] for col in columns]  # Column name is at index 1
    except sqlite3.Error as e:
        print(f"❌ Error getting schema for {table_name}: {e}")
        return []

def confirm_import(file_name, table_name, df, table_columns):
    """Confirm with user before importing"""
    print(f"\n⚠️ About to import {len(df)} rows from {file_name} into {table_name}")
    print(f"CSV columns: {', '.join(df.columns.tolist())}")
    print(f"Table columns: {', '.join(table_columns)}")
    
    # Check for column mismatches
    missing_columns = [col for col in table_columns if col not in df.columns]
    extra_columns = [col for col in df.columns if col not in table_columns]
    
    if missing_columns:
        print(f"⚠️ Warning: Table columns missing from CSV: {', '.join(missing_columns)}")
    if extra_columns:
        print(f"⚠️ Warning: CSV columns not in table: {', '.join(extra_columns)}")
    
    confirm = input(f"Continue with import? (y/n): ")
    return confirm.lower() == 'y'

def import_csv_to_table(conn, file_path, table_name=None):
    """Import a CSV file into a database table"""
    # If table name not provided, use filename without extension
    if table_name is None:
        table_name = os.path.splitext(os.path.basename(file_path))[0]
    
    # Preview the CSV
    df = preview_csv(file_path)
    if df is None:
        return False
    
    # Get table schema
    table_columns = get_table_schema(conn, table_name)
    if not table_columns:
        print(f"❌ Table {table_name} not found in database")
        return False
    
    # Confirm import
    if not confirm_import(os.path.basename(file_path), table_name, df, table_columns):
        print("❌ Import canceled")
        return False
    
    try:
        # Filter dataframe to only include columns that exist in the table
        valid_columns = [col for col in df.columns if col in table_columns]
        df_filtered = df[valid_columns]
        
        # Check if we have any valid columns
        if not valid_columns:
            print("❌ No matching columns found between CSV and table")
            return False
        
        # Import data
        print(f"📥 Importing {len(df_filtered)} rows with {len(valid_columns)} columns...")
        df_filtered.to_sql(table_name, conn, if_exists='append', index=False)
        
        # Verify import
        cursor = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
        count = cursor.fetchone()[0]
        print(f"✅ Import complete. Table {table_name} now has {count} rows")
        return True
    
    except Exception as e:
        print(f"❌ Error importing data: {e}")
        return False

def main():
    """Main function"""
    print("📊 ERP Data Import Script")
    print("=" * 50)
    
    # Connect to database
    conn = connect_db()
    if not conn:
        sys.exit(1)
    
    # Get CSV directory
    csv_dir = input("Enter directory containing CSV files (or press Enter for Downloads): ")
    if not csv_dir:
        csv_dir = os.path.expanduser("~/Downloads")
    print(f"Looking for CSV files in: {csv_dir}")
    
    # Find CSV files
    csv_files = find_csv_files(csv_dir)
    if not csv_files:
        sys.exit(1)
    
    # Process each file
    for i, file in enumerate(csv_files):
        print(f"\n[{i+1}/{len(csv_files)}] Processing {os.path.basename(file)}")
        
        # Ask which table to import into
        table_name = input(f"Enter table name to import into (or press Enter to use filename): ")
        if not table_name:
            table_name = os.path.splitext(os.path.basename(file))[0]
        
        # Import data
        import_csv_to_table(conn, file, table_name)
    
    # Close connection
    conn.close()
    print("\n✅ Import process complete!")

if __name__ == "__main__":
    main()
