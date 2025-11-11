"""
Main FastAPI application entry point
Backward compatibility: Import app from main
"""
from .main import app

__all__ = ["app"]

