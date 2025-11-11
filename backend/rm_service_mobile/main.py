"""
Main FastAPI application for RM Service Mobile (User - Read Only)
"""
from fastapi import FastAPI
from .api.routes import medical_records, allergies, diagnoses, prescriptions, lab_results, medical_documents, relations

app = FastAPI(
    title="RM Service Mobile",
    version="1.0.0",
    description="Mobile service for users to view their medical records (Read-only). Requires user authentication token."
)

# Include routers
app.include_router(medical_records.router)
app.include_router(allergies.router)
app.include_router(diagnoses.router)
app.include_router(prescriptions.router)
app.include_router(lab_results.router)
app.include_router(medical_documents.router)
app.include_router(relations.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "RM Service Mobile",
        "version": "1.0.0",
        "status": "ready",
        "description": "Read-only service for users to view their medical records"
    }

