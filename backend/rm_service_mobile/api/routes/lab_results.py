"""
Lab Results API Routes (Mobile - Read Only for Users)
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

from rm_service.schemas.lab_result import LabResultResponse
from rm_service.services.crud import (
    get_lab_result_by_id,
    get_record_lab_results,
    get_medical_record,
)

router = APIRouter(prefix="/lab-results", tags=["Lab Results (Mobile)"])

@router.get("/record/{record_id}", response_model=List[LabResultResponse])
async def get_record_lab_results_route(
    record_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get all lab results for a medical record
    **Requires user authentication** - User can only view lab results for their own records
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
    
    lab_results = get_record_lab_results(db, record_id)
    return [LabResultResponse.model_validate(l) for l in lab_results]

@router.get("/{lab_id}", response_model=LabResultResponse)
async def get_lab_result_route(
    lab_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get lab result by ID
    **Requires user authentication** - User can only view lab results for their own records
    """
    lab_result = get_lab_result_by_id(db, lab_id)
    if not lab_result:
        raise HTTPException(status_code=404, detail="Lab result not found")
    
    # Verify that the medical record belongs to current user
    record = get_medical_record(db, lab_result.record_id)
    if not record or record.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this lab result"
        )
    
    return LabResultResponse.model_validate(lab_result)

