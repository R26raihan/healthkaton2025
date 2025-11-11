"""
Prescription Schemas
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class PrescriptionCreate(BaseModel):
    """Schema for creating prescription"""
    record_id: str
    drug_name: str
    drug_code: Optional[str] = None
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    duration_days: Optional[int] = None
    notes: Optional[str] = None

class PrescriptionResponse(BaseModel):
    """Schema for prescription response"""
    prescription_id: str
    record_id: str
    drug_name: str
    drug_code: Optional[str] = None
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    duration_days: Optional[int] = None
    notes: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

