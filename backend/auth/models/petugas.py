"""
Petugas (Staff/Officer) Model for Backoffice
"""
from sqlalchemy import Column, Integer, String, Boolean, TIMESTAMP, Enum
from sqlalchemy.sql import func
from ..core.database import Base
import enum

class PetugasRole(enum.Enum):
    """Role untuk petugas backoffice - values must match database enum (UPPERCASE)"""
    ADMIN = "ADMIN"  # Full access
    DOKTER = "DOKTER"  # Dokter - bisa create/update medical records
    PERAWAT = "PERAWAT"  # Perawat - bisa create/update medical records
    ADMINISTRATOR = "ADMINISTRATOR"  # Administrator - bisa manage data
    STAFF = "STAFF"  # Staff umum - read only atau limited access

class Petugas(Base):
    """Petugas model - Staff/Officer untuk backoffice"""
    __tablename__ = "petugas"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password = Column(String(255), nullable=False)  # Hashed password
    phoneNumber = Column(String(20))
    nip = Column(String(50), unique=True, index=True)  # Nomor Induk Pegawai
    role = Column(Enum(PetugasRole, native_enum=False, length=20), default=PetugasRole.STAFF, nullable=False, index=True)
    specialization = Column(String(255))  # Spesialisasi (untuk dokter)
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

