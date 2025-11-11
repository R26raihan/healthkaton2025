"""
Prescription Model
"""
from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
import uuid
from ..core.database import Base

class Prescription(Base):
    """Prescription model - Medication prescriptions"""
    __tablename__ = "prescriptions"
    
    prescription_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    record_id = Column(String(36), ForeignKey("medical_records.record_id", ondelete="CASCADE"), nullable=False, index=True)
    drug_name = Column(String(255), nullable=False, index=True)
    drug_code = Column(String(50))
    dosage = Column(String(100))
    frequency = Column(String(100))  # Contoh: 3x sehari
    duration_days = Column(Integer)
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())

