"""
Allergies API Routes
"""
import uuid
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.allergy import AllergyCreate, AllergyResponse, AllergySeverityEnum
from ...services.crud import (
    create_allergy,
    get_allergy_by_id,
    get_patient_allergies,
    update_allergy,
    delete_allergy,
)

router = APIRouter(prefix="/allergies", tags=["Allergies"])

# Allergies Routes
@router.post("/", response_model=AllergyResponse, status_code=status.HTTP_201_CREATED)
async def create_allergy_route(
    allergy: AllergyCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Create a new allergy for a patient (Backoffice - Petugas only)"""
    allergy_data = allergy.model_dump()
    allergy_data["allergy_id"] = str(uuid.uuid4())
    # patient_id harus diisi di request body
    if "patient_id" not in allergy_data or not allergy_data["patient_id"]:
        raise HTTPException(status_code=400, detail="patient_id is required")
    return create_allergy(db, allergy_data)

@router.get("/patient/{patient_id}", response_model=List[AllergyResponse])
async def get_patient_allergies_route(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all allergies for a patient by ID (Backoffice - Petugas only)"""
    return get_patient_allergies(db, patient_id)

@router.get("/{allergy_id}", response_model=AllergyResponse)
async def get_allergy_route(
    allergy_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get allergy by ID (Backoffice - Petugas only)"""
    allergy = get_allergy_by_id(db, allergy_id)
    if not allergy:
        raise HTTPException(status_code=404, detail="Allergy not found")
    return AllergyResponse.model_validate(allergy)

@router.put("/{allergy_id}", response_model=AllergyResponse)
async def update_allergy_route(
    allergy_id: str,
    allergy: AllergyCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Update an allergy (Backoffice - Petugas only)"""
    existing_allergy = get_allergy_by_id(db, allergy_id)
    if not existing_allergy:
        raise HTTPException(status_code=404, detail="Allergy not found")
    
    allergy_data = allergy.model_dump()
    updated_allergy = update_allergy(db, allergy_id, allergy_data)
    if not updated_allergy:
        raise HTTPException(status_code=404, detail="Allergy not found")
    return AllergyResponse.model_validate(updated_allergy)

@router.delete("/{allergy_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_allergy_route(
    allergy_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Delete an allergy (Backoffice - Petugas only)"""
    existing_allergy = get_allergy_by_id(db, allergy_id)
    if not existing_allergy:
        raise HTTPException(status_code=404, detail="Allergy not found")
    
    success = delete_allergy(db, allergy_id)
    if not success:
        raise HTTPException(status_code=404, detail="Allergy not found")
    return None

