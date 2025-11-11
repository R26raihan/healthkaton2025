"""
Medical Document Schemas
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from enum import Enum

class FileTypeEnum(str, Enum):
    PDF = "pdf"
    IMAGE = "image"

class MedicalDocumentCreate(BaseModel):
    """Schema for creating medical document"""
    patient_id: int  # FK to users.id
    record_id: Optional[str] = None
    file_type: FileTypeEnum
    file_url: str
    extract_text: Optional[str] = None

class MedicalDocumentResponse(BaseModel):
    """Schema for medical document response"""
    doc_id: str
    patient_id: int  # FK to users.id
    record_id: Optional[str] = None
    file_type: str
    file_url: str
    extract_text: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

