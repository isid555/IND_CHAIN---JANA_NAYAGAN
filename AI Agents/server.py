from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
from agent import PdfScorerAgent
from task import ScorePdfTask
import os
import json
import google.generativeai as genai
from dotenv import load_dotenv
import traceback

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Initialize Gemini for both PDF analysis and chatbot
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)

# Load and format the knowledge base for chatbot
try:
    with open('knowledge_base/contracts.json', 'r') as f:
        contracts = json.load(f)
except FileNotFoundError:
    print("Warning: knowledge_base/contracts.json not found. Chatbot functionality will be limited.")
    contracts = {}

# Helper to format contracts into a structured prompt
def format_knowledge(contracts_data):
    if not contracts_data:
        return "No contract knowledge base available."
    
    formatted = []
    for contract_name, details in contracts_data.items():
        section = [f"📘 {contract_name}: {details['description']}"]

        if 'key_features' in details:
            section.append("\nKey Features:")
            for feature, desc in details['key_features'].items():
                section.append(f"- {feature.replace('_', ' ').title()}: {desc}")

        if 'functions' in details:
            section.append("\nFunctions:")
            for func, desc in details['functions'].items():
                section.append(f"- {func}(): {desc}")

        if 'events' in details:
            section.append("\nEvents:")
            for event, desc in details['events'].items():
                section.append(f"- {event}: {desc}")

        if 'use_cases' in details:
            use_cases = ", ".join(details['use_cases'])
            section.append(f"\nUse Cases: {use_cases}")

        if 'workflow' in details:
            section.append("\nWorkflow:")
            for step, desc in details['workflow'].items():
                section.append(f"- {step.replace('_', ' ').title()}: {desc}")

        if 'participant_lifecycle' in details:
            section.append("\nParticipant Lifecycle:")
            for stage, desc in details['participant_lifecycle'].items():
                section.append(f"- {stage.title()}: {desc}")

        formatted.append("\n".join(section))
    return "\n\n".join(formatted)

# Pre-generate context once at startup
formatted_context = format_knowledge(contracts)

def clean_text_formatting(text):
    """Remove all markdown and special formatting from text"""
    import re
    
    # First, handle all possible escape sequences
    text = text.replace('\\n\\n', '\n\n')  # Double escaped newlines
    text = text.replace('\\n', '\n')       # Single escaped newlines
    text = text.replace('\\t', ' ')        # Escaped tabs
    text = text.replace('\\r', '')         # Escaped carriage returns
    
    # Remove markdown bold (**text** and __text__)
    text = re.sub(r'\*\*(.*?)\*\*', r'\1', text)
    text = re.sub(r'__(.*?)__', r'\1', text)
    
    # Remove markdown italic (*text* and _text_)
    text = re.sub(r'\*(.*?)\*', r'\1', text)
    text = re.sub(r'_(.*?)_', r'\1', text)
    
    # Remove code blocks (```text```)
    text = re.sub(r'```.*?```', '', text, flags=re.DOTALL)
    
    # Remove inline code (`text`)
    text = re.sub(r'`(.*?)`', r'\1', text)
    
    # Remove extra quotes
    text = re.sub(r'"([^"]*)"', r'\1', text)
    text = re.sub(r"'([^']*)'", r'\1', text)
    
    # Remove escaped formatting characters
    text = re.sub(r'\\([*_`"\'])', r'\1', text)
    
    # Handle numbered lists more aggressively - catch all variations
    # \n\n1. -> \n\n1. (keep as is)
    # \n\n1 -> \n\n1. 
    # \n\n1: -> \n\n1. 
    text = re.sub(r'\n\n(\d+)[:\s]*', r'\n\n\1. ', text)
    
    # Clean up multiple consecutive newlines
    text = re.sub(r'\n{3,}', '\n\n', text)          # 3+ newlines to 2
    text = re.sub(r'\n\s+\n', '\n\n', text)         # Newlines with spaces between
    text = re.sub(r'[ \t]{2,}', ' ', text)          # Multiple spaces/tabs to single
    
    # Clean up formatting artifacts around punctuation
    text = re.sub(r'\s+([.,:;!?])', r'\1', text)    # Remove spaces before punctuation
    text = re.sub(r'([.,:;!?])\s{2,}', r'\1 ', text) # Multiple spaces after punctuation to single
    
    # Final cleanup
    text = text.strip()
    
    return text

