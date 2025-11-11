"""
Diagnoses API Routes
"""
import uuid
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.diagnosis import DiagnosisCreate, DiagnosisResponse
from ...services.crud import (
    create_diagnosis,
    get_diagnosis_by_id,
    get_record_diagnoses,
    update_diagnosis,
    delete_diagnosis,
    get_medical_record,
)

router = APIRouter(prefix="/diagnoses", tags=["Diagnoses"])

# Diagnoses Routes
@router.post("/", response_model=DiagnosisResponse, status_code=status.HTTP_201_CREATED)
async def create_diagnosis_route(
    diagnosis: DiagnosisCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Create a new diagnosis (Backoffice - Petugas only)"""
    # Verify that the medical record exists
    record = get_medical_record(db, diagnosis.record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    diagnosis_data = diagnosis.model_dump()
    diagnosis_data["diagnosis_id"] = str(uuid.uuid4())
    return create_diagnosis(db, diagnosis_data)

@router.get("/record/{record_id}", response_model=List[DiagnosisResponse])
async def get_record_diagnoses_route(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all diagnoses for a medical record (Backoffice - Petugas only)"""
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    diagnoses = get_record_diagnoses(db, record_id)
    return [DiagnosisResponse.model_validate(d) for d in diagnoses]

@router.get("/{diagnosis_id}", response_model=DiagnosisResponse)
async def get_diagnosis_route(
    diagnosis_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get diagnosis by ID (Backoffice - Petugas only)"""
    diagnosis = get_diagnosis_by_id(db, diagnosis_id)
    if not diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")
    
    return DiagnosisResponse.model_validate(diagnosis)

@router.put("/{diagnosis_id}", response_model=DiagnosisResponse)
async def update_diagnosis_route(
    diagnosis_id: str,
    diagnosis: DiagnosisCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Update a diagnosis (Backoffice - Petugas only)"""
    existing_diagnosis = get_diagnosis_by_id(db, diagnosis_id)
    if not existing_diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")
    
    diagnosis_data = diagnosis.model_dump()
    updated_diagnosis = update_diagnosis(db, diagnosis_id, diagnosis_data)
    if not updated_diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")
    return DiagnosisResponse.model_validate(updated_diagnosis)

@router.delete("/{diagnosis_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_diagnosis_route(
    diagnosis_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Delete a diagnosis (Backoffice - Petugas only)"""
    existing_diagnosis = get_diagnosis_by_id(db, diagnosis_id)
    if not existing_diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")
    
    success = delete_diagnosis(db, diagnosis_id)
    if not success:
        raise HTTPException(status_code=404, detail="Diagnosis not found")
    return None

