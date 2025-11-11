"""
Health Calculator API Routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...core.database import get_db
from ...core.dependencies import get_current_active_user_for_calculator
from ...services.calculator import HealthCalculator
from ...services.crud import (
    save_health_calculation,
    get_user_calculations,
    get_calculation_by_id,
    get_latest_calculation,
    save_health_metric
)
from ...schemas.health_calculator import (
    BMIRequest, BMIResponse,
    BMRRequest, BMRResponse,
    TDEERequest, TDEEResponse,
    BodyFatRequest, BodyFatResponse,
    WaistToHipRequest, WaistToHipResponse,
    WaistToHeightRequest, WaistToHeightResponse,
    IdealBodyWeightRequest, IdealBodyWeightResponse,
    BodySurfaceAreaRequest, BodySurfaceAreaResponse,
    MaxHeartRateRequest, MaxHeartRateResponse,
    TargetHeartRateRequest, TargetHeartRateResponse,
    MAPRequest, MAPResponse,
    MetabolicAgeRequest, MetabolicAgeResponse,
    DailyCalorieRequest, DailyCalorieResponse,
    MacronutrientsRequest, MacronutrientsResponse,
    OneRepMaxRequest, OneRepMaxResponse,
    CaloriesBurnedRequest, CaloriesBurnedResponse,
    VO2MaxRequest, VO2MaxResponse,
    RecoveryTimeRequest, RecoveryTimeResponse,
    WaterNeedsRequest, WaterNeedsResponse,
    BodyWaterRequest, BodyWaterResponse,
    HealthCalculationResponse
)

router = APIRouter(prefix="/calculator", tags=["Health Calculator"])
calc = HealthCalculator()

# ============================================
# 🩺 Kesehatan Tubuh Umum
# ============================================

@router.post("/bmi", response_model=BMIResponse)
async def calculate_bmi(
    request: BMIRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Body Mass Index (BMI)"""
    result = calc.calculate_bmi(request.weight_kg, request.height_cm)
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "height_cm": request.height_cm
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="BMI",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric for statistics
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="BMI",
        metric_value=result["bmi"],
        unit="kg/m²"
    )
    
    return result

