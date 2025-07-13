# 🤖 AI Services Platform

A comprehensive AI-powered platform that provides two integrated services:

1. **📄 PDF Verification Agent** - Analyzes PDF documents from IPFS with genuineness scoring
2. **💬 Web3 Smart Contract Assistant** - AI chatbot for decentralized platform support

Built with Flask, Google Gemini AI, and modern web technologies.

## ✨ Features

### 📄 PDF Verification Agent
- **Dynamic IPFS Integration**: Analyze any PDF from IPFS using public gateways
- **AI-Powered Analysis**: Text extraction, summarization, and genuineness scoring (0-10)
- **Real-time Processing**: Live feedback with loading states
- **JSON API**: RESTful endpoints for programmatic access

### 💬 Web3 Smart Contract Assistant  
- **Comprehensive Knowledge Base**: Detailed information about smart contracts
- **Interactive Chat Interface**: Real-time messaging with conversation history
- **Multi-Contract Support**: 
  - **FundraiserDApp**: Crowdfunding and campaign management
  - **Remittance**: Secure peer-to-peer transfers with secret phrases
  - **MultiPoolLoanSystem**: ROSCA-based decentralized lending pools
- **Context-Aware Responses**: AI understanding of blockchain workflows and functions

## 🚀 Quick Start

### Prerequisites
- Python 3.7+
- Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

### Installation

#### Option 1: Automated Setup (Recommended)

**Windows:**
```cmd
git clone https://github.com/yourusername/ai-services-platform.git
cd ai-services-platform
setup.bat
```

**Linux/Mac:**
```bash
git clone https://github.com/yourusername/ai-services-platform.git
cd ai-services-platform
chmod +x setup.sh
./setup.sh
```

#### Option 2: Manual Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/ai-services-platform.git
   cd ai-services-platform
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env and add your Gemini API key
   ```

4. **Start the server:**
   ```bash
   python server.py
   ```

5. **Open your browser:**
   Navigate to `http://localhost:5000`

## 🌐 API Documentation

### PDF Analysis Endpoint
```http
POST /analyze
Content-Type: application/json

{
  "ipfs_hash": "QmYourActualPDFHashHere"
}
```

**Response:**
```json
{
  "status": "success",
  "ipfs_hash": "QmYourHashHere",
  "summary": "Document summary...",
  "score": 8.5,
  "timestamp": "2025-07-13T10:30:00",
  "message": "PDF analysis completed successfully. Genuineness score: 8.5/10"
}
```

### Web3 Chatbot Endpoint
```http
POST /api/chat
Content-Type: application/json

{
  "prompt": "How do I create a fundraiser?"
}
```

**Response:**
```json
{
  "reply": "To create a fundraiser, you need to call the createFundraiser function...",
  "status": "success",
  "timestamp": "2025-07-13T10:30:00"
}
```

### Health Check
```http
GET /health
```

## 🧪 Testing

### Automated Tests
```bash
# Test PDF verification
python test_api.py

# Test Web3 chatbot
python test_chatbot.py
```

### Manual Testing
1. **PDF Verification**: Use IPFS hash `QmYA2fn8cMbVWo4v95RwcwJVyQsNtnEwHerfWR8UNtEwoE`
2. **Chatbot**: Try queries like "How do I create a fundraiser?" or "Explain the lending pool system"

## 📋 Smart Contract Knowledge Base

The chatbot provides expert assistance on:

### 🎯 FundraiserDApp
- Campaign creation and management
- Donation tracking and goal monitoring
- Fund withdrawal with deadline enforcement
- IPFS document integration for verification

### 💸 Remittance System
- Secure peer-to-peer money transfers
- Secret phrase-based security
- Unique payment ID generation
- Transaction descriptions and tracking

### 🏦 MultiPoolLoanSystem (ROSCA)
- Decentralized lending pool management
- Collateral-based participant security
- Automated bidding and payout mechanisms
- Default handling and surplus distribution

## 🎯 Example Use Cases

### PDF Verification
- Document authenticity verification
- Invoice and receipt validation
- Legal document analysis
- Academic paper verification

### Web3 Assistant
- Smart contract function explanations
- Workflow guidance for DeFi operations
- Security best practices
- Troubleshooting blockchain interactions

## 📁 Project Structure

```
ai-services-platform/
├── server.py                   # Main Flask application
├── knowledge_base/
│   └── contracts.json         # Smart contract knowledge base
├── main.py                    # CLI interface for PDF verification
├── agent.py                   # PDF scoring agent
├── task.py                    # Analysis task definitions
├── tools.py                   # PDF processing and AI utilities
├── test_api.py               # PDF API testing
├── test_chatbot.py           # Chatbot API testing
├── requirements.txt          # Python dependencies
├── .env.example             # Environment template
├── .gitignore              # Git ignore rules
├── setup.sh               # Linux/Mac setup script
├── setup.bat             # Windows setup script
└── README.md            # This file
```

## 🛠️ Development

### Adding New Smart Contracts
1. Update `knowledge_base/contracts.json`
2. Add contract details following the existing structure
3. Restart the server to load new knowledge

### Extending PDF Analysis
- Modify `tools.py` for new analysis features
- Update `agent.py` for additional scoring criteria
- Enhance prompts in `tools.py` for better AI responses

### Custom Endpoints
- Add new routes in `server.py`
- Follow existing error handling patterns
- Update API documentation in README

