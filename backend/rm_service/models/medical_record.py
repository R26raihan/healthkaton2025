"""
Medical Record Model
"""
from sqlalchemy import Column, String, Integer, DateTime, Text, Enum
from sqlalchemy.sql import func
import uuid
from ..core.database import Base
import enum

class VisitType(enum.Enum):
    OUTPATIENT = "outpatient"
    INPATIENT = "inpatient"
    EMERGENCY = "emergency"

class MedicalRecord(Base):
    """Medical Record header model"""
    __tablename__ = "medical_records"
    
    record_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(Integer, nullable=False, index=True)  # FK to users.id
    visit_date = Column(DateTime, nullable=False, index=True)
    # Use native_enum=False to handle MySQL enum properly
    visit_type = Column(Enum(VisitType, native_enum=False, length=20), nullable=False, index=True)
    diagnosis_summary = Column(Text)
    notes = Column(Text)
    doctor_name = Column(String(255))
    facility_name = Column(String(255))
    created_at = Column(DateTime, server_default=func.now())
    
    def __init__(self, **kwargs):
        # Handle visit_type conversion if it's a string
        if 'visit_type' in kwargs and isinstance(kwargs['visit_type'], str):
            try:
                # Try to find matching enum by value
                for enum_item in VisitType:
                    if enum_item.value == kwargs['visit_type'].lower():
                        kwargs['visit_type'] = enum_item
                        break
            except:
                pass
        super().__init__(**kwargs)

