from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
import time

# Path is now the mount point directly
model_path = "/models"

# Load model and tokenizer
print(f"Loading model from: {model_path}")
tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    model_path, 
    torch_dtype=torch.float16,
    device_map="auto",
    trust_remote_code=True
)

# Verify device
device = next(model.parameters()).device
print(f'Using device: {device}')

# Test inference
prompt = "Explain the advantages of transformer models in three sentences."
input_ids = tokenizer(prompt, return_tensors='pt').to(device)

# Time the inference
start_time = time.time()
outputs = model.generate(**input_ids, max_length=100)
end_time = time.time()

# Print results
print(f'Generation time: {end_time - start_time:.2f} seconds')
print('Generated text:')
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