# HTML template for the web interface with both services
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>AI Services Platform</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .services { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
        .service { background: #f8f9fa; padding: 20px; border-radius: 10px; border: 2px solid #dee2e6; }
        .service h2 { margin-top: 0; color: #495057; }
        .container { background: #ffffff; padding: 20px; border-radius: 10px; margin: 20px 0; border: 1px solid #dee2e6; }
        .input-group { margin: 15px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        textarea { height: 100px; resize: vertical; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 5px; }
        button:hover { background: #0056b3; }
        .chat-button { background: #28a745; }
        .chat-button:hover { background: #218838; }
        .result { background: #e9ecef; padding: 15px; border-radius: 5px; margin-top: 20px; max-height: 400px; overflow-y: auto; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-top: 20px; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-top: 20px; }
        .loading { color: #007bff; font-style: italic; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 5px; overflow-x: auto; }
        .chat-history { background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 20px; max-height: 300px; overflow-y: auto; }
        .chat-message { margin: 10px 0; padding: 10px; border-radius: 5px; }
        .user-message { background: #007bff; color: white; text-align: right; }
        .bot-message { background: #e9ecef; color: #495057; }
        .nav-tabs { display: flex; margin-bottom: 20px; }
        .nav-tab { padding: 10px 20px; background: #f8f9fa; border: 1px solid #dee2e6; cursor: pointer; margin-right: 5px; border-radius: 5px 5px 0 0; }
        .nav-tab.active { background: #007bff; color: white; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        @media (max-width: 768px) {
            .services { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🤖 AI Services Platform</h1>
        <p>PDF Verification Agent & Web3 Smart Contract Assistant</p>
    </div>

    <div class="nav-tabs">
        <div class="nav-tab active" onclick="switchTab('pdf')">📄 PDF Verification</div>
        <div class="nav-tab" onclick="switchTab('chat')">💬 Web3 Chatbot</div>
    </div>

    <!-- PDF Verification Tab -->
    <div id="pdf-tab" class="tab-content active">
        <div class="service">
            <h2>🔍 PDF Verification Agent</h2>
            <p>Analyze PDF documents from IPFS and get genuineness scores.</p>
            
            <div class="container">
                <form id="pdfForm">
                    <div class="input-group">
                        <label for="ipfsHash">IPFS Hash:</label>
                        <input type="text" id="ipfsHash" name="ipfsHash" placeholder="QmYourPDFHashHere..." required>
                        <small>Example: QmYA2fn8cMbVWo4v95RwcwJVyQsNtnEwHerfWR8UNtEwoE</small>
                    </div>
                    <button type="submit">🚀 Analyze PDF</button>
                </form>
            </div>

            <div id="pdfResult"></div>
        </div>
    </div>

    <!-- Chatbot Tab -->
    <div id="chat-tab" class="tab-content">
        <div class="service">
            <h2>💬 Web3 Smart Contract Assistant</h2>
            <p>Ask questions about our decentralized platform's smart contracts.</p>
            
            <div class="container">
                <div class="input-group">
                    <label for="chatPrompt">Your Question:</label>
                    <textarea id="chatPrompt" placeholder="Ask about fundraising, remittance, or lending pools..."></textarea>
                </div>
                <button class="chat-button" onclick="sendChatMessage()">💬 Send Message</button>
                <button onclick="clearChat()">🗑️ Clear Chat</button>
            </div>

            <div id="chatHistory" class="chat-history"></div>
        </div>
    </div>

    <script>
        let chatHistory = [];

        function switchTab(tabName) {
            // Hide all tabs
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.nav-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected tab
            document.getElementById(tabName + '-tab').classList.add('active');
            event.target.classList.add('active');
        }

        // PDF Verification functionality
        document.getElementById('pdfForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const ipfsHash = document.getElementById('ipfsHash').value;
            const resultDiv = document.getElementById('pdfResult');
            
            resultDiv.innerHTML = '<div class="loading">🔄 Analyzing PDF... This may take a moment.</div>';
            
            try {
                const response = await fetch('/analyze', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ipfs_hash: ipfsHash})
                });
                
                const data = await response.json();
                
                if (response.ok) {
                    resultDiv.innerHTML = `
                        <div class="success">
                            <h3>✅ Analysis Complete</h3>
                            <p><strong>Genuineness Score:</strong> ${data.score}/10</p>
                            <p><strong>Summary:</strong></p>
                            <p>${data.summary}</p>
                            <details>
                                <summary>📄 Raw JSON Response</summary>
                                <pre>${JSON.stringify(data, null, 2)}</pre>
                            </details>
                        </div>
                    `;
                } else {
                    resultDiv.innerHTML = `
                        <div class="error">
                            <h3>❌ Error</h3>
                            <p>${data.error}</p>
                        </div>
                    `;
                }
            } catch (error) {
                resultDiv.innerHTML = `
                    <div class="error">
                        <h3>❌ Network Error</h3>
                        <p>Failed to connect to the server: ${error.message}</p>
                    </div>
                `;
            }
        });

        // Chatbot functionality
        async function sendChatMessage() {
            const prompt = document.getElementById('chatPrompt').value.trim();
            if (!prompt) return;

            const chatHistoryDiv = document.getElementById('chatHistory');
            
            // Add user message
            addChatMessage('user', prompt);
            document.getElementById('chatPrompt').value = '';
            
            // Show loading
            addChatMessage('bot', '🤔 Thinking...');
            
            try {
                const response = await fetch('/api/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({prompt: prompt})
                });
                
                const data = await response.json();
                
                // Remove loading message
                const messages = chatHistoryDiv.querySelectorAll('.chat-message');
                if (messages.length > 0) {
                    messages[messages.length - 1].remove();
                }
                
                if (response.ok) {
                    addChatMessage('bot', data.reply);
                } else {
                    addChatMessage('bot', `❌ Error: ${data.error}`);
                }
            } catch (error) {
                // Remove loading message
                const messages = chatHistoryDiv.querySelectorAll('.chat-message');
                if (messages.length > 0) {
                    messages[messages.length - 1].remove();
                }
                addChatMessage('bot', `❌ Network Error: ${error.message}`);
            }
        }

        function addChatMessage(sender, message) {
            const chatHistoryDiv = document.getElementById('chatHistory');
            const messageDiv = document.createElement('div');
            messageDiv.className = `chat-message ${sender}-message`;
            messageDiv.textContent = message;
            chatHistoryDiv.appendChild(messageDiv);
            chatHistoryDiv.scrollTop = chatHistoryDiv.scrollHeight;
        }

        function clearChat() {
            document.getElementById('chatHistory').innerHTML = '';
            chatHistory = [];
        }

        // Allow Enter key to send messages
        document.getElementById('chatPrompt').addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendChatMessage();
            }
        });
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    """Serve the main web interface"""
    return render_template_string(HTML_TEMPLATE)

@app.route('/analyze', methods=['POST'])
def analyze_pdf():
    """API endpoint to analyze PDF from IPFS hash"""
    try:
        # Check if API key is configured
        if not os.getenv("GEMINI_API_KEY") or os.getenv("GEMINI_API_KEY") == "your_gemini_api_key_here":
            return jsonify({
                "error": "GEMINI_API_KEY not configured. Please set it in your .env file.",
                "status": "error"
            }), 500

        # Get IPFS hash from request
        data = request.get_json()
        if not data or 'ipfs_hash' not in data:
            return jsonify({
                "error": "Missing 'ipfs_hash' in request body",
                "status": "error"
            }), 400

        ipfs_hash = data['ipfs_hash'].strip()
        if not ipfs_hash:
            return jsonify({
                "error": "IPFS hash cannot be empty",
                "status": "error"
            }), 400

        # Create agent and task
        agent = PdfScorerAgent()
        task = ScorePdfTask(ipfs_hash=ipfs_hash)
        
        # Run the analysis
        result = agent.run(task)
        
        # Clean up the summary text formatting
        cleaned_summary = clean_text_formatting(result["summary"])
        
        # Return JSON formatted response
        response = {
            "status": "success",
            "ipfs_hash": ipfs_hash,
            "summary": cleaned_summary,
            "score": result["score"],
            "timestamp": __import__('datetime').datetime.now().isoformat(),
            "message": f"PDF analysis completed successfully. Genuineness score: {result['score']}/10"
        }
        
        return jsonify(response), 200

    except Exception as e:
        error_message = str(e)
        print(f"Error analyzing PDF: {error_message}")
        print(traceback.format_exc())
        
        return jsonify({
            "status": "error",
            "error": error_message,
            "message": "Failed to analyze PDF. Please check the IPFS hash and try again.",
            "timestamp": __import__('datetime').datetime.now().isoformat()
        }), 500

@app.route('/api/chat', methods=['POST'])
def chat():
    """Web3 Smart Contract Chatbot API endpoint"""
    try:
        # Check if API key is configured
        if not GEMINI_API_KEY or GEMINI_API_KEY == "your_gemini_api_key_here":
            return jsonify({
                "error": "GEMINI_API_KEY not configured. Please set it in your .env file.",
                "status": "error"
            }), 500

        # Get prompt from request
        data = request.get_json()
        if not data or 'prompt' not in data:
            return jsonify({
                "error": "Missing 'prompt' in request body",
                "status": "error"
            }), 400

        prompt = data.get("prompt", "").strip()
        if not prompt:
            return jsonify({
                "error": "Prompt cannot be empty",
                "status": "error"
            }), 400

        # Create full prompt with knowledge base
        full_prompt = f"""
You are a helpful AI assistant for a decentralized Web3 application.

The platform includes smart contracts for:
- Fundraising (FundraiserDApp)
- Remittance (secure peer-to-peer transfers)
- Lending pools using a ROSCA model (MultiPoolLoanSystem)

Below is the complete knowledge base of the system contracts:

{formatted_context}

IMPORTANT FORMATTING RULES:
- Use ONLY plain text in your response
- Do NOT use any markdown formatting like **bold**, *italic*, or `code`
- Do NOT use asterisks (*), quotes ("), backticks (`), or other special characters for formatting
- Do NOT use numbered lists with special formatting
- Use simple numbered lists like: 1. First item, 2. Second item
- Use simple bullet points with dashes: - Item one, - Item two
- Keep responses clean and readable without any markup

Now, answer the following user query with accurate, simple, and clear instructions in plain text only.
Be helpful and provide specific details from the knowledge base when relevant.
If the user asks about functions, explain how to use them.
If they ask about workflows, walk them through the steps.
Keep your responses concise but informative.

User: {prompt}
"""

        # Try to get a working model
        model_names = ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-1.0-pro"]
        response_text = None
        
        for model_name in model_names:
            try:
                model = genai.GenerativeModel(model_name)
                response = model.generate_content(full_prompt)
                response_text = response.text.strip()
                
                # Clean up formatting - remove markdown and special characters
                response_text = clean_text_formatting(response_text)
                break
            except Exception as e:
                print(f"Model {model_name} failed: {e}")
                continue

        if response_text is None:
            return jsonify({
                "error": "Failed to generate response. No working model available.",
                "status": "error"
            }), 500

        return jsonify({
            "reply": response_text,
            "status": "success",
            "timestamp": __import__('datetime').datetime.now().isoformat()
        })

    except Exception as e:
        print(f"Chat error: {e}")
        print(traceback.format_exc())
        
        return jsonify({
            "error": str(e),
            "status": "error",
            "message": "Failed to process chat request.",
            "timestamp": __import__('datetime').datetime.now().isoformat()
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "message": "PDF Verification Agent is running",
        "timestamp": __import__('datetime').datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("🚀 Starting AI Services Platform...")
    print("📝 Make sure you have:")
    print("   1. Valid GEMINI_API_KEY in your .env file")
    print("   2. All dependencies installed (pip install -r requirements.txt)")
    print("\n🌐 Server will be available at:")
    print("   • Web Interface: http://localhost:5000")
    print("   • PDF Analysis API: http://localhost:5000/analyze")
    print("   • Web3 Chatbot API: http://localhost:5000/api/chat")
    print("   • Health Check: http://localhost:5000/health")
    print("\n📖 API Usage:")
    print("   PDF Analysis:")
    print("   POST /analyze")
    print("   Body: {\"ipfs_hash\": \"QmYourHashHere\"}")
    print("\n   Web3 Chatbot:")
    print("   POST /api/chat") 
    print("   Body: {\"prompt\": \"Your question about smart contracts\"}")
    print("\n⚠️  SECURITY NOTE: This is a development server.")
    print("   For production, use a proper WSGI server (gunicorn, uwsgi)")
    
    # For production, set debug=False
    DEBUG_MODE = os.getenv('FLASK_ENV') != 'production'
    app.run(host='0.0.0.0', port=5000, debug=DEBUG_MODE)
