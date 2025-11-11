"""
Allergy Model
"""
from sqlalchemy import Column, String, Integer, Text, DateTime, Enum
from sqlalchemy.sql import func
import uuid
import enum
from ..core.database import Base

class AllergySeverity(enum.Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"

class Allergy(Base):
    """Allergy model - Patient allergies"""
    __tablename__ = "allergies"
    
    allergy_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(Integer, nullable=False, index=True)  # FK to users.id
    allergy_name = Column(String(255), nullable=False, index=True)  # Contoh: Penicillin
    severity = Column(Enum(AllergySeverity, native_enum=False, length=20), default=AllergySeverity.MODERATE, index=True)
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

