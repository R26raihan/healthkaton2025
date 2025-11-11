"""
Medical Document Model
"""
from sqlalchemy import Column, String, Integer, Text, DateTime, Enum
from sqlalchemy.sql import func
import uuid
import enum
from ..core.database import Base

class FileType(enum.Enum):
    PDF = "pdf"
    IMAGE = "image"

class MedicalDocument(Base):
    """Medical Document model - File uploads (PDF/Image)"""
    __tablename__ = "medical_documents"
    
    doc_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(Integer, nullable=False, index=True)  # FK to users.id
    record_id = Column(String(36), index=True)  # Optional FK to medical_records
    file_type = Column(Enum(FileType, native_enum=False, length=20), nullable=False, index=True)
    file_url = Column(Text, nullable=False)
    extract_text = Column(Text)  # OCR result for RAG
    created_at = Column(DateTime, server_default=func.now())

