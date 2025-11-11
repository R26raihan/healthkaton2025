"""
Main FastAPI application for RAG Service
"""
from fastapi import FastAPI
from .api.routes import rag
from .core.config import SERVICE_NAME, SERVICE_VERSION

app = FastAPI(
    title=SERVICE_NAME,
    version=SERVICE_VERSION,
    description="RAG Service for Admin/Doctor/Staff (Petugas Only) - Medical Records Q&A"
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

