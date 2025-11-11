#!/bin/bash
# Script to run FastAPI services using Python from venv
# This script automatically activates venv and runs the services

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "❌ Error: venv not found!"
    echo "   Please create venv first: python3 -m venv venv"
    exit 1
fi

# Activate venv
echo "✅ Activating virtual environment..."
source venv/bin/activate

# Check Python version
echo "✅ Python version: $(python --version)"
echo "✅ Python path: $(which python)"
echo ""

# Check if requirements are installed
if [ ! -f "venv/bin/uvicorn" ]; then
    echo "⚠️  Dependencies not installed. Installing..."
    pip install -r requirements.txt
    echo ""
fi

# Run the Python script with venv Python
python running.py "$@"

