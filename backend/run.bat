@echo off
REM Script to run FastAPI services using Python from venv (Windows)
REM This script automatically activates venv and runs the services

REM Get the directory where this script is located
cd /d "%~dp0"

REM Check if venv exists
if not exist "venv" (
    echo ❌ Error: venv not found!
    echo    Please create venv first: python -m venv venv
    exit /b 1
)

REM Activate venv
echo ✅ Activating virtual environment...
call venv\Scripts\activate.bat

REM Check Python version
echo ✅ Python version:
python --version
echo ✅ Python path:
where python
echo.

REM Check if requirements are installed
if not exist "venv\Scripts\uvicorn.exe" (
    echo ⚠️  Dependencies not installed. Installing...
    pip install -r requirements.txt
    echo.
)

REM Run the Python script with venv Python
python running.py %*

