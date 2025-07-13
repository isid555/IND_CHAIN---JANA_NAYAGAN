import google.generativeai as genai
import os
from dotenv import load_dotenv

def test_model():
    """Test Gemini model initialization and basic functionality"""
    load_dotenv()
    
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key or api_key == "your_gemini_api_key_here":
        print("❌ Please set your GEMINI_API_KEY in a .env file")
        return False
    
    genai.configure(api_key=api_key)
    
    # Try different model names
    model_names = [
        "gemini-1.5-flash",
        "gemini-1.5-pro", 
        "gemini-1.0-pro",
        "models/gemini-1.5-flash",
        "models/gemini-1.5-pro",
        "models/gemini-1.0-pro"
    ]
    
    for model_name in model_names:
        try:
            print(f"🔄 Trying model: {model_name}")
            model = genai.GenerativeModel(model_name)
            
            # Test with a simple prompt
            response = model.generate_content("Say hello")
            print(f"✅ SUCCESS with {model_name}")
            print(f"Response: {response.text}")
            return True
            
        except Exception as e:
            print(f"❌ Failed with {model_name}: {str(e)[:100]}...")
            continue
    
    print("❌ No working model found!")
    print("\n💡 Try these steps:")
    print("1. Check your API key is valid")
    print("2. Make sure you have access to Gemini API")
    print("3. Visit https://makersuite.google.com/app/apikey to verify your key")
    return False

if __name__ == "__main__":
    test_model()
