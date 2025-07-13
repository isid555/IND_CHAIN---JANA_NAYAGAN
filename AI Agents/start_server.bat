@echo off
echo Starting PDF Verification Agent Server...
echo.
echo Make sure you have:
echo 1. Valid GEMINI_API_KEY in your .env file
echo 2. All dependencies installed (pip install -r requirements.txt)
echo.
echo Server will be available at:
echo - Web Interface: http://localhost:5000
echo - API Endpoint: http://localhost:5000/analyze
echo - Health Check: http://localhost:5000/health
echo.
echo Press Ctrl+C to stop the server
echo.
python server.py
pause
