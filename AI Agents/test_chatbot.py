import requests
import json

def test_chatbot(prompt):
    """Test the Web3 Chatbot API"""
    url = "http://localhost:5000/api/chat"
    
    payload = {
        "prompt": prompt
    }
    
    try:
        print(f"💬 Testing chatbot with prompt: {prompt}")
        print("📡 Sending request to API...")
        
        response = requests.post(url, json=payload, timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        result = response.json()
        
        if response.status_code == 200:
            print("🤖 Bot Reply:")
            print(result['reply'])
        else:
            print("❌ Error:")
            print(result.get('error', 'Unknown error'))
        
        print("\n📄 Full JSON Response:")
        print(json.dumps(result, indent=2))
        
        return result
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to server. Make sure the server is running at http://localhost:5000")
    except requests.exceptions.Timeout:
        print("⏰ Error: Request timed out.")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_multiple_prompts():
    """Test chatbot with various prompts"""
    test_prompts = [
        "What is the FundraiserDApp contract for?",
        "How do I create a fundraiser?",
        "Explain the remittance system",
        "What is the MultiPoolLoanSystem?",
        "How does the bidding mechanism work in lending pools?",
        "What are the security measures in the platform?"
    ]
    
    print("🧪 Testing Web3 Chatbot with multiple prompts")
    print("=" * 60)
    
    for i, prompt in enumerate(test_prompts, 1):
        print(f"\n📝 Test {i}/{len(test_prompts)}")
        print("-" * 40)
        test_chatbot(prompt)
        print("\n" + "=" * 60)

if __name__ == "__main__":
    choice = input("Choose test type:\n1. Single prompt\n2. Multiple test prompts\nEnter choice (1 or 2): ").strip()
    
    if choice == "1":
        user_prompt = input("\nEnter your question about Web3 smart contracts: ").strip()
        if user_prompt:
            test_chatbot(user_prompt)
        else:
            print("No prompt provided!")
    elif choice == "2":
        test_multiple_prompts()
    else:
        print("Invalid choice. Please run again and select 1 or 2.")
