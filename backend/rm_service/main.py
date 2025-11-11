"""
Main FastAPI application for Medical Records Service
"""
from fastapi import FastAPI
from .api.routes import (
    medical_records, 
    relations, 
    allergies, 
    diagnoses, 
    prescriptions, 
    lab_results, 
    medical_documents,
    patients
)
from .core.config import SERVICE_NAME, SERVICE_VERSION

app = FastAPI(title=SERVICE_NAME, version=SERVICE_VERSION)

# Include routers
app.include_router(medical_records.router)
app.include_router(relations.router)
app.include_router(allergies.router)
app.include_router(diagnoses.router)
app.include_router(prescriptions.router)
app.include_router(lab_results.router)
app.include_router(medical_documents.router)
app.include_router(patients.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": SERVICE_NAME,
        "version": SERVICE_VERSION
    }

