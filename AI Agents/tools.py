import requests
from PyPDF2 import PdfReader
import re
import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

# Try different model names in order of preference
model_names = ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-pro", "models/gemini-1.5-flash"]
model = None

for model_name in model_names:
    try:
        model = genai.GenerativeModel(model_name)
        # Test the model with a simple request
        test_response = model.generate_content("Hello")
        print(f"Successfully using model: {model_name}")
        break
    except Exception as e:
        print(f"Model {model_name} failed: {str(e)[:100]}...")
        continue

if model is None:
    raise Exception("No working Gemini model found. Please check your API key and try running 'python list_models.py' to see available models.")

def download_pdf_from_ipfs(ipfs_hash: str) -> str:
    """Download PDF from IPFS using public gateway"""
    # Use public IPFS gateway
    gateway_url = f"https://ipfs.io/ipfs/{ipfs_hash}"
    
    try:
        response = requests.get(gateway_url, timeout=30)
        response.raise_for_status()
        
        # Save to local file
        file_path = f"{ipfs_hash}.pdf"
        with open(file_path, 'wb') as f:
            f.write(response.content)
        
        return file_path
    except requests.exceptions.RequestException as e:
        raise Exception(f"Failed to download PDF from IPFS: {e}")

def extract_text_from_pdf(file_path: str) -> str:
    reader = PdfReader(file_path)
    text = " ".join(page.extract_text() or "" for page in reader.pages)
    return text

def summarize_text(text: str) -> str:
    prompt = f"Summarize the following PDF content:\n\n{text[:8000]}"
    response = model.generate_content(prompt)
    return response.text.strip()

def score_pdf_content(text: str) -> float:
    prompt = f"""
    Analyze the following document and give a score between 0 and 10 for how genuine it seems. 
    Consider whether it's a proper invoice, has dates, formatting, signatures, or official tone.
    Output ONLY the score:
    
    {text[:8000]}
    """
    response = model.generate_content(prompt)
    try:
        return float(re.findall(r'\d+(\.\d+)?', response.text)[0])
    except:
        return 5.0  # Default fallback
