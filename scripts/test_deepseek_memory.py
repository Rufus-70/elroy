import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
import psutil
import time
import gc

def print_memory_usage():
    """Print current memory usage statistics"""
    process = psutil.Process()
    print(f"CPU RAM: {process.memory_info().rss / (1024 * 1024):.2f} MB")
    if torch.cuda.is_available():
        for i in range(torch.cuda.device_count()):
            print(f"GPU {i} Memory: {torch.cuda.memory_allocated(i) / (1024 * 1024):.2f} MB / {torch.cuda.get_device_properties(i).total_memory / (1024 * 1024):.2f} MB")

# Configure model loading for low memory
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_quant_type="nf4"
)

print("Initial memory usage:")
print_memory_usage()

# Load tokenizer first
print("\nLoading tokenizer...")
tokenizer = AutoTokenizer.from_pretrained("/models", trust_remote_code=True)

print("\nMemory after loading tokenizer:")
print_memory_usage()

# Load model with memory optimization
print("\nLoading model with 4-bit quantization...")
try:
    model = AutoModelForCausalLM.from_pretrained(
        "/models",
        quantization_config=quantization_config,
        device_map="auto",
        trust_remote_code=True,
        torch_dtype=torch.float16,
        low_cpu_mem_usage=True
    )

    print("\nMemory after loading model:")
    print_memory_usage()

    # Test inference
    prompt = "Explain neural networks in one paragraph."
    print(f"\nGenerating response for: '{prompt}'")

    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

    start_time = time.time()
    with torch.no_grad():
        outputs = model.generate(**inputs, max_length=100)
    end_time = time.time()

    response = tokenizer.decode(outputs[0], skip_special_tokens=True)

    print(f"\nGeneration time: {end_time - start_time:.2f} seconds")
    print(f"Response: {response}")

    print("\nFinal memory usage:")
    print_memory_usage()

except Exception as e:
    print(f"Error loading or running model: {e}")

# Clean up
print("\nCleaning up...")
del model
del tokenizer
gc.collect()
if torch.cuda.is_available():
    torch.cuda.empty_cache()

print("\nMemory after cleanup:")
print_memory_usage()
