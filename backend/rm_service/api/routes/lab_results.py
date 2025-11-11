"""
Lab Results API Routes
"""
import uuid
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.lab_result import LabResultCreate, LabResultResponse
from ...services.crud import (
    create_lab_result,
    get_lab_result_by_id,
    get_record_lab_results,
    update_lab_result,
    delete_lab_result,
    get_medical_record,
)

router = APIRouter(prefix="/lab-results", tags=["Lab Results"])

# Lab Results Routes
@router.post("/", response_model=LabResultResponse, status_code=status.HTTP_201_CREATED)
async def create_lab_result_route(
    lab_result: LabResultCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Create a new lab result (Backoffice - Petugas only)"""
    # Verify that the medical record exists
    record = get_medical_record(db, lab_result.record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    lab_data = lab_result.model_dump()
    lab_data["lab_id"] = str(uuid.uuid4())
    return create_lab_result(db, lab_data)

@router.get("/record/{record_id}", response_model=List[LabResultResponse])
async def get_record_lab_results_route(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all lab results for a medical record (Backoffice - Petugas only)"""
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    lab_results = get_record_lab_results(db, record_id)
    return [LabResultResponse.model_validate(l) for l in lab_results]

@router.get("/{lab_id}", response_model=LabResultResponse)
async def get_lab_result_route(
    lab_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get lab result by ID (Backoffice - Petugas only)"""
    lab_result = get_lab_result_by_id(db, lab_id)
    if not lab_result:
        raise HTTPException(status_code=404, detail="Lab result not found")
    
    return LabResultResponse.model_validate(lab_result)

@router.put("/{lab_id}", response_model=LabResultResponse)
async def update_lab_result_route(
    lab_id: str,
    lab_result: LabResultCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Update a lab result (Backoffice - Petugas only)"""
    existing_lab_result = get_lab_result_by_id(db, lab_id)
    if not existing_lab_result:
        raise HTTPException(status_code=404, detail="Lab result not found")
    
    lab_data = lab_result.model_dump()
    updated_lab_result = update_lab_result(db, lab_id, lab_data)
    if not updated_lab_result:
        raise HTTPException(status_code=404, detail="Lab result not found")
    return LabResultResponse.model_validate(updated_lab_result)

@router.delete("/{lab_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_lab_result_route(
    lab_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Delete a lab result (Backoffice - Petugas only)"""
    existing_lab_result = get_lab_result_by_id(db, lab_id)
    if not existing_lab_result:
        raise HTTPException(status_code=404, detail="Lab result not found")
    
    success = delete_lab_result(db, lab_id)
    if not success:
        raise HTTPException(status_code=404, detail="Lab result not found")
    return None

