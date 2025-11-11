"""
Diagnoses API Routes (Mobile - Read Only for Users)
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...core.database import get_db
from ...core.dependencies import get_current_active_user_for_rm_mobile
import sys
import os

# Add parent directory to import from rm_service
_parent_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.append(_parent_dir)

from rm_service.schemas.diagnosis import DiagnosisResponse
from rm_service.services.crud import (
    get_diagnosis_by_id,
    get_record_diagnoses,
    get_medical_record,
)

router = APIRouter(prefix="/diagnoses", tags=["Diagnoses (Mobile)"])

@router.get("/record/{record_id}", response_model=List[DiagnosisResponse])
async def get_record_diagnoses_route(
    record_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get all diagnoses for a medical record
    **Requires user authentication** - User can only view diagnoses for their own records
    """
    # Verify that the medical record exists and belongs to current user
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    if record.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this record"
        )
    
    diagnoses = get_record_diagnoses(db, record_id)
    return [DiagnosisResponse.model_validate(d) for d in diagnoses]

@router.get("/{diagnosis_id}", response_model=DiagnosisResponse)
async def get_diagnosis_route(
    diagnosis_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get diagnosis by ID
    **Requires user authentication** - User can only view diagnoses for their own records
    """
    diagnosis = get_diagnosis_by_id(db, diagnosis_id)
    if not diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")
    
    # Verify that the medical record belongs to current user
    record = get_medical_record(db, diagnosis.record_id)
    if not record or record.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this diagnosis"
        )
    
    return DiagnosisResponse.model_validate(diagnosis)

