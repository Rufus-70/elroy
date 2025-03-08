#!/bin/bash
# Jetson Orin Nano System Assessment Script with Database Logging
# This script gathers system information for Phase 0 assessment and logs to a SQLite database

OUTPUT_FILE=~/projects/elroy/system_assessment/system_info_report.txt
DB_FILE=~/projects/elroy/system_assessment/system_assessment.db
mkdir -p $(dirname "$OUTPUT_FILE")

# Create or overwrite the output file
echo "Jetson Orin Nano System Assessment Report" > $OUTPUT_FILE
echo "=========================================" >> $OUTPUT_FILE

# Initialize SQLite database if not exists
if [ ! -f "$DB_FILE" ]; then
    sqlite3 $DB_FILE "CREATE TABLE system_info (
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
    );"
fi

# Collect OS Version & JetPack Details
OS_VERSION=$(cat /etc/nv_tegra_release)
echo "$OS_VERSION" >> $OUTPUT_FILE

# Collect CUDA, cuDNN, and TensorRT Versions
CUDA_VERSION=$(nvcc --version 2>/dev/null | grep "release")
CUDNN_VERSION=$(dpkg -l | grep libcudnn8 | awk '{print $3}')
TENSORRT_VERSION=$(dpkg -l | grep tensorrt | awk '{print $3}')
echo "\nCUDA Version: $CUDA_VERSION" >> $OUTPUT_FILE
echo "cuDNN Version: $CUDNN_VERSION" >> $OUTPUT_FILE
echo "TensorRT Version: $TENSORRT_VERSION" >> $OUTPUT_FILE

# Collect Python Version
PYTHON_VERSION=$(python3 --version)
echo "\nPython Version: $PYTHON_VERSION" >> $OUTPUT_FILE

# Collect System Resources
CPU_INFO=$(lscpu | grep "Model name")
GPU_INFO=$(tegrastats --interval 1000 --logfile /tmp/gpu_usage.log & sleep 5; killall tegrastats; cat /tmp/gpu_usage.log)
MEMORY_INFO=$(free -h)
STORAGE_INFO=$(df -h)
echo "\nCPU Info: $CPU_INFO" >> $OUTPUT_FILE
echo "GPU Info: $GPU_INFO" >> $OUTPUT_FILE
echo "Memory Info: $MEMORY_INFO" >> $OUTPUT_FILE
echo "Storage Info: $STORAGE_INFO" >> $OUTPUT_FILE

# Collect Docker Containers
DOCKER_CONTAINERS=$(sudo docker ps -a --format "{{.ID}} {{.Image}} {{.Status}}")
echo "\nDocker Containers: $DOCKER_CONTAINERS" >> $OUTPUT_FILE

# Check PyTorch GPU in Container
PYTORCH_CONTAINER="nvcr.io/nvidia/pytorch:24.09-py3-igpu"
PYTORCH_GPU_TEST="Not Run"
if sudo docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$PYTORCH_CONTAINER"; then
    PYTORCH_GPU_TEST=$(sudo docker run --rm --runtime=nvidia --gpus all $PYTORCH_CONTAINER python3 -c "import torch; print(torch.cuda.is_available())")
    echo "\nPyTorch GPU Test: $PYTORCH_GPU_TEST" >> $OUTPUT_FILE
fi

# Insert Data into SQLite Database
sqlite3 $DB_FILE "INSERT INTO system_info (
    os_version, jetpack_version, cuda_version, cudnn_version, tensorrt_version, 
    python_version, cpu_info, gpu_info, memory_info, storage_info, docker_containers, pytorch_gpu_test
) VALUES (
    '$OS_VERSION', 'R36', '$CUDA_VERSION', '$CUDNN_VERSION', '$TENSORRT_VERSION',
    '$PYTHON_VERSION', '$CPU_INFO', '$GPU_INFO', '$MEMORY_INFO', '$STORAGE_INFO',
    '$DOCKER_CONTAINERS', '$PYTORCH_GPU_TEST'
);"

echo "\nSystem Assessment Complete. Results stored in: $OUTPUT_FILE and logged to database: $DB_FILE"
