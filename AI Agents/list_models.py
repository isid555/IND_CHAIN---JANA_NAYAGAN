import google.generativeai as genai
import os
from dotenv import load_dotenv

def list_available_models():
    """List all available Gemini models"""
    load_dotenv()
    
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key or api_key == "your_gemini_api_key_here":
        print("Please set your GEMINI_API_KEY in a .env file")
        return
    
    genai.configure(api_key=api_key)
    
    try:
        print("Available Gemini models:")
        for model in genai.list_models():
            if 'generateContent' in model.supported_generation_methods:
                print(f"- {model.name}")
    except Exception as e:
        print(f"Error listing models: {e}")

if __name__ == "__main__":
    list_available_models()
