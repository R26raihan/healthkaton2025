"""
Petugas (Staff/Officer) routes for backoffice
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import List
from ...core.database import get_db
from ...models.petugas import Petugas
from ...schemas.petugas import (
    PetugasCreate, 
    PetugasUpdate, 
    PetugasResponse, 
    PetugasLoginRequest
)
from ...core.dependencies import get_current_active_user, get_current_active_petugas
from ...services.crud import (
    authenticate_petugas,
    create_petugas,
    get_petugas_by_id,
    get_all_petugas,
    update_petugas,
    delete_petugas,
    check_petugas_exists
)
from ...services.security import create_access_token
from ...core.config import ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(prefix="/petugas", tags=["Petugas (Backoffice)"])

@router.post("/register", response_model=PetugasResponse, status_code=status.HTTP_201_CREATED)
async def register_petugas(
    petugas: PetugasCreate,
    db: Session = Depends(get_db)
):
    """
    Register a new petugas (Staff/Officer)
    
    **Note:** For initial setup, this endpoint is public. 
    After first admin is created, you should restrict this to admin-only.
    """
    # TODO: Add admin check after first admin is created
    # For now, allow public registration for initial setup
    
    # Check if petugas already exists
    exists, message = check_petugas_exists(db, petugas.email, petugas.nip)
    if exists:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    # Create new petugas
    # Convert role enum to string (value is UPPERCASE)
    role_value = petugas.role.value if hasattr(petugas.role, 'value') else str(petugas.role)
    petugas_data = {
        "name": petugas.name,
        "email": petugas.email,
        "password": petugas.password,
        "phoneNumber": petugas.phoneNumber,
        "nip": petugas.nip,
        "role": role_value,  # Will be converted to enum in create_petugas
        "specialization": petugas.specialization
    }
    db_petugas = create_petugas(db, petugas_data)
    return PetugasResponse.model_validate(db_petugas)

@router.post("/login", response_model=dict)
async def login_petugas(
    login_data: PetugasLoginRequest,
    db: Session = Depends(get_db)
):
    """
    Login petugas and get JWT token
    
    **Note:** This is separate from user login - petugas use different credentials
    """
    petugas = authenticate_petugas(db, login_data.email, login_data.password)
    if not petugas:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not petugas.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Petugas account is inactive"
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": petugas.email, "type": "petugas"}, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "petugas": PetugasResponse.model_validate(petugas)
    }

@router.get("/me", response_model=PetugasResponse)
async def get_current_petugas_me(
    current_petugas: Petugas = Depends(get_current_active_petugas)
):
    """Get current petugas information"""
    return PetugasResponse.model_validate(current_petugas)

@router.get("/", response_model=List[PetugasResponse])
async def get_all_petugas_list(
    skip: int = 0,
    limit: int = 100,
    current_petugas: Petugas = Depends(get_current_active_petugas),
    db: Session = Depends(get_db)
):
    """Get all petugas - Only admin can access"""
    # Check if current petugas is admin
    if not hasattr(current_petugas, 'role') or current_petugas.role.value != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admin can view all petugas"
        )
    
    petugas_list = get_all_petugas(db, skip, limit)
    return [PetugasResponse.model_validate(p) for p in petugas_list]

@router.get("/{petugas_id}", response_model=PetugasResponse)
async def get_petugas(
    petugas_id: int,
    current_petugas: Petugas = Depends(get_current_active_petugas),
    db: Session = Depends(get_db)
):
    """Get petugas by ID"""
    # Admin can view any petugas, others can only view themselves
    if hasattr(current_petugas, 'role') and current_petugas.role.value == "ADMIN":
        petugas = get_petugas_by_id(db, petugas_id)
    else:
        # Non-admin can only view themselves
        if current_petugas.id != petugas_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view this petugas"
            )
        petugas = current_petugas
    
    if not petugas:
        raise HTTPException(status_code=404, detail="Petugas not found")
    
    return PetugasResponse.model_validate(petugas)

@router.put("/{petugas_id}", response_model=PetugasResponse)
async def update_petugas_route(
    petugas_id: int,
    petugas_update: PetugasUpdate,
    current_petugas: Petugas = Depends(get_current_active_petugas),
    db: Session = Depends(get_db)
):
    """Update petugas"""
    # Admin can update any petugas, others can only update themselves
    if hasattr(current_petugas, 'role') and current_petugas.role.value == "ADMIN":
        # Admin can update anyone
        pass
    else:
        # Non-admin can only update themselves
        if current_petugas.id != petugas_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to update this petugas"
            )
        # Non-admin cannot change role
        if petugas_update.role is not None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to change role"
            )
    
    petugas_data = petugas_update.model_dump(exclude_unset=True)
    # Role will be converted to enum in update_petugas function
    
    updated_petugas = update_petugas(db, petugas_id, petugas_data)
    if not updated_petugas:
        raise HTTPException(status_code=404, detail="Petugas not found")
    
    return PetugasResponse.model_validate(updated_petugas)

@router.delete("/{petugas_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_petugas_route(
    petugas_id: int,
    current_petugas: Petugas = Depends(get_current_active_petugas),
    db: Session = Depends(get_db)
):
    """Delete petugas - Only admin can delete"""
    # Only admin can delete
    if not hasattr(current_petugas, 'role') or current_petugas.role.value != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admin can delete petugas"
        )
    
    # Cannot delete yourself
    if current_petugas.id == petugas_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete yourself"
        )
    
    success = delete_petugas(db, petugas_id)
    if not success:
        raise HTTPException(status_code=404, detail="Petugas not found")
    return None

