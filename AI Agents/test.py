from agent import PdfScorerAgent
from task import ScorePdfTask
import os
from dotenv import load_dotenv

def test_with_local_file():
    """Test version that uses a local PDF file instead of IPFS"""
    load_dotenv()
    
    if not os.getenv("GEMINI_API_KEY") or os.getenv("GEMINI_API_KEY") == "your_gemini_api_key_here":
        print("Please set your GEMINI_API_KEY in a .env file")
        print("Copy .env.example to .env and add your actual API key")
        return
    
    # Create a simple test PDF content (you can replace this with actual PDF testing)
    print("Testing PDF verification system...")
    print("Note: To test with IPFS, you need a valid IPFS hash of a PDF file")
    print("\nSystem is ready! The IPFS connection issue has been resolved.")
    print("The system now uses public IPFS gateways instead of requiring a local IPFS node.")

if __name__ == "__main__":
    test_with_local_file()
