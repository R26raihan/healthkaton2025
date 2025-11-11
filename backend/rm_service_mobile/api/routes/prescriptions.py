"""
Prescriptions API Routes (Mobile - Read Only for Users)
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

from rm_service.schemas.prescription import PrescriptionResponse
from rm_service.services.crud import (
    get_prescription_by_id,
    get_record_prescriptions,
    get_medical_record,
)

router = APIRouter(prefix="/prescriptions", tags=["Prescriptions (Mobile)"])

@router.get("/record/{record_id}", response_model=List[PrescriptionResponse])
async def get_record_prescriptions_route(
    record_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get all prescriptions for a medical record
    **Requires user authentication** - User can only view prescriptions for their own records
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
    
    prescriptions = get_record_prescriptions(db, record_id)
    return [PrescriptionResponse.model_validate(p) for p in prescriptions]

@router.get("/{prescription_id}", response_model=PrescriptionResponse)
async def get_prescription_route(
    prescription_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get prescription by ID
    **Requires user authentication** - User can only view prescriptions for their own records
    """
    prescription = get_prescription_by_id(db, prescription_id)
    if not prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    # Verify that the medical record belongs to current user
    record = get_medical_record(db, prescription.record_id)
    if not record or record.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this prescription"
        )
    
    return PrescriptionResponse.model_validate(prescription)

