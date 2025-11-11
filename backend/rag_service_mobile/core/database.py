"""
Database connection - Reuse from auth service for medical documents
"""
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from auth.core.database import engine, Base, get_db

__all__ = ["engine", "Base", "get_db"]

