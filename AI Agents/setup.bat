@echo off
echo 🚀 Setting up AI Services Platform...

:: Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed. Please install Python 3.7+ first.
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo ✅ Python found
python --version

:: Check if pip is installed
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip is not installed. Please install pip first.
    pause
    exit /b 1
)

echo ✅ pip found
pip --version

:: Install dependencies
echo 📦 Installing dependencies...
pip install -r requirements.txt

if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully

:: Create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file...
    copy .env.example .env >nul
    echo ✅ .env file created from .env.example
    echo ⚠️  IMPORTANT: Edit .env file and add your actual Gemini API key!
) else (
    echo ⚠️  .env file already exists
)

:: Check if knowledge base exists
if not exist "knowledge_base\contracts.json" (
    echo ❌ Warning: knowledge_base\contracts.json not found
    echo    Web3 chatbot functionality will be limited
) else (
    echo ✅ Knowledge base found
)

echo.
echo 🎉 Setup complete!
echo.
echo 📋 Next steps:
echo 1. Edit .env file and add your Gemini API key
echo    Get it from: https://makersuite.google.com/app/apikey
echo.
echo 2. Start the server:
echo    python server.py
echo.
echo 3. Open your browser to:
echo    http://localhost:5000
echo.
echo 📖 For more information, see README.md
pause
