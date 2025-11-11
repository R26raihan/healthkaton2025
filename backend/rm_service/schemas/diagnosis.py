"""
Diagnosis Schemas
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class DiagnosisCreate(BaseModel):
    """Schema for creating diagnosis"""
    record_id: str
    icd_code: Optional[str] = None
    diagnosis_name: str
    primary_flag: bool = False

class DiagnosisResponse(BaseModel):
    """Schema for diagnosis response"""
    diagnosis_id: str
    record_id: str
    icd_code: Optional[str] = None
    diagnosis_name: str
    primary_flag: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

