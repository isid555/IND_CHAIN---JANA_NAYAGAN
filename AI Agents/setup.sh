#!/bin/bash

# AI Services Platform Setup Script
echo "🚀 Setting up AI Services Platform..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo "❌ Python is not installed. Please install Python 3.7+ first."
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

echo "✅ Python found: $($PYTHON_CMD --version)"

# Check if pip is installed
if ! command -v pip &> /dev/null; then
    echo "❌ pip is not installed. Please install pip first."
    exit 1
fi

echo "✅ pip found: $(pip --version)"

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created from .env.example"
    echo "⚠️  IMPORTANT: Edit .env file and add your actual Gemini API key!"
else
    echo "⚠️  .env file already exists"
fi

# Check if knowledge base exists
if [ ! -f "knowledge_base/contracts.json" ]; then
    echo "❌ Warning: knowledge_base/contracts.json not found"
    echo "   Web3 chatbot functionality will be limited"
else
    echo "✅ Knowledge base found"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit .env file and add your Gemini API key"
echo "   Get it from: https://makersuite.google.com/app/apikey"
echo ""
echo "2. Start the server:"
echo "   $PYTHON_CMD server.py"
echo ""
echo "3. Open your browser to:"
echo "   http://localhost:5000"
echo ""
echo "📖 For more information, see README.md"
