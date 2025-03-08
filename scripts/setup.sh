#!/bin/bash

# Set project directory
PROJECT_DIR=~/projects/elroy
VENV_DIR=$PROJECT_DIR/venv
SCRIPT_DIR=$PROJECT_DIR/scripts

echo "🚀 Setting up agendic agent environment..."

# Create project directory if it doesn't exist
mkdir -p $PROJECT_DIR/data/ka1
mkdir -p $PROJECT_DIR/data/ko1
mkdir -p $PROJECT_DIR/data/ob1
mkdir -p $PROJECT_DIR/data/qms
mkdir -p $PROJECT_DIR/data/erp
mkdir -p $PROJECT_DIR/data/sme
mkdir -p $PROJECT_DIR/db
mkdir -p $VENV_DIR
mkdir -p $SCRIPT_DIR

# Set up virtual environment
if [ ! -d "$VENV_DIR/bin" ]; then
    echo "🔧 Creating virtual environment..."
    python3 -m venv $VENV_DIR
    echo "✅ Virtual environment created."
else
    echo "⚡ Virtual environment already exists."
fi

# Activate virtual environment
source $VENV_DIR/bin/activate

# Install dependencies
echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install pandas

echo "✅ Dependencies installed."

# Initialize database
echo "📂 Initializing database..."
python3 - <<EOF
import sqlite3
DB_FILE = "$PROJECT_DIR/db/agendic_agent.db"

SCHEMA = '''
CREATE TABLE IF NOT EXISTS ka1 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    iteration INTEGER NOT NULL,
    concern TEXT NOT NULL,
    planned_actions TEXT NOT NULL,
    expected_learnings TEXT NOT NULL,
    actual_learnings TEXT,
    actual_actions TEXT,
    changes_next_iteration TEXT
);

CREATE TABLE IF NOT EXISTS ko1 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    known_fact TEXT NOT NULL,
    source TEXT,
    assumption TEXT,
    status TEXT CHECK( status IN ('Pending', 'In Review', 'Confirmed', 'Disproven') ) NOT NULL,
    validation_method TEXT
);

CREATE TABLE IF NOT EXISTS ob1 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    observation TEXT NOT NULL,
    investigation_status TEXT CHECK( investigation_status IN ('Unreviewed', 'Investigating', 'Resolved') ) NOT NULL,
    linked_ka1 INTEGER,
    FOREIGN KEY (linked_ka1) REFERENCES ka1(id)
);

CREATE TABLE IF NOT EXISTS qms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    indexed_text TEXT
);

CREATE TABLE IF NOT EXISTS erp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    table_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sme (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic TEXT NOT NULL,
    document_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    indexed_text TEXT
);
'''

conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()
cursor.executescript(SCHEMA)
conn.commit()
conn.close()
print("✅ Database initialized successfully at", DB_FILE)
EOF

echo "🚀 Setup complete! Virtual environment, dependencies, and database are ready."
echo "To activate the virtual environment, run: source $VENV_DIR/bin/activate"
