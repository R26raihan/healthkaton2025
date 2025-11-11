"""
Lab Result Model
"""
from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
import uuid
from ..core.database import Base

class LabResult(Base):
    """Lab Result model - Laboratory test results"""
    __tablename__ = "lab_results"
    
    lab_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    record_id = Column(String(36), ForeignKey("medical_records.record_id", ondelete="CASCADE"), nullable=False, index=True)
    test_name = Column(String(255), nullable=False, index=True)  # Contoh: HbA1c
    result_value = Column(String(255))
    result_unit = Column(String(50))  # mg/dl, %, dll
    normal_range = Column(String(100))
    interpretation = Column(Text)
    attachment_url = Column(Text)
    created_at = Column(DateTime, server_default=func.now())

