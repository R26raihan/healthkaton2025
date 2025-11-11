"""
Patient Detail Schemas
"""
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List
from .medical_record import MedicalRecordFull
from .allergy import AllergyResponse
from .medical_document import MedicalDocumentResponse

class PatientInfo(BaseModel):
    """Basic patient information"""
    id: int
    name: str
    email: str
    phoneNumber: Optional[str] = None
    ktpNumber: Optional[str] = None
    kkNumber: Optional[str] = None
    is_active: bool
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class PatientUpdate(BaseModel):
    """Schema for updating patient information"""
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phoneNumber: Optional[str] = None
    ktpNumber: Optional[str] = None
    kkNumber: Optional[str] = None
    is_active: Optional[bool] = None
    
    class Config:
        from_attributes = True

class PatientDetailResponse(BaseModel):
    """Complete patient detail with all medical data"""
    patient_info: PatientInfo
    medical_records: List[MedicalRecordFull]
    allergies: List[AllergyResponse]
    medical_documents: List[MedicalDocumentResponse]
    summary: dict
    
    class Config:
        from_attributes = True

class PatientListResponse(BaseModel):
    """Response for patient list with pagination"""
    patients: List[PatientInfo]
    total: int
    skip: int
    limit: int
    
    class Config:
        from_attributes = True

