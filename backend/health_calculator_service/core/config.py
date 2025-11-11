"""
Configuration settings for Health Calculator Service
"""
import os
import sys
from dotenv import load_dotenv

# Load .env file from root directory
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
env_path = os.path.join(root_dir, '.env')
load_dotenv(dotenv_path=env_path)

# Service specific config
SERVICE_NAME = "Health Calculator Service"
SERVICE_VERSION = "1.0.0"

# Database Configuration (use same as auth service)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
# Use healthkon_bpjs if DB_NAME not set, fallback to healthkon for compatibility
DB_NAME = os.getenv("DB_NAME", "healthkon_bpjs")

