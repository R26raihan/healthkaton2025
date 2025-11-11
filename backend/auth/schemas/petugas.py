"""
Petugas (Staff/Officer) Schemas
"""
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional
from enum import Enum

class PetugasRoleEnum(str, Enum):
    """Role untuk petugas - values match database enum (UPPERCASE)"""
    ADMIN = "ADMIN"
    DOKTER = "DOKTER"
    PERAWAT = "PERAWAT"
    ADMINISTRATOR = "ADMINISTRATOR"
    STAFF = "STAFF"

class PetugasCreate(BaseModel):
    """Schema for creating petugas"""
    name: str
    email: EmailStr
    password: str
    phoneNumber: Optional[str] = None
    nip: Optional[str] = None  # Nomor Induk Pegawai
    role: PetugasRoleEnum = PetugasRoleEnum.STAFF
    specialization: Optional[str] = None  # Spesialisasi (untuk dokter)

class PetugasUpdate(BaseModel):
    """Schema for updating petugas"""
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    phoneNumber: Optional[str] = None
    nip: Optional[str] = None
    role: Optional[PetugasRoleEnum] = None
    specialization: Optional[str] = None
    is_active: Optional[bool] = None

class PetugasResponse(BaseModel):
    """Schema for petugas response"""
    id: int
    name: str
    email: str
    phoneNumber: Optional[str] = None
    nip: Optional[str] = None
    role: str
    specialization: Optional[str] = None
    is_active: bool
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class PetugasLoginRequest(BaseModel):
    """Schema for petugas login"""
    email: EmailStr
    password: str

