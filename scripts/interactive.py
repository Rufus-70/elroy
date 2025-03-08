import argparse
import torch
import time
import os
from transformers import AutoTokenizer, AutoModelForCausalLM

def load_model(model_path):
    """Load the model and tokenizer from the specified path."""
    print(f"Loading model from: {model_path}")
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model path {model_path} does not exist!")
    
    start_time = time.time()
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    print(f"Tokenizer loaded in {time.time() - start_time:.2f} seconds")
    
    load_start_time = time.time()
    # Load with appropriate settings for Jetson Orin Nano
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16,
        device_map="auto" # This will use CUDA if available
    )
    load_time = time.time() - load_start_time
    print(f"Model loaded in {load_time:.2f} seconds")
    
    # Print memory usage
    if torch.cuda.is_available():
        memory_allocated = torch.cuda.memory_allocated() / (1024 ** 3)  # GB
        memory_reserved = torch.cuda.memory_reserved() / (1024 ** 3)  # GB
        print(f"GPU Memory allocated: {memory_allocated:.2f} GB")
        print(f"GPU Memory reserved: {memory_reserved:.2f} GB")
    
    return model, tokenizer

def generate_response(model, tokenizer, prompt, max_length=512, temperature=0.7):
    """Generate a response from the model given a prompt."""
    input_ids = tokenizer(prompt, return_tensors="pt").input_ids
    
    # Move to GPU if available
    if torch.cuda.is_available():
        input_ids = input_ids.cuda()
        if not next(model.parameters()).is_cuda:
            model = model.cuda()
    
    # Track tokens per second
    start_time = time.time()
    with torch.no_grad():
        output = model.generate(
            input_ids,
            max_length=max_length,
            temperature=temperature,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )
    
    inference_time = time.time() - start_time
    output_text = tokenizer.decode(output[0], skip_special_tokens=True)
    
    # Calculate performance metrics
    tokens_generated = output.shape[1] - input_ids.shape[1]
    tokens_per_second = tokens_generated / inference_time if inference_time > 0 else 0
    
    return output_text, inference_time, tokens_per_second

def interactive_session(model, tokenizer, max_length=512, temperature=0.7):
    """Run an interactive session with the model."""
    print("\n===== DeepSeek R1 Interactive Session =====")
    print("Type 'exit', 'quit', or 'q' to end the session")
    print("Type 'perf' to see performance metrics")
    print("=============================================\n")
    
    perf_metrics = []
    
    while True:
        prompt = input("\nYou: ")
        
        if prompt.lower() in ['exit', 'quit', 'q']:
            break
            
        if prompt.lower() == 'perf':
            if perf_metrics:
                avg_tps = sum(tps for _, tps in perf_metrics) / len(perf_metrics)
                avg_time = sum(time for time, _ in perf_metrics) / len(perf_metrics)
                print(f"\nPerformance metrics over {len(perf_metrics)} queries:")
                print(f"Average generation time: {avg_time:.2f} seconds")
                print(f"Average tokens per second: {avg_tps:.2f}")
                print(f"Memory allocated: {torch.cuda.memory_allocated() / (1024 ** 3):.2f} GB")
            else:
                print("No performance metrics available yet.")
            continue
            
        print("\nGenerating response...")
        response, inf_time, tps = generate_response(
            model, tokenizer, prompt, max_length, temperature
        )
        
        # Store metrics
        perf_metrics.append((inf_time, tps))
        
        print(f"\nDeepSeek R1: {response}")
        print(f"\n[Generated in {inf_time:.2f}s, {tps:.2f} tokens/s]")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Interactive session with DeepSeek R1")
    parser.add_argument("--model_path", type=str, default="/workspace/models/deepseek-r1-optimized",
                        help="Path to the model directory")
    parser.add_argument("--max_length", type=int, default=512,
                        help="Maximum length of generated text")
    parser.add_argument("--temperature", type=float, default=0.7,
                        help="Sampling temperature (higher = more random)")
    args = parser.parse_args()
    
    try:
        model, tokenizer = load_model(args.model_path)
        interactive_session(model, tokenizer, args.max_length, args.temperature)
    except KeyboardInterrupt:
        print("\nInteractive session terminated by user.")
    except Exception as e:
        print(f"\nError: {e}")
