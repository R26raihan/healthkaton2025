"""
Medical Record Schemas
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List
from enum import Enum

class VisitTypeEnum(str, Enum):
    OUTPATIENT = "outpatient"
    INPATIENT = "inpatient"
    EMERGENCY = "emergency"

class MedicalRecordCreate(BaseModel):
    """Schema for creating medical record - for backoffice (petugas), patient_id must be provided"""
    patient_id: int  # Required for backoffice - petugas can create records for any patient
    visit_date: datetime
    visit_type: VisitTypeEnum
    diagnosis_summary: Optional[str] = None
    notes: Optional[str] = None
    doctor_name: Optional[str] = None
    facility_name: Optional[str] = None

class MedicalRecordResponse(BaseModel):
    """Schema for medical record response"""
    record_id: str
    patient_id: int  # FK to users.id
    visit_date: datetime
    visit_type: str
    diagnosis_summary: Optional[str] = None
    notes: Optional[str] = None
    doctor_name: Optional[str] = None
    facility_name: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

class MedicalRecordFull(MedicalRecordResponse):
    """Full medical record with related data"""
    diagnoses: Optional[List] = []
    prescriptions: Optional[List] = []
    lab_results: Optional[List] = []

