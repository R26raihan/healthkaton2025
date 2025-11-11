"""
Diagnosis Model
"""
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
import uuid
from ..core.database import Base

class Diagnosis(Base):
    """Diagnosis model - Multiple diagnoses per medical record"""
    __tablename__ = "diagnoses"
    
    diagnosis_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    record_id = Column(String(36), ForeignKey("medical_records.record_id", ondelete="CASCADE"), nullable=False, index=True)
    icd_code = Column(String(20), index=True)
    diagnosis_name = Column(String(255), nullable=False)
    primary_flag = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())

