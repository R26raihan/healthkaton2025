"""
Configuration settings - Reuse from auth service
"""
import os
import sys
from dotenv import load_dotenv

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from auth.core.config import DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME

# Service specific config
SERVICE_NAME = "Medical Records Service"
SERVICE_VERSION = "1.0.0"

