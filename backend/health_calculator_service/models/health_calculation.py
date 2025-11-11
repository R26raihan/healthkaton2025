"""
Health Calculation Model
"""
from sqlalchemy import Column, Integer, String, JSON, TIMESTAMP, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base

class HealthCalculation(Base):
    __tablename__ = "health_calculations"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    calculation_type = Column(String(50), nullable=False, index=True, comment="BMI, BMR, TDEE, BodyFat, etc")
    input_data = Column(JSON, nullable=False, comment="Input data for calculation")
    result_data = Column(JSON, nullable=False, comment="Calculation results and details")
    calculated_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationship (optional, if needed)
    # user = relationship("User", back_populates="health_calculations")

