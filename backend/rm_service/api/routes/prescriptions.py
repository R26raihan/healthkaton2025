"""
Prescriptions API Routes
"""
import uuid
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.prescription import PrescriptionCreate, PrescriptionResponse
from ...services.crud import (
    create_prescription,
    get_prescription_by_id,
    get_record_prescriptions,
    update_prescription,
    delete_prescription,
    get_medical_record,
)

router = APIRouter(prefix="/prescriptions", tags=["Prescriptions"])

# Prescriptions Routes
@router.post("/", response_model=PrescriptionResponse, status_code=status.HTTP_201_CREATED)
async def create_prescription_route(
    prescription: PrescriptionCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Create a new prescription (Backoffice - Petugas only)"""
    # Verify that the medical record exists
    record = get_medical_record(db, prescription.record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    prescription_data = prescription.model_dump()
    prescription_data["prescription_id"] = str(uuid.uuid4())
    return create_prescription(db, prescription_data)

@router.get("/record/{record_id}", response_model=List[PrescriptionResponse])
async def get_record_prescriptions_route(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all prescriptions for a medical record (Backoffice - Petugas only)"""
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    prescriptions = get_record_prescriptions(db, record_id)
    return [PrescriptionResponse.model_validate(p) for p in prescriptions]

@router.get("/{prescription_id}", response_model=PrescriptionResponse)
async def get_prescription_route(
    prescription_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get prescription by ID (Backoffice - Petugas only)"""
    prescription = get_prescription_by_id(db, prescription_id)
    if not prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    return PrescriptionResponse.model_validate(prescription)

@router.put("/{prescription_id}", response_model=PrescriptionResponse)
async def update_prescription_route(
    prescription_id: str,
    prescription: PrescriptionCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Update a prescription (Backoffice - Petugas only)"""
    existing_prescription = get_prescription_by_id(db, prescription_id)
    if not existing_prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    prescription_data = prescription.model_dump()
    updated_prescription = update_prescription(db, prescription_id, prescription_data)
    if not updated_prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    return PrescriptionResponse.model_validate(updated_prescription)

@router.delete("/{prescription_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_prescription_route(
    prescription_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Delete a prescription (Backoffice - Petugas only)"""
    existing_prescription = get_prescription_by_id(db, prescription_id)
    if not existing_prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    success = delete_prescription(db, prescription_id)
    if not success:
        raise HTTPException(status_code=404, detail="Prescription not found")
    return None

