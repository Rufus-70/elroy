#!/bin/bash
# setup_deepseek_container.sh
CONTAINER_NAME="deepseek-persistent"
IMAGE_NAME="nvcr.io/nvidia/pytorch:24.09-py3-igpu"
SCRIPT_PATH="/scripts/test_deepseek_memory.py"

# Stop and remove the container if it already exists
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Create the container and copy the script inside
docker run -d --name $CONTAINER_NAME --runtime nvidia --gpus all --ipc=host -v $(pwd)/scripts:/scripts -v /models:/models $IMAGE_NAME sleep infinity

# Copy the script to the container
docker cp ./test_deepseek_memory.py $CONTAINER_NAME:$SCRIPT_PATH

# Wait for the container to be ready (adjust sleep time if needed)
sleep 5

# Install the required packages
docker exec -it $CONTAINER_NAME pip install transformers psutil bitsandbytes

# Execute the memory test script
docker exec -it $CONTAINER_NAME python $SCRIPT_PATH
