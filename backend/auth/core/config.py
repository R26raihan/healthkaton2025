"""
Configuration settings loaded from .env file with auto-detect MySQL port
"""
import os
import socket
from dotenv import load_dotenv

# Load .env file from root directory
# config.py is in auth/core/, so we need to go up 2 levels to reach backend/
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
env_path = os.path.join(root_dir, '.env')
load_dotenv(dotenv_path=env_path)

# Database Configuration
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "healthkon")

# Auto-detect MySQL port if not specified
def detect_mysql_port():
    """Auto-detect MySQL port by trying to connect with PyMySQL"""
    env_port = os.getenv("DB_PORT")
    if env_port:
        return env_port
    
    # Try to detect by actually connecting with PyMySQL
    try:
        import pymysql
        # Common MySQL ports to try
        common_ports = [3306, 3307, 3308, 55662, 33060]
        
        for port in common_ports:
            try:
                # Try to connect with short timeout
                conn = pymysql.connect(
                    host=DB_HOST,
                    port=port,
                    user=DB_USER,
                    password=DB_PASSWORD,
                    connect_timeout=2
                )
                conn.close()
                return str(port)
            except (pymysql.Error, Exception):
                continue
    except ImportError:
        # Fallback to socket check if pymysql not available yet
        common_ports = [3306, 3307, 3308, 55662, 33060]
        for port in common_ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(1)
                result = sock.connect_ex((DB_HOST, port))
                sock.close()
                if result == 0:
                    return str(port)
            except Exception:
                continue
    
    # Default to 3306 if none found
    return "3306"

DB_PORT = detect_mysql_port()

# JWT Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-this-in-production")
ALGORITHM = os.getenv("ALGORITHM", "HS256") 
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "43200"))  # 30 days (1 month)

