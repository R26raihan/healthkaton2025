"""
Main FastAPI application for Health Calculator Service
"""
from fastapi import FastAPI
from .api.routes import calculator_router, metrics_router
from .core.config import SERVICE_NAME, SERVICE_VERSION

app = FastAPI(
    title=SERVICE_NAME,
    version=SERVICE_VERSION,
    description="Health Calculator Service - Provides various health calculation tools and metrics tracking"
)

# Include routers
app.include_router(calculator_router)
app.include_router(metrics_router)

@app.get("/")
async def root():
    return {
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "status": "running",
        "endpoints": {
            "calculator": "/calculator",
            "metrics": "/metrics",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": SERVICE_NAME
    }

