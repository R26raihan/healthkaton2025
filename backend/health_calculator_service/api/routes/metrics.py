"""
Health Metrics API Routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...core.dependencies import get_current_active_user_for_calculator
from ...services.crud import (
    get_user_metrics,
    get_metric_by_id,
    get_latest_metric,
    get_metrics_statistics
)
from ...schemas.health_calculator import HealthMetricResponse

router = APIRouter(prefix="/metrics", tags=["Health Metrics"])

@router.get("/", response_model=List[HealthMetricResponse])
async def get_metrics(
    metric_type: Optional[str] = None,
    limit: int = 100,
    offset: int = 0,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Get user's health metrics history"""
    metrics = get_user_metrics(
        db=db,
        user_id=current_user.id,
        metric_type=metric_type,
        limit=limit,
        offset=offset
    )
    return metrics

@router.get("/{metric_id}", response_model=HealthMetricResponse)
async def get_metric(
    metric_id: int,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Get specific metric by ID"""
    metric = get_metric_by_id(db=db, metric_id=metric_id, user_id=current_user.id)
    if not metric:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metric not found"
        )
    return metric

@router.get("/latest/{metric_type}")
async def get_latest_metric_value(
    metric_type: str,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Get latest metric value of specific type"""
    metric = get_latest_metric(
        db=db,
        user_id=current_user.id,
        metric_type=metric_type
    )
    if not metric:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No {metric_type} metric found"
        )
    return metric

@router.get("/statistics/{metric_type}")
async def get_metric_statistics(
    metric_type: str,
    days: int = 30,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Get statistics for a metric type over a period"""
    stats = get_metrics_statistics(
        db=db,
        user_id=current_user.id,
        metric_type=metric_type,
        days=days
    )
    return stats