## 🔧 Troubleshooting

### Common Issues

**Server won't start**
- Check if port 5000 is available
- Verify all dependencies are installed
- Ensure Python 3.7+ is being used

**API key errors**
- Verify `GEMINI_API_KEY` in `.env` file
- Check API key validity at [Google AI Studio](https://makersuite.google.com/app/apikey)
- Ensure no extra spaces or quotes in the key

**PDF download fails**
- Verify IPFS hash is valid
- Check internet connection
- Try alternative IPFS gateways

**Chatbot not responding**
- Ensure `knowledge_base/contracts.json` exists
- Check Gemini API quota and limits
- Verify model availability

## 🚀 Deployment

### Local Development
```bash
python server.py
```

### Production Deployment
- Set `debug=False` in `server.py`
- Use production WSGI server (Gunicorn, uWSGI)
- Configure reverse proxy (Nginx, Apache)
- Set up SSL/TLS certificates
- Use environment variables for secrets

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Google Gemini AI](https://ai.google.dev/) for powerful language processing
- [IPFS](https://ipfs.io/) for decentralized file storage
- [Flask](https://flask.palletsprojects.com/) for the web framework
- [PyPDF2](https://pypdf2.readthedocs.io/) for PDF processing

## 📞 Support

- 🐛 **Bug Reports**: [Open an issue](https://github.com/yourusername/ai-services-platform/issues)
- 💡 **Feature Requests**: [Start a discussion](https://github.com/yourusername/ai-services-platform/discussions)
- 📧 **Contact**: your.email@example.com

---

<div align="center">
  <strong>Built with ❤️ for the Web3 and AI community</strong>
</div>

## 🚀 Features

- **Dynamic IPFS Hash Input**: Enter any IPFS hash via web interface or API
- **Web Interface**: User-friendly web UI at `http://localhost:5000`
- **REST API**: JSON API endpoint for programmatic access
- **JSON Responses**: All outputs in structured JSON format
- **Real-time Analysis**: Immediate feedback with loading states
- **Error Handling**: Comprehensive error messages and validation

## 📦 Installation

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure environment:**
   - Copy `.env.example` to `.env`
   - Add your Google Gemini API key:
     ```
     GEMINI_API_KEY=your_actual_api_key_here
     ```

## 🌐 Usage Options

### Option 1: Web Server (Recommended)
Start the localhost server with web interface and API:

```bash
python server.py
```

Then open your browser to:
- **Web Interface**: http://localhost:5000
- **API Endpoint**: http://localhost:5000/analyze
- **Health Check**: http://localhost:5000/health

### Option 2: Command Line
```bash
python main.py
```

### Option 3: API Testing
```bash
python test_api.py
```

## 🔗 API Usage

### Analyze PDF Endpoint
```bash
POST http://localhost:5000/analyze
Content-Type: application/json

{
  "ipfs_hash": "QmYourActualPDFHashHere"
}
```

### Example Response
```json
{
  "status": "success",
  "ipfs_hash": "QmYourHashHere",
  "summary": "This document appears to be an invoice from...",
  "score": 8.5,
  "timestamp": "2025-07-13T10:30:00",
  "message": "PDF analysis completed successfully. Genuineness score: 8.5/10"
}
```

### Error Response
```json
{
  "status": "error",
  "error": "Failed to download PDF from IPFS",
  "message": "Failed to analyze PDF. Please check the IPFS hash and try again.",
  "timestamp": "2025-07-13T10:30:00"
}
```

## 🎯 Web Interface Features

- **Dynamic Input**: Enter any IPFS hash in the web form
- **Real-time Loading**: Visual feedback during analysis
- **JSON Viewer**: Expandable raw JSON response
- **Error Display**: Clear error messages with suggestions
- **Responsive Design**: Works on desktop and mobile

## 🧪 Testing

Use these public PDF files for testing:
- `QmYA2fn8cMbVWo4v95RwcwJVyQsNtnEwHerfWR8UNtEwoE` (Example document)
- Any valid IPFS hash pointing to a PDF file

## 🔧 How It Works

1. **Input**: User provides IPFS hash via web form or API
2. **Download**: System fetches PDF from IPFS public gateway
3. **Extract**: Extracts text content from PDF using PyPDF2
4. **Analyze**: Uses Gemini AI to summarize and score genuineness
5. **Output**: Returns structured JSON with summary and score

## 📁 Project Structure
```
pdf_verification_agent/
├── server.py          # Flask web server with API
├── main.py            # Command-line interface
├── agent.py           # PDF scoring agent
├── task.py            # Analysis task definition
├── tools.py           # PDF processing and AI tools
├── test_api.py        # API testing client
├── requirements.txt   # Dependencies
└── .env              # Environment variables
```

## 🛠️ Troubleshooting

- **Server won't start**: Check if port 5000 is available
- **API key errors**: Verify your `GEMINI_API_KEY` in `.env`
- **IPFS download fails**: Try a different IPFS hash or check network
- **Model errors**: The system auto-detects working Gemini models

## 🔄 What's New

✅ **Dynamic IPFS hash input** - No more hardcoded hashes!
✅ **Localhost web server** - Easy-to-use web interface
✅ **JSON API responses** - Structured, parseable output
✅ **Real-time feedback** - Loading states and progress
✅ **Error handling** - Comprehensive error management
✅ **Multiple interfaces** - Web, API, and CLI options
