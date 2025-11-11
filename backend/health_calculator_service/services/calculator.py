"""
Health Calculator Service
Provides various health calculation formulas
"""
import math
from typing import Dict, Optional
from datetime import datetime, date

class HealthCalculator:
    """Health calculation utilities"""
    
    # ============================================
    # 🩺 Kesehatan Tubuh Umum
    # ============================================
    
    @staticmethod
    def calculate_bmi(weight_kg: float, height_cm: float) -> Dict:
        """
        Calculate Body Mass Index (BMI)
        Formula: weight (kg) / (height (m))^2
        """
        height_m = height_cm / 100
        bmi = weight_kg / (height_m ** 2)
        
        # BMI Categories
        if bmi < 18.5:
            category = "Underweight"
            category_id = "underweight"
        elif bmi < 25:
            category = "Normal weight"
            category_id = "normal"
        elif bmi < 30:
            category = "Overweight"
            category_id = "overweight"
        else:
            category = "Obese"
            category_id = "obese"
        
        return {
            "bmi": round(bmi, 2),
            "category": category,
            "category_id": category_id,
            "interpretation": f"BMI {bmi:.1f} indicates {category.lower()}"
        }
    
    @staticmethod
    def calculate_bmr(weight_kg: float, height_cm: float, age: int, gender: str) -> Dict:
        """
        Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
        Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
        Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161
        """
        if gender.lower() in ['male', 'm', 'laki-laki', 'pria']:
            bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age + 5
        else:
            bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age - 161
        
        return {
            "bmr": round(bmr, 2),
            "unit": "kcal/day",
            "interpretation": f"Your body burns {bmr:.0f} calories per day at rest"
        }
    
    @staticmethod
    def calculate_tdee(bmr: float, activity_level: str) -> Dict:
        """
        Calculate Total Daily Energy Expenditure (TDEE)
        Activity multipliers:
        - Sedentary: 1.2
        - Light: 1.375
        - Moderate: 1.55
        - Active: 1.725
        - Very Active: 1.9
        """
        multipliers = {
            "sedentary": 1.2,
            "light": 1.375,
            "moderate": 1.55,
            "active": 1.725,
            "very_active": 1.9
        }
        
        activity = activity_level.lower().replace(" ", "_")
        multiplier = multipliers.get(activity, 1.2)
        tdee = bmr * multiplier
        
        return {
            "tdee": round(tdee, 2),
            "unit": "kcal/day",
            "activity_level": activity_level,
            "multiplier": multiplier,
            "interpretation": f"With {activity_level} activity, you burn {tdee:.0f} calories per day"
        }
    
    @staticmethod
    def calculate_body_fat_percentage(weight_kg: float, height_cm: float, age: int, 
                                     gender: str, waist_cm: float, neck_cm: float, 
                                     hip_cm: Optional[float] = None) -> Dict:
        """
        Calculate Body Fat Percentage using US Navy method
        """
        if gender.lower() in ['male', 'm', 'laki-laki', 'pria']:
            # Men: %Fat = 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
            if waist_cm <= neck_cm:
                return {"error": "Waist measurement must be greater than neck measurement"}
            body_fat = 495 / (1.0324 - 0.19077 * math.log10(waist_cm - neck_cm) + 0.15456 * math.log10(height_cm)) - 450
        else:
            # Women: %Fat = 495 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(height)) - 450
            if not hip_cm:
                return {"error": "Hip measurement required for women"}
            body_fat = 495 / (1.29579 - 0.35004 * math.log10(waist_cm + hip_cm - neck_cm) + 0.22100 * math.log10(height_cm)) - 450
        
        # Body fat categories
        if gender.lower() in ['male', 'm', 'laki-laki', 'pria']:
            if body_fat < 6:
                category = "Essential fat"
            elif body_fat < 14:
                category = "Athletes"
            elif body_fat < 18:
                category = "Fitness"
            elif body_fat < 25:
                category = "Average"
            else:
                category = "Obese"
        else:
            if body_fat < 16:
                category = "Essential fat"
            elif body_fat < 20:
                category = "Athletes"
            elif body_fat < 25:
                category = "Fitness"
            elif body_fat < 32:
                category = "Average"
            else:
                category = "Obese"
        
        return {
            "body_fat_percentage": round(body_fat, 2),
            "unit": "%",
            "category": category,
            "interpretation": f"Body fat percentage: {body_fat:.1f}% ({category})"
        }
    
    @staticmethod
    def calculate_waist_to_hip_ratio(waist_cm: float, hip_cm: float) -> Dict:
        """
        Calculate Waist-to-Hip Ratio (WHR)
        """
        whr = waist_cm / hip_cm
        
        # Health risk categories
        if whr < 0.85:
            risk = "Low risk"
        elif whr < 0.9:
            risk = "Moderate risk"
        else:
            risk = "High risk"
        
        return {
            "waist_to_hip_ratio": round(whr, 2),
            "risk_level": risk,
            "interpretation": f"WHR {whr:.2f} indicates {risk.lower()}"
        }
    
    @staticmethod
    def calculate_waist_to_height_ratio(waist_cm: float, height_cm: float) -> Dict:
        """
        Calculate Waist-to-Height Ratio (WtHR)
        """
        wthr = waist_cm / height_cm
        
        # Health risk categories
        if wthr < 0.4:
            risk = "Low risk"
        elif wthr < 0.5:
            risk = "Moderate risk"
        elif wthr < 0.6:
            risk = "High risk"
        else:
            risk = "Very high risk"
        
        return {
            "waist_to_height_ratio": round(wthr, 2),
            "risk_level": risk,
            "interpretation": f"WtHR {wthr:.2f} indicates {risk.lower()}"
        }
    
    @staticmethod
    def calculate_ideal_body_weight(height_cm: float, gender: str) -> Dict:
        """
        Calculate Ideal Body Weight using Devine formula
        Men: IBW = 50 + 2.3 × (height(in) - 60)
        Women: IBW = 45.5 + 2.3 × (height(in) - 60)
        """
        height_in = height_cm / 2.54
        
        if gender.lower() in ['male', 'm', 'laki-laki', 'pria']:
            ibw_kg = 50 + 2.3 * (height_in - 60)
        else:
            ibw_kg = 45.5 + 2.3 * (height_in - 60)
        
        return {
            "ideal_body_weight": round(ibw_kg, 2),
            "unit": "kg",
            "interpretation": f"Ideal body weight: {ibw_kg:.1f} kg"
        }
    
    @staticmethod
    def calculate_body_surface_area(weight_kg: float, height_cm: float) -> Dict:
        """
        Calculate Body Surface Area (BSA) using Mosteller formula
        BSA (m²) = sqrt((height(cm) × weight(kg)) / 3600)
        """
        bsa = math.sqrt((height_cm * weight_kg) / 3600)
        
        return {
            "body_surface_area": round(bsa, 2),
            "unit": "m²",
            "interpretation": f"Body surface area: {bsa:.2f} m²"
        }
    
    # ============================================
    # ❤️ Kesehatan Jantung & Metabolisme
    # ============================================
    
    @staticmethod
    def calculate_max_heart_rate(age: int) -> Dict:
        """
        Calculate Maximum Heart Rate using Tanaka formula
        MHR = 208 - (0.7 × age)
        """
        mhr = 208 - (0.7 * age)
        
        return {
            "max_heart_rate": round(mhr, 0),
            "unit": "bpm",
            "interpretation": f"Maximum heart rate: {mhr:.0f} bpm"
        }
    
    @staticmethod
    def calculate_target_heart_rate_zone(age: int, intensity: str = "moderate") -> Dict:
        """
        Calculate Target Heart Rate Zone for exercise
        Moderate: 50-70% of MHR
        Vigorous: 70-85% of MHR
        """
        mhr = 208 - (0.7 * age)
        
        if intensity.lower() in ["moderate", "mod"]:
            min_zone = mhr * 0.50
            max_zone = mhr * 0.70
            zone_name = "Moderate"
        else:  # vigorous
            min_zone = mhr * 0.70
            max_zone = mhr * 0.85
            zone_name = "Vigorous"
        
        return {
            "target_heart_rate_zone": {
                "min": round(min_zone, 0),
                "max": round(max_zone, 0)
            },
            "intensity": zone_name,
            "unit": "bpm",
            "interpretation": f"Target heart rate zone: {min_zone:.0f}-{max_zone:.0f} bpm ({zone_name})"
        }
    
    @staticmethod
    def calculate_mean_arterial_pressure(systolic: float, diastolic: float) -> Dict:
        """
        Calculate Mean Arterial Pressure (MAP)
        MAP = (2 × diastolic + systolic) / 3
        """
        map_value = (2 * diastolic + systolic) / 3
        
        # Blood pressure categories
        if map_value < 70:
            category = "Low"
        elif map_value < 100:
            category = "Normal"
        elif map_value < 110:
            category = "Elevated"
        else:
            category = "High"
        
        return {
            "mean_arterial_pressure": round(map_value, 2),
            "unit": "mmHg",
            "category": category,
            "interpretation": f"MAP {map_value:.1f} mmHg ({category})"
        }
    
    @staticmethod
    def calculate_metabolic_age(bmr: float, age: int, gender: str) -> Dict:
        """
        Estimate Metabolic Age based on BMR
        This is a simplified estimation
        """
        # Average BMR by age and gender (simplified)
        if gender.lower() in ['male', 'm', 'laki-laki', 'pria']:
            avg_bmr_by_age = {
                20: 2000, 30: 1950, 40: 1900, 50: 1850, 60: 1800, 70: 1750
            }
        else:
            avg_bmr_by_age = {
                20: 1700, 30: 1650, 40: 1600, 50: 1550, 60: 1500, 70: 1450
            }
        
        # Find closest age
        closest_age = min(avg_bmr_by_age.keys(), key=lambda x: abs(avg_bmr_by_age[x] - bmr))
        metabolic_age = closest_age
        
        if metabolic_age < age:
            status = "Younger than actual age"
        elif metabolic_age > age:
            status = "Older than actual age"
        else:
            status = "Matches actual age"
        
        return {
            "metabolic_age": metabolic_age,
            "actual_age": age,
            "status": status,
            "interpretation": f"Metabolic age: {metabolic_age} years ({status.lower()})"
        }
    
    # ============================================
    # 🍎 Nutrisi & Gizi
    # ============================================
    
    @staticmethod
    def calculate_daily_calorie_needs(tdee: float, goal: str = "maintain") -> Dict:
        """
        Calculate daily calorie needs based on goal
        """
        if goal.lower() == "lose":
            calories = tdee - 500  # Deficit for weight loss
            interpretation = f"For weight loss: {calories:.0f} kcal/day (500 kcal deficit)"
        elif goal.lower() == "gain":
            calories = tdee + 500  # Surplus for weight gain
            interpretation = f"For weight gain: {calories:.0f} kcal/day (500 kcal surplus)"
        else:  # maintain
            calories = tdee
            interpretation = f"For weight maintenance: {calories:.0f} kcal/day"
        
        return {
            "daily_calories": round(calories, 2),
            "goal": goal,
            "unit": "kcal/day",
            "interpretation": interpretation
        }
    
    @staticmethod
    def calculate_macronutrients(calories: float, protein_percent: float = 30, 
                                 carb_percent: float = 40, fat_percent: float = 30) -> Dict:
        """
        Calculate daily macronutrient needs
        Protein: 4 kcal/g
        Carbs: 4 kcal/g
        Fat: 9 kcal/g
        """
        # Ensure percentages sum to 100
        total_percent = protein_percent + carb_percent + fat_percent
        if total_percent != 100:
            # Normalize
            protein_percent = (protein_percent / total_percent) * 100
            carb_percent = (carb_percent / total_percent) * 100
            fat_percent = (fat_percent / total_percent) * 100
        
        protein_cal = calories * (protein_percent / 100)
        carb_cal = calories * (carb_percent / 100)
        fat_cal = calories * (fat_percent / 100)
        
        protein_g = protein_cal / 4
        carb_g = carb_cal / 4
        fat_g = fat_cal / 9
        
        return {
            "protein": {
                "grams": round(protein_g, 2),
                "calories": round(protein_cal, 2),
                "percentage": round(protein_percent, 1)
            },
            "carbohydrates": {
                "grams": round(carb_g, 2),
                "calories": round(carb_cal, 2),
                "percentage": round(carb_percent, 1)
            },
            "fat": {
                "grams": round(fat_g, 2),
                "calories": round(fat_cal, 2),
                "percentage": round(fat_percent, 1)
            },
            "interpretation": f"Daily macros: {protein_g:.0f}g protein, {carb_g:.0f}g carbs, {fat_g:.0f}g fat"
        }
    
    # ============================================
    # 🏋️ Kebugaran & Latihan
    # ============================================
    
    @staticmethod
    def calculate_one_rep_max(weight: float, reps: int) -> Dict:
        """
        Calculate One Rep Max (1RM) using Epley formula
        1RM = weight × (1 + reps/30)
        """
        one_rm = weight * (1 + reps / 30)
        
        return {
            "one_rep_max": round(one_rm, 2),
            "unit": "kg",
            "interpretation": f"Estimated 1RM: {one_rm:.1f} kg"
        }
    
    @staticmethod
    def calculate_calories_burned(weight_kg: float, duration_minutes: float, 
                                 activity_met: float) -> Dict:
        """
        Calculate calories burned during exercise
        Calories = MET × weight(kg) × duration(hours)
        MET values: Walking=3.5, Running=8, Cycling=6, Swimming=7, etc.
        """
        duration_hours = duration_minutes / 60
        calories = activity_met * weight_kg * duration_hours
        
        return {
            "calories_burned": round(calories, 2),
            "unit": "kcal",
            "interpretation": f"Burned approximately {calories:.0f} calories"
        }
    
    @staticmethod
    def estimate_vo2_max(age: int, resting_hr: float, max_hr: float) -> Dict:
        """
        Estimate VO₂ Max using simplified formula
        VO₂ Max = 15.3 × (MHR / RHR)
        """
        vo2_max = 15.3 * (max_hr / resting_hr)
        
        # Fitness categories
        if vo2_max < 30:
            category = "Poor"
        elif vo2_max < 40:
            category = "Fair"
        elif vo2_max < 50:
            category = "Good"
        elif vo2_max < 60:
            category = "Very Good"
        else:
            category = "Excellent"
        
        return {
            "vo2_max": round(vo2_max, 2),
            "unit": "ml/kg/min",
            "category": category,
            "interpretation": f"VO₂ Max: {vo2_max:.1f} ml/kg/min ({category})"
        }
    
    @staticmethod
    def estimate_recovery_time(intensity: str, duration_minutes: float) -> Dict:
        """
        Estimate recovery time needed after exercise
        """
        if intensity.lower() in ["low", "light"]:
            recovery_hours = duration_minutes / 60 * 0.5  # 30 min recovery per hour
        elif intensity.lower() in ["moderate", "mod"]:
            recovery_hours = duration_minutes / 60 * 1  # 1 hour recovery per hour
        else:  # high, vigorous
            recovery_hours = duration_minutes / 60 * 1.5  # 1.5 hours recovery per hour
        
        recovery_hours = max(24, recovery_hours)  # Minimum 24 hours for high intensity
        
        return {
            "recovery_time_hours": round(recovery_hours, 1),
            "recovery_time_days": round(recovery_hours / 24, 1),
            "interpretation": f"Recommended recovery: {recovery_hours:.1f} hours"
        }
    
    # ============================================
    # 💧 Cairan & Hidrasi
    # ============================================
    
    @staticmethod
    def calculate_daily_water_needs(weight_kg: float, activity_level: str = "moderate") -> Dict:
        """
        Calculate daily water needs
        Base: 35ml per kg body weight
        Add 500ml for moderate activity, 1000ml for high activity
        """
        base_water = weight_kg * 35  # ml
        
        if activity_level.lower() in ["high", "very_active", "active"]:
            additional_water = 1000
        elif activity_level.lower() in ["moderate", "mod"]:
            additional_water = 500
        else:
            additional_water = 0
        
        total_water_ml = base_water + additional_water
        total_water_liters = total_water_ml / 1000
        
        return {
            "daily_water_needs": round(total_water_liters, 2),
            "daily_water_ml": round(total_water_ml, 0),
            "unit": "liters",
            "interpretation": f"Daily water needs: {total_water_liters:.1f} liters ({total_water_ml:.0f} ml)"
        }
    
    @staticmethod
    def calculate_body_water_percentage(weight_kg: float, body_fat_percent: float) -> Dict:
        """
        Calculate percentage of water in body
        Lean body mass contains ~73% water
        """
        lean_body_mass = weight_kg * (1 - body_fat_percent / 100)
        water_weight = lean_body_mass * 0.73
        water_percentage = (water_weight / weight_kg) * 100
        
        return {
            "body_water_percentage": round(water_percentage, 2),
            "water_weight_kg": round(water_weight, 2),
            "unit": "%",
            "interpretation": f"Body water: {water_percentage:.1f}% ({water_weight:.1f} kg)"
        }

