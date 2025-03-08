#!/bin/bash

# Configuration
CONTAINER_NAME="deepseek_r1"
SCRIPT_DIR="/app"

# Fixed model paths
MODEL_PATH_1="/workspace/models/deepseek-r1-optimized"
MODEL_PATH_2="/workspace/models/deepseek-r1-distill-qwen-1.5b" 
MODEL_PATH_3="/workspace/models/deepseek/deepseek-llm-7b-base"

# Function to check if container is running
check_container() {
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "✓ Container $CONTAINER_NAME is running"
        return 0
    else
        echo "✗ Container $CONTAINER_NAME is not running"
        return 1
    fi
}

# Copy scripts to container
copy_scripts() {
    echo "Copying scripts to container..."
    docker exec $CONTAINER_NAME mkdir -p $SCRIPT_DIR 2>/dev/null
    docker cp verify_gpu.py $CONTAINER_NAME:$SCRIPT_DIR/
    docker cp interactive.py $CONTAINER_NAME:$SCRIPT_DIR/
    echo "✓ Scripts copied"
}

# Main menu
echo "DeepSeek R1 Management Script"
check_container

while true; do
    echo -e "\n===== DeepSeek R1 Management Script ====="
    echo "1. Verify GPU with Model 1 (deepseek-r1-optimized)"
    echo "2. Verify GPU with Model 2 (deepseek-r1-distill-qwen-1.5b)"
    echo "3. Verify GPU with Model 3 (deepseek-llm-7b-base)"
    echo "4. Copy scripts to container"
    echo "5. Exit"
    echo "======================================="
    echo -n "Please select an option: "
    
    read choice
    
    case $choice in
        1)
            echo "Running GPU verification with model: $MODEL_PATH_1"
            docker exec -it $CONTAINER_NAME python3 $SCRIPT_DIR/verify_gpu.py --model_path "$MODEL_PATH_1"
            ;;
        2)
            echo "Running GPU verification with model: $MODEL_PATH_2"
            docker exec -it $CONTAINER_NAME python3 $SCRIPT_DIR/verify_gpu.py --model_path "$MODEL_PATH_2"
            ;;
        3)
            echo "Running GPU verification with model: $MODEL_PATH_3"
            docker exec -it $CONTAINER_NAME python3 $SCRIPT_DIR/verify_gpu.py --model_path "$MODEL_PATH_3"
            ;;
        4)
            copy_scripts
            ;;
        5)
            echo "Exiting script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
