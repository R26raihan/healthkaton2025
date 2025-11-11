"""
Lab Result Schemas
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class LabResultCreate(BaseModel):
    """Schema for creating lab result"""
    record_id: str
    test_name: str
    result_value: Optional[str] = None
    result_unit: Optional[str] = None
    normal_range: Optional[str] = None
    interpretation: Optional[str] = None
    attachment_url: Optional[str] = None

class LabResultResponse(BaseModel):
    """Schema for lab result response"""
    lab_id: str
    record_id: str
    test_name: str
    result_value: Optional[str] = None
    result_unit: Optional[str] = None
    normal_range: Optional[str] = None
    interpretation: Optional[str] = None
    attachment_url: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

