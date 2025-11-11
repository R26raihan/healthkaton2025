"""
Pydantic schemas for Health Calculator requests and responses
"""
from pydantic import BaseModel, Field, model_serializer
from typing import Optional, Dict, Any
from datetime import datetime

# ============================================
# 🩺 Kesehatan Tubuh Umum
# ============================================

class BMIRequest(BaseModel):
    weight_kg: float = Field(..., gt=0, description="Weight in kilograms")
    height_cm: float = Field(..., gt=0, description="Height in centimeters")

class BMIResponse(BaseModel):
    bmi: float
    category: str
    category_id: str
    interpretation: str

class BMRRequest(BaseModel):
    weight_kg: float = Field(..., gt=0)
    height_cm: float = Field(..., gt=0)
    age: int = Field(..., gt=0, le=120)
    gender: str = Field(..., description="male or female")

class BMRResponse(BaseModel):
    bmr: float
    unit: str
    interpretation: str

class TDEERequest(BaseModel):
    bmr: float = Field(..., gt=0)
    activity_level: str = Field(..., description="sedentary, light, moderate, active, very_active")

class TDEEResponse(BaseModel):
    tdee: float
    unit: str
    activity_level: str
    multiplier: float
    interpretation: str

class BodyFatRequest(BaseModel):
    weight_kg: float = Field(..., gt=0)
    height_cm: float = Field(..., gt=0)
    age: int = Field(..., gt=0, le=120)
    gender: str
    waist_cm: float = Field(..., gt=0)
    neck_cm: float = Field(..., gt=0)
    hip_cm: Optional[float] = Field(None, gt=0, description="Required for women")

class BodyFatResponse(BaseModel):
    body_fat_percentage: float
    unit: str
    category: str
    interpretation: str

class WaistToHipRequest(BaseModel):
    waist_cm: float = Field(..., gt=0)
    hip_cm: float = Field(..., gt=0)

class WaistToHipResponse(BaseModel):
    waist_to_hip_ratio: float
    risk_level: str
    interpretation: str

class WaistToHeightRequest(BaseModel):
    waist_cm: float = Field(..., gt=0)
    height_cm: float = Field(..., gt=0)

class WaistToHeightResponse(BaseModel):
    waist_to_height_ratio: float
    risk_level: str
    interpretation: str

class IdealBodyWeightRequest(BaseModel):
    height_cm: float = Field(..., gt=0)
    gender: str

class IdealBodyWeightResponse(BaseModel):
    ideal_body_weight: float
    unit: str
    interpretation: str

class BodySurfaceAreaRequest(BaseModel):
    weight_kg: float = Field(..., gt=0)
    height_cm: float = Field(..., gt=0)

class BodySurfaceAreaResponse(BaseModel):
    body_surface_area: float
    unit: str
    interpretation: str

# ============================================
# ❤️ Kesehatan Jantung & Metabolisme
# ============================================

class MaxHeartRateRequest(BaseModel):
    age: int = Field(..., gt=0, le=120)

class MaxHeartRateResponse(BaseModel):
    max_heart_rate: float
    unit: str
    interpretation: str

class TargetHeartRateRequest(BaseModel):
    age: int = Field(..., gt=0, le=120)
    intensity: str = Field("moderate", description="moderate or vigorous")

class TargetHeartRateResponse(BaseModel):
    target_heart_rate_zone: Dict[str, float]
    intensity: str
    unit: str
    interpretation: str

class MAPRequest(BaseModel):
    systolic: float = Field(..., gt=0)
    diastolic: float = Field(..., gt=0)

class MAPResponse(BaseModel):
    mean_arterial_pressure: float
    unit: str
    category: str
    interpretation: str

class MetabolicAgeRequest(BaseModel):
    bmr: float = Field(..., gt=0)
    age: int = Field(..., gt=0, le=120)
    gender: str

class MetabolicAgeResponse(BaseModel):
    metabolic_age: int
    actual_age: int
    status: str
    interpretation: str

# ============================================
# 🍎 Nutrisi & Gizi
# ============================================

