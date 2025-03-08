import requests
import streamlit as st

st.title("LLM Model Debugging")

# Query Ollama API
try:
    response = requests.get("http://localhost:11434/api/tags")
    response_json = response.json()
    st.write("Ollama API Response:", response_json)
except Exception as e:
    st.error(f"Error querying Ollama: {e}")