@router.post("/bmr", response_model=BMRResponse)
async def calculate_bmr(
    request: BMRRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Basal Metabolic Rate (BMR)"""
    result = calc.calculate_bmr(request.weight_kg, request.height_cm, request.age, request.gender)
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "height_cm": request.height_cm,
        "age": request.age,
        "gender": request.gender
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="BMR",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="BMR",
        metric_value=result["bmr"],
        unit="kcal/day"
    )
    
    return result

@router.post("/tdee", response_model=TDEEResponse)
async def calculate_tdee(
    request: TDEERequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Total Daily Energy Expenditure (TDEE)"""
    result = calc.calculate_tdee(request.bmr, request.activity_level)
    
    # Save to database
    input_data = {
        "bmr": request.bmr,
        "activity_level": request.activity_level
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="TDEE",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="TDEE",
        metric_value=result["tdee"],
        unit="kcal/day"
    )
    
    return result

@router.post("/body-fat", response_model=BodyFatResponse)
async def calculate_body_fat(
    request: BodyFatRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Body Fat Percentage"""
    result = calc.calculate_body_fat_percentage(
        request.weight_kg, request.height_cm, request.age,
        request.gender, request.waist_cm, request.neck_cm, request.hip_cm
    )
    
    if "error" in result:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=result["error"])
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "height_cm": request.height_cm,
        "age": request.age,
        "gender": request.gender,
        "waist_cm": request.waist_cm,
        "neck_cm": request.neck_cm,
        "hip_cm": request.hip_cm
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="BodyFat",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="BodyFat",
        metric_value=result["body_fat_percentage"],
        unit="%"
    )
    
    return result

@router.post("/waist-to-hip", response_model=WaistToHipResponse)
async def calculate_waist_to_hip(
    request: WaistToHipRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Waist-to-Hip Ratio (WHR)"""
    result = calc.calculate_waist_to_hip_ratio(request.waist_cm, request.hip_cm)
    
    # Save to database
    input_data = {
        "waist_cm": request.waist_cm,
        "hip_cm": request.hip_cm
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="WaistToHip",
        input_data=input_data,
        result_data=result
    )
    
    return result

@router.post("/waist-to-height", response_model=WaistToHeightResponse)
async def calculate_waist_to_height(
    request: WaistToHeightRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Waist-to-Height Ratio (WtHR)"""
    result = calc.calculate_waist_to_height_ratio(request.waist_cm, request.height_cm)
    
    # Save to database
    input_data = {
        "waist_cm": request.waist_cm,
        "height_cm": request.height_cm
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="WaistToHeight",
        input_data=input_data,
        result_data=result
    )
    
    return result

@router.post("/ideal-body-weight", response_model=IdealBodyWeightResponse)
async def calculate_ideal_body_weight(
    request: IdealBodyWeightRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Ideal Body Weight"""
    result = calc.calculate_ideal_body_weight(request.height_cm, request.gender)
    
    # Save to database
    input_data = {
        "height_cm": request.height_cm,
        "gender": request.gender
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="IdealBodyWeight",
        input_data=input_data,
        result_data=result
    )
    
    return result

@router.post("/body-surface-area", response_model=BodySurfaceAreaResponse)
async def calculate_body_surface_area(
    request: BodySurfaceAreaRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Body Surface Area (BSA)"""
    result = calc.calculate_body_surface_area(request.weight_kg, request.height_cm)
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "height_cm": request.height_cm
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="BodySurfaceArea",
        input_data=input_data,
        result_data=result
    )
    
    return result

# ============================================
# ❤️ Kesehatan Jantung & Metabolisme
# ============================================

@router.post("/max-heart-rate", response_model=MaxHeartRateResponse)
async def calculate_max_heart_rate(
    request: MaxHeartRateRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Maximum Heart Rate"""
    result = calc.calculate_max_heart_rate(request.age)
    
    # Save to database
    input_data = {"age": request.age}
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="MaxHeartRate",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="MaxHeartRate",
        metric_value=result["max_heart_rate"],
        unit="bpm"
    )
    
    return result

@router.post("/target-heart-rate", response_model=TargetHeartRateResponse)
async def calculate_target_heart_rate(
    request: TargetHeartRateRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Target Heart Rate Zone"""
    result = calc.calculate_target_heart_rate_zone(request.age, request.intensity)
    
    # Save to database
    input_data = {
        "age": request.age,
        "intensity": request.intensity
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="TargetHeartRate",
        input_data=input_data,
        result_data=result
    )
    
    return result

@router.post("/map", response_model=MAPResponse)
async def calculate_map(
    request: MAPRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Mean Arterial Pressure (MAP)"""
    result = calc.calculate_mean_arterial_pressure(request.systolic, request.diastolic)
    
    # Save to database
    input_data = {
        "systolic": request.systolic,
        "diastolic": request.diastolic
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="MAP",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="MAP",
        metric_value=result["mean_arterial_pressure"],
        unit="mmHg"
    )
    
    return result

@router.post("/metabolic-age", response_model=MetabolicAgeResponse)
async def calculate_metabolic_age(
    request: MetabolicAgeRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Metabolic Age"""
    result = calc.calculate_metabolic_age(request.bmr, request.age, request.gender)
    
    # Save to database
    input_data = {
        "bmr": request.bmr,
        "age": request.age,
        "gender": request.gender
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="MetabolicAge",
        input_data=input_data,
        result_data=result
    )
    
    return result

# ============================================
# 🍎 Nutrisi & Gizi
# ============================================

@router.post("/daily-calories", response_model=DailyCalorieResponse)
async def calculate_daily_calories(
    request: DailyCalorieRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Daily Calorie Needs"""
    result = calc.calculate_daily_calorie_needs(request.tdee, request.goal)
    
    # Save to database
    input_data = {
        "tdee": request.tdee,
        "goal": request.goal
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="DailyCalories",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="DailyCalories",
        metric_value=result["daily_calories"],
        unit="kcal/day"
    )
    
    return result

@router.post("/macronutrients", response_model=MacronutrientsResponse)
async def calculate_macronutrients(
    request: MacronutrientsRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Macronutrients (Protein, Carbs, Fat)"""
    result = calc.calculate_macronutrients(
        request.calories, request.protein_percent, request.carb_percent, request.fat_percent
    )
    
    # Save to database
    input_data = {
        "calories": request.calories,
        "protein_percent": request.protein_percent,
        "carb_percent": request.carb_percent,
        "fat_percent": request.fat_percent
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="Macronutrients",
        input_data=input_data,
        result_data=result
    )
    
    return result

# ============================================
# 🏋️ Kebugaran & Latihan
# ============================================

@router.post("/one-rep-max", response_model=OneRepMaxResponse)
async def calculate_one_rep_max(
    request: OneRepMaxRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate One Rep Max (1RM)"""
    result = calc.calculate_one_rep_max(request.weight, request.reps)
    
    # Save to database
    input_data = {
        "weight": request.weight,
        "reps": request.reps
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="OneRepMax",
        input_data=input_data,
        result_data=result
    )
    
    return result

@router.post("/calories-burned", response_model=CaloriesBurnedResponse)
async def calculate_calories_burned(
    request: CaloriesBurnedRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Calories Burned During Exercise"""
    result = calc.calculate_calories_burned(
        request.weight_kg, request.duration_minutes, request.activity_met
    )
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "duration_minutes": request.duration_minutes,
        "activity_met": request.activity_met
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="CaloriesBurned",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="CaloriesBurned",
        metric_value=result["calories_burned"],
        unit="kcal"
    )
    
    return result

@router.post("/vo2-max", response_model=VO2MaxResponse)
async def calculate_vo2_max(
    request: VO2MaxRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate VO₂ Max (Maximum Oxygen Consumption)"""
    result = calc.estimate_vo2_max(request.age, request.resting_hr, request.max_hr)
    
    # Save to database
    input_data = {
        "age": request.age,
        "resting_hr": request.resting_hr,
        "max_hr": request.max_hr
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="VO2Max",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="VO2Max",
        metric_value=result["vo2_max"],
        unit="ml/kg/min"
    )
    
    return result

@router.post("/recovery-time", response_model=RecoveryTimeResponse)
async def calculate_recovery_time(
    request: RecoveryTimeRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Estimate Recovery Time After Exercise"""
    result = calc.estimate_recovery_time(request.intensity, request.duration_minutes)
    
    # Save to database
    input_data = {
        "intensity": request.intensity,
        "duration_minutes": request.duration_minutes
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="RecoveryTime",
        input_data=input_data,
        result_data=result
    )
    
    return result

# ============================================
# 💧 Cairan & Hidrasi
# ============================================

@router.post("/water-needs", response_model=WaterNeedsResponse)
async def calculate_water_needs(
    request: WaterNeedsRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Daily Water Needs"""
    result = calc.calculate_daily_water_needs(request.weight_kg, request.activity_level)
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "activity_level": request.activity_level
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="WaterNeeds",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="WaterNeeds",
        metric_value=result["daily_water_ml"],
        unit="ml"
    )
    
    return result

@router.post("/body-water", response_model=BodyWaterResponse)
async def calculate_body_water(
    request: BodyWaterRequest,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Calculate Body Water Percentage"""
    result = calc.calculate_body_water_percentage(request.weight_kg, request.body_fat_percent)
    
    # Save to database
    input_data = {
        "weight_kg": request.weight_kg,
        "body_fat_percent": request.body_fat_percent
    }
    save_health_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type="BodyWater",
        input_data=input_data,
        result_data=result
    )
    
    # Also save as metric
    save_health_metric(
        db=db,
        user_id=current_user.id,
        metric_type="BodyWater",
        metric_value=result["body_water_percentage"],
        unit="%"
    )
    
    return result

# ============================================
# History & Statistics
# ============================================

@router.get("/history", response_model=List[HealthCalculationResponse])
async def get_calculation_history(
    calculation_type: str = None,
    limit: int = 50,
    offset: int = 0,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Get user's calculation history"""
    calculations = get_user_calculations(
        db=db,
        user_id=current_user.id,
        calculation_type=calculation_type,
        limit=limit,
        offset=offset
    )
    return calculations

@router.get("/latest/{calculation_type}")
async def get_latest_calculation_result(
    calculation_type: str,
    current_user = Depends(get_current_active_user_for_calculator),
    db: Session = Depends(get_db)
):
    """Get latest calculation result of specific type"""
    calculation = get_latest_calculation(
        db=db,
        user_id=current_user.id,
        calculation_type=calculation_type
    )
    if not calculation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No {calculation_type} calculation found"
        )
    return calculation

