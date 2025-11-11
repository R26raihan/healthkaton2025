"""
CRUD operations for Health Calculator Service
"""
from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List, Optional, Dict, Any
from datetime import datetime
import json

from ..models.health_calculation import HealthCalculation
from ..models.health_metric import HealthMetric

# ============================================
# Health Calculations CRUD
# ============================================

def save_health_calculation(
    db: Session,
    user_id: int,
    calculation_type: str,
    input_data: Dict[str, Any],
    result_data: Dict[str, Any]
) -> HealthCalculation:
    """Save health calculation result to database"""
    calculation = HealthCalculation(
        user_id=user_id,
        calculation_type=calculation_type,
        input_data=input_data,
        result_data=result_data
    )
    db.add(calculation)
    db.commit()
    db.refresh(calculation)
    return calculation

def get_user_calculations(
    db: Session,
    user_id: int,
    calculation_type: Optional[str] = None,
    limit: int = 50,
    offset: int = 0
) -> List[HealthCalculation]:
    """Get user's health calculations"""
    query = db.query(HealthCalculation).filter(HealthCalculation.user_id == user_id)
    
    if calculation_type:
        query = query.filter(HealthCalculation.calculation_type == calculation_type)
    
    query = query.order_by(desc(HealthCalculation.calculated_at))
    query = query.offset(offset).limit(limit)
    
    return query.all()

def get_calculation_by_id(db: Session, calculation_id: int, user_id: int) -> Optional[HealthCalculation]:
    """Get specific calculation by ID"""
    return db.query(HealthCalculation).filter(
        HealthCalculation.id == calculation_id,
        HealthCalculation.user_id == user_id
    ).first()

def get_latest_calculation(
    db: Session,
    user_id: int,
    calculation_type: str
) -> Optional[HealthCalculation]:
    """Get latest calculation of specific type for user"""
    return db.query(HealthCalculation).filter(
        HealthCalculation.user_id == user_id,
        HealthCalculation.calculation_type == calculation_type
    ).order_by(desc(HealthCalculation.calculated_at)).first()

# ============================================
# Health Metrics CRUD
# ============================================

def save_health_metric(
    db: Session,
    user_id: int,
    metric_type: str,
    metric_value: float,
    unit: str,
    notes: Optional[str] = None
) -> HealthMetric:
    """Save health metric to database"""
    metric = HealthMetric(
        user_id=user_id,
        metric_type=metric_type,
        metric_value=metric_value,
        unit=unit,
        notes=notes
    )
    db.add(metric)
    db.commit()
    db.refresh(metric)
    return metric

def get_user_metrics(
    db: Session,
    user_id: int,
    metric_type: Optional[str] = None,
    limit: int = 100,
    offset: int = 0
) -> List[HealthMetric]:
    """Get user's health metrics"""
    query = db.query(HealthMetric).filter(HealthMetric.user_id == user_id)
    
    if metric_type:
        query = query.filter(HealthMetric.metric_type == metric_type)
    
    query = query.order_by(desc(HealthMetric.recorded_at))
    query = query.offset(offset).limit(limit)
    
    return query.all()

def get_metric_by_id(db: Session, metric_id: int, user_id: int) -> Optional[HealthMetric]:
    """Get specific metric by ID"""
    return db.query(HealthMetric).filter(
        HealthMetric.id == metric_id,
        HealthMetric.user_id == user_id
    ).first()

def get_latest_metric(
    db: Session,
    user_id: int,
    metric_type: str
) -> Optional[HealthMetric]:
    """Get latest metric of specific type for user"""
    return db.query(HealthMetric).filter(
        HealthMetric.user_id == user_id,
        HealthMetric.metric_type == metric_type
    ).order_by(desc(HealthMetric.recorded_at)).first()

def get_metrics_statistics(
    db: Session,
    user_id: int,
    metric_type: str,
    days: int = 30
) -> Dict[str, Any]:
    """Get statistics for a metric type over a period"""
    from sqlalchemy import func
    from datetime import timedelta
    
    cutoff_date = datetime.now() - timedelta(days=days)
    
    metrics = db.query(HealthMetric).filter(
        HealthMetric.user_id == user_id,
        HealthMetric.metric_type == metric_type,
        HealthMetric.recorded_at >= cutoff_date
    ).all()
    
    if not metrics:
        return {
            "metric_type": metric_type,
            "count": 0,
            "average": None,
            "min": None,
            "max": None,
            "latest": None
        }
    
    values = [float(m.metric_value) for m in metrics]
    
    return {
        "metric_type": metric_type,
        "count": len(values),
        "average": round(sum(values) / len(values), 2),
        "min": round(min(values), 2),
        "max": round(max(values), 2),
        "latest": float(metrics[0].metric_value),
        "unit": metrics[0].unit,
        "period_days": days
    }

