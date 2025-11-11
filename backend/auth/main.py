"""
Main FastAPI application
"""
from fastapi import FastAPI
from .api.routes import auth, health, petugas

app = FastAPI(title="Authentication Service", version="1.0.0")

# Include routers
app.include_router(auth.router)
app.include_router(health.router)
app.include_router(petugas.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Authentication Service", "version": "1.0.0"}

