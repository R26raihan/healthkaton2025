"""
Main FastAPI application for RAG Service Mobile
"""
from fastapi import FastAPI
from .api.routes import rag
from .core.config import SERVICE_NAME, SERVICE_VERSION

app = FastAPI(
    title=SERVICE_NAME,
    version=SERVICE_VERSION,
    description="RAG Service Mobile - User-friendly Medical Records Q&A for Mobile App"
)

# Include routers
app.include_router(rag.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "status": "ready"
    }

