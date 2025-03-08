CREATE TABLE ka1 (
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
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE ko1 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    known_fact TEXT NOT NULL,
    source TEXT,
    assumption TEXT,
    status TEXT CHECK( status IN ('Pending', 'In Review', 'Confirmed', 'Disproven') ) NOT NULL,
    validation_method TEXT
);
CREATE TABLE ob1 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    observation TEXT NOT NULL,
    investigation_status TEXT CHECK( investigation_status IN ('Unreviewed', 'Investigating', 'Resolved') ) NOT NULL,
    linked_ka1 INTEGER,
    FOREIGN KEY (linked_ka1) REFERENCES ka1(id)
);
CREATE TABLE qms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    indexed_text TEXT
);
CREATE TABLE erp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    table_name TEXT NOT NULL
);
CREATE TABLE sme (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic TEXT NOT NULL,
    document_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    indexed_text TEXT
);
CREATE TABLE system_updates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    action TEXT NOT NULL,
    details TEXT NOT NULL
);
CREATE TABLE system_info (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    os_version TEXT,
    jetpack_version TEXT,
    cuda_version TEXT,
    cudnn_version TEXT,
    tensorrt_version TEXT,
    python_version TEXT,
    cpu_info TEXT,
    gpu_info TEXT,
    memory_info TEXT,
    storage_info TEXT,
    docker_containers TEXT,
    pytorch_gpu_test TEXT
);
