"""
Health Calculator API routes
"""
from .calculator import router as calculator_router
from .metrics import router as metrics_router

__all__ = ["calculator_router", "metrics_router"]

