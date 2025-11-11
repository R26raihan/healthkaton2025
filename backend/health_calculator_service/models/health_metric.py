"""
Health Metric History Model
"""
from sqlalchemy import Column, Integer, String, DECIMAL, TIMESTAMP, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base

class HealthMetric(Base):
    __tablename__ = "health_metrics_history"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    metric_type = Column(String(50), nullable=False, index=True, comment="BMI, Weight, BodyFat, HeartRate, etc")
    metric_value = Column(DECIMAL(10, 2), nullable=False)
    unit = Column(String(20), nullable=False, comment="kg, cm, bpm, %, etc")
    recorded_at = Column(TIMESTAMP, server_default=func.now(), nullable=False, index=True)
    notes = Column(Text, nullable=True)
    
    # Relationship (optional, if needed)
    # user = relationship("User", back_populates="health_metrics")

