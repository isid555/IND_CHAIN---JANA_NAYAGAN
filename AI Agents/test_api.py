import requests
import json

def test_api(ipfs_hash):
    """Test the PDF verification API"""
    url = "http://localhost:5000/analyze"
    
    payload = {
        "ipfs_hash": ipfs_hash
    }
    
    try:
        print(f"🔍 Testing with IPFS hash: {ipfs_hash}")
        print("📡 Sending request to API...")
        
        response = requests.post(url, json=payload, timeout=60)
        
        print(f"📊 Response Status: {response.status_code}")
        print("📄 Response JSON:")
        print(json.dumps(response.json(), indent=2))
        
        return response.json()
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to server. Make sure the server is running at http://localhost:5000")
    except requests.exceptions.Timeout:
        print("⏰ Error: Request timed out. The PDF might be too large or the server is busy.")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_health():
    """Test the health check endpoint"""
    try:
        response = requests.get("http://localhost:5000/health")
        print("🏥 Health Check:")
        print(json.dumps(response.json(), indent=2))
    except Exception as e:
        print(f"❌ Health check failed: {e}")

if __name__ == "__main__":
    print("🧪 PDF Verification API Test Client")
    print("=" * 50)
    
    # Test health first
    test_health()
    print("\n" + "=" * 50)
    
    # Test with example IPFS hash
    # Replace this with a real PDF IPFS hash
    example_hash = "QmYA2fn8cMbVWo4v95RwcwJVyQsNtnEwHerfWR8UNtEwoE"
    
    # You can also get input from user
    user_hash = input(f"\nEnter IPFS hash (or press Enter to use example): ").strip()
    if user_hash:
        example_hash = user_hash
    
    test_api(example_hash)
