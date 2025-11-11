"""
Allergies API Routes (Mobile - Read Only for Users)
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

from rm_service.schemas.allergy import AllergyResponse
from rm_service.services.crud import (
    get_allergy_by_id,
    get_patient_allergies,
)

router = APIRouter(prefix="/allergies", tags=["Allergies (Mobile)"])

@router.get("/my-allergies", response_model=List[AllergyResponse])
async def get_my_allergies(
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get all allergies for current user
    **Requires user authentication** - User can only view their own allergies
    """
    return get_patient_allergies(db, current_user.id)

@router.get("/{allergy_id}", response_model=AllergyResponse)
async def get_allergy_route(
    allergy_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get allergy by ID
    **Requires user authentication** - User can only view their own allergies
    """
    allergy = get_allergy_by_id(db, allergy_id)
    if not allergy:
        raise HTTPException(status_code=404, detail="Allergy not found")
    
    # Verify that the allergy belongs to current user
    if allergy.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this allergy"
        )
    
    return AllergyResponse.model_validate(allergy)

