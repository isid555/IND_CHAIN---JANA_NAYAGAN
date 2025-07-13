"""
Simple command-line interface for the PDF Verification Agent
For web interface and API, use: python server.py
"""

from agent import PdfScorerAgent
from task import ScorePdfTask
import os
import json
from dotenv import load_dotenv

def main():
    """Command-line interface for PDF verification"""
    load_dotenv()
    
    print("🔍 PDF Verification Agent - Command Line Interface")
    print("=" * 60)
    
    # Check API key
    if not os.getenv("GEMINI_API_KEY") or os.getenv("GEMINI_API_KEY") == "your_gemini_api_key_here":
        print("❌ Please set your GEMINI_API_KEY in a .env file")
        print("💡 For web interface, run: python server.py")
        return
    
    # Get IPFS hash from user
    ipfs_hash = input("📎 Enter IPFS hash of PDF file: ").strip()
    
    if not ipfs_hash:
        print("❌ IPFS hash cannot be empty")
        return
    
    try:
        print(f"\n🔄 Analyzing PDF with hash: {ipfs_hash}")
        print("⏳ This may take a moment...")
        
        # Create agent and task
        agent = PdfScorerAgent()
        task = ScorePdfTask(ipfs_hash=ipfs_hash)
        
        # Run analysis
        result = agent.run(task)
        
        # Format response as JSON
        response = {
            "status": "success",
            "ipfs_hash": ipfs_hash,
            "summary": result["summary"],
            "score": result["score"],
            "message": f"PDF analysis completed. Genuineness score: {result['score']}/10"
        }
        
        print("\n✅ Analysis Complete!")
        print("📄 JSON Response:")
        print(json.dumps(response, indent=2))
        
    except Exception as e:
        error_response = {
            "status": "error",
            "ipfs_hash": ipfs_hash,
            "error": str(e),
            "message": "Failed to analyze PDF. Please check the IPFS hash and try again."
        }
        
        print("\n❌ Analysis Failed!")
        print("📄 JSON Response:")
        print(json.dumps(error_response, indent=2))

if __name__ == "__main__":
    main()
    print("\n💡 For web interface and API server, run: python server.py")
