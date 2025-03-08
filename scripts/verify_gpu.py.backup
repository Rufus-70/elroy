#!/usr/bin/env python3
import argparse
import torch
import numpy as np
import time
import os
import sys

def verify_gpu():
    """Basic GPU verification"""
    print("\n===== GPU VERIFICATION =====")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    
    if not torch.cuda.is_available():
        print("GPU acceleration is NOT AVAILABLE")
        return False
    
    print(f"CUDA version: {torch.version.cuda}")
    print(f"GPU count: {torch.cuda.device_count()}")
    print(f"GPU name: {torch.cuda.get_device_name(0)}")
    
    # Check memory usage
    print(f"Current GPU memory usage: {torch.cuda.memory_allocated() / 1024**2:.2f} MB")
    
    # Run simple tensor operations
    print("Running test tensor operations on GPU...")
    a = torch.randn(2000, 2000).cuda()
    b = torch.randn(2000, 2000).cuda()
    
    start = time.time()
    c = torch.matmul(a, b)
    torch.cuda.synchronize()
    end = time.time()
    
    print(f"Matrix multiplication time: {end - start:.4f} seconds")
    print(f"GPU memory after operations: {torch.cuda.memory_allocated() / 1024**2:.2f} MB")
    
    # Compare with CPU
    a_cpu = a.cpu()
    b_cpu = b.cpu()
    c_cpu = torch.matmul(a_cpu, b_cpu)
    
    max_diff = torch.max(torch.abs(c_cpu - c.cpu())).item()
    print(f"Max difference between CPU and GPU results: {max_diff:.10f}")
    
    if max_diff > 0.1:
        print("WARNING: Significant precision differences detected")
    
    return True

def check_model(model_path):
    """Check if the model path exists and try to load the model"""
    print(f"\n===== MODEL CHECK =====")
    print(f"Model path: {model_path}")
    
    # Check if path exists
    if os.path.exists(model_path):
        print(f"✓ Model path exists")
        
        # Check if it looks like a model directory
        if os.path.isfile(os.path.join(model_path, "config.json")):
            print(f"✓ Found config.json - looks like a valid model directory")
            return True
        else:
            print(f"✗ No config.json found - may not be a valid model directory")
            # List contents to help debug
            print("\nDirectory contents:")
            try:
                for item in os.listdir(model_path):
                    print(f"  - {item}")
            except Exception as e:
                print(f"Error listing directory: {e}")
    else:
        print(f"✗ Model path does not exist")
        
        # Try to help diagnose
        parent_dir = os.path.dirname(model_path)
        if os.path.exists(parent_dir):
            print(f"\nParent directory exists. Contents of {parent_dir}:")
            try:
                for item in os.listdir(parent_dir):
                    print(f"  - {item}")
            except Exception as e:
                print(f"Error listing parent directory: {e}")
    
    return False
    
def main():
    parser = argparse.ArgumentParser(description="Verify GPU and model")
    parser.add_argument("--model_path", type=str, required=True, help="Path to model directory")
    args = parser.parse_args()
    
    print("====== DeepSeek R1 Verification ======")
    
    # Verify GPU first
    gpu_ok = verify_gpu()
    
    # Then check model path
    model_ok = check_model(args.model_path)
    
    print("\n===== VERIFICATION SUMMARY =====")
    print(f"GPU Status: {'✓ OK' if gpu_ok else '✗ ISSUES DETECTED'}")
    print(f"Model Status: {'✓ OK' if model_ok else '✗ ISSUES DETECTED'}")
    print("================================")

if __name__ == "__main__":
    main()
