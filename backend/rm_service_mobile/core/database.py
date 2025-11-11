"""
Database connection - Reuse from rm_service
"""
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from rm_service.core.database import engine, Base, get_db

__all__ = ["engine", "Base", "get_db"]