class DailyCalorieRequest(BaseModel):
    tdee: float = Field(..., gt=0)
    goal: str = Field("maintain", description="maintain, lose, or gain")

class DailyCalorieResponse(BaseModel):
    daily_calories: float
    goal: str
    unit: str
    interpretation: str

class MacronutrientsRequest(BaseModel):
    calories: float = Field(..., gt=0)
    protein_percent: float = Field(30, ge=0, le=100)
    carb_percent: float = Field(40, ge=0, le=100)
    fat_percent: float = Field(30, ge=0, le=100)

class MacronutrientsResponse(BaseModel):
    protein: Dict[str, float]
    carbohydrates: Dict[str, float]
    fat: Dict[str, float]
    interpretation: str

# ============================================
# 🏋️ Kebugaran & Latihan
# ============================================

class OneRepMaxRequest(BaseModel):
    weight: float = Field(..., gt=0)
    reps: int = Field(..., gt=0, le=30)

class OneRepMaxResponse(BaseModel):
    one_rep_max: float
    unit: str
    interpretation: str

class CaloriesBurnedRequest(BaseModel):
    weight_kg: float = Field(..., gt=0)
    duration_minutes: float = Field(..., gt=0)
    activity_met: float = Field(..., gt=0, description="MET value for activity")

class CaloriesBurnedResponse(BaseModel):
    calories_burned: float
    unit: str
    interpretation: str

class VO2MaxRequest(BaseModel):
    age: int = Field(..., gt=0, le=120)
    resting_hr: float = Field(..., gt=0)
    max_hr: float = Field(..., gt=0)

class VO2MaxResponse(BaseModel):
    vo2_max: float
    unit: str
    category: str
    interpretation: str

class RecoveryTimeRequest(BaseModel):
    intensity: str = Field(..., description="low, moderate, or high")
    duration_minutes: float = Field(..., gt=0)

class RecoveryTimeResponse(BaseModel):
    recovery_time_hours: float
    recovery_time_days: float
    interpretation: str

# ============================================
# 💧 Cairan & Hidrasi
# ============================================

class WaterNeedsRequest(BaseModel):
    weight_kg: float = Field(..., gt=0)
    activity_level: str = Field("moderate", description="sedentary, moderate, or high")

class WaterNeedsResponse(BaseModel):
    daily_water_needs: float
    daily_water_ml: float
    unit: str
    interpretation: str

class BodyWaterRequest(BaseModel):
    weight_kg: float = Field(..., gt=0)
    body_fat_percent: float = Field(..., ge=0, le=100)

class BodyWaterResponse(BaseModel):
    body_water_percentage: float
    water_weight_kg: float
    unit: str
    interpretation: str

# ============================================
# Response Models dengan data tersimpan
# ============================================

class HealthCalculationResponse(BaseModel):
    id: int
    user_id: int
    calculation_type: str
    result_data: Dict[str, Any]
    calculated_at: datetime
    
    @model_serializer(mode='wrap')
    def serialize_model(self, serializer, info):
        """Transform model fields to response format"""
        data = serializer(self)
        return {
            "calculation_id": data["id"],
            "user_id": data["user_id"],
            "calculation_type": data["calculation_type"],
            "result": data["result_data"],
            "calculated_at": data["calculated_at"]
        }
    
    class Config:
        from_attributes = True

class HealthMetricResponse(BaseModel):
    id: int
    user_id: int
    metric_type: str
    metric_value: float
    unit: str
    recorded_at: datetime
    notes: Optional[str] = None
    
    @model_serializer(mode='wrap')
    def serialize_model(self, serializer, info):
        """Transform model fields to response format"""
        data = serializer(self)
        return {
            "metric_id": data["id"],
            "user_id": data["user_id"],
            "metric_type": data["metric_type"],
            "metric_value": data["metric_value"],
            "unit": data["unit"],
            "recorded_at": data["recorded_at"],
            "notes": data.get("notes")
        }
    
    class Config:
        from_attributes = True

