"""
Allergy Schemas
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from enum import Enum

class AllergySeverityEnum(str, Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"

class AllergyCreate(BaseModel):
    """Schema for creating allergy"""
    patient_id: int  # FK to users.id
    allergy_name: str
    severity: AllergySeverityEnum = AllergySeverityEnum.MODERATE
    notes: Optional[str] = None

class AllergyResponse(BaseModel):
    """Schema for allergy response"""
    allergy_id: str
    patient_id: int  # FK to users.id
    allergy_name: str
    severity: str
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

