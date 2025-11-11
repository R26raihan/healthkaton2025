"""
Medical Records API Routes (Mobile - Read Only for Users)
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

from rm_service.schemas.medical_record import MedicalRecordResponse, MedicalRecordFull
from rm_service.services.crud import (
    get_medical_record,
    get_patient_records,
    get_record_diagnoses,
    get_record_prescriptions,
    get_record_lab_results,
)

router = APIRouter(prefix="/medical-records", tags=["Medical Records (Mobile)"])

@router.get("/my-records", response_model=List[MedicalRecordResponse])
async def get_my_records(
    current_user = Depends(get_current_active_user_for_rm_mobile),
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Get my medical records (current logged in user)
    **Requires user authentication** - User can only view their own records
    """
    return get_patient_records(db, current_user.id, skip, limit)

@router.get("/{record_id}", response_model=MedicalRecordFull)
async def get_record(
    record_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get medical record by ID with all related data
    **Requires user authentication** - User can only view their own records
    """
    from rm_service.schemas.diagnosis import DiagnosisResponse
    from rm_service.schemas.prescription import PrescriptionResponse
    from rm_service.schemas.lab_result import LabResultResponse
    
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    # Verify that the record belongs to current user
    if record.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this record"
        )
    
    # Get related data
    diagnoses = [DiagnosisResponse.model_validate(d) for d in get_record_diagnoses(db, record_id)]
    prescriptions = [PrescriptionResponse.model_validate(p) for p in get_record_prescriptions(db, record_id)]
    lab_results = [LabResultResponse.model_validate(l) for l in get_record_lab_results(db, record_id)]
    
    record_dict = MedicalRecordResponse.model_validate(record).model_dump()
    record_dict["diagnoses"] = [d.model_dump() for d in diagnoses]
    record_dict["prescriptions"] = [p.model_dump() for p in prescriptions]
    record_dict["lab_results"] = [l.model_dump() for l in lab_results]
    
    return record_dict

