import 'dart:math';

/// Health Calculator Service
/// Provides various health calculation formulas (mirror of Python backend)
class HealthCalculatorService {
  // ============================================
  // 🩺 Kesehatan Tubuh Umum
  // ============================================
  
  /// Calculate Body Mass Index (BMI)
  /// Formula: weight (kg) / (height (m))^2
  static Map<String, dynamic> calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    
    String category;
    String categoryId;
    
    if (bmi < 18.5) {
      category = "Underweight";
      categoryId = "underweight";
    } else if (bmi < 25) {
      category = "Normal weight";
      categoryId = "normal";
    } else if (bmi < 30) {
      category = "Overweight";
      categoryId = "overweight";
    } else {
      category = "Obese";
      categoryId = "obese";
    }
    
    return {
      "bmi": bmi.toStringAsFixed(2),
      "category": category,
      "category_id": categoryId,
      "interpretation": "BMI ${bmi.toStringAsFixed(1)} indicates ${category.toLowerCase()}",
    };
  }
  
  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  static Map<String, dynamic> calculateBMR(
    double weightKg,
    double heightCm,
    int age,
    String gender,
  ) {
    double bmr;
    
    if (gender.toLowerCase() == 'male' || 
        gender.toLowerCase() == 'm' || 
        gender.toLowerCase() == 'laki-laki' || 
        gender.toLowerCase() == 'pria') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    
    return {
      "bmr": bmr.toStringAsFixed(2),
      "unit": "kcal/day",
      "interpretation": "Your body burns ${bmr.toStringAsFixed(0)} calories per day at rest",
    };
  }
  
  /// Calculate Total Daily Energy Expenditure (TDEE)
  static Map<String, dynamic> calculateTDEE(double bmr, String activityLevel) {
    final multipliers = {
      "sedentary": 1.2,
      "light": 1.375,
      "moderate": 1.55,
      "active": 1.725,
      "very_active": 1.9,
    };
    
    final activity = activityLevel.toLowerCase().replaceAll(" ", "_");
    final multiplier = multipliers[activity] ?? 1.2;
    final tdee = bmr * multiplier;
    
    return {
      "tdee": tdee.toStringAsFixed(2),
      "unit": "kcal/day",
      "activity_level": activityLevel,
      "multiplier": multiplier,
      "interpretation": "With $activityLevel activity, you burn ${tdee.toStringAsFixed(0)} calories per day",
    };
  }
  
  /// Calculate Body Fat Percentage using US Navy method
  static Map<String, dynamic> calculateBodyFatPercentage({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required double waistCm,
    required double neckCm,
    double? hipCm,
  }) {
    double bodyFat;
    
    if (gender.toLowerCase() == 'male' || 
        gender.toLowerCase() == 'm' || 
        gender.toLowerCase() == 'laki-laki' || 
        gender.toLowerCase() == 'pria') {
      if (waistCm <= neckCm) {
        return {"error": "Waist measurement must be greater than neck measurement"};
      }
      bodyFat = 495 / (1.0324 - 0.19077 * log10(waistCm - neckCm) + 0.15456 * log10(heightCm)) - 450;
    } else {
      if (hipCm == null) {
        return {"error": "Hip measurement required for women"};
      }
      bodyFat = 495 / (1.29579 - 0.35004 * log10(waistCm + hipCm - neckCm) + 0.22100 * log10(heightCm)) - 450;
    }
    
    String category;
    if (gender.toLowerCase() == 'male' || 
        gender.toLowerCase() == 'm' || 
        gender.toLowerCase() == 'laki-laki' || 
        gender.toLowerCase() == 'pria') {
      if (bodyFat < 6) {
        category = "Essential fat";
      } else if (bodyFat < 14) {
        category = "Athletes";
      } else if (bodyFat < 18) {
        category = "Fitness";
      } else if (bodyFat < 25) {
        category = "Average";
      } else {
        category = "Obese";
      }
    } else {
      if (bodyFat < 16) {
        category = "Essential fat";
      } else if (bodyFat < 20) {
        category = "Athletes";
      } else if (bodyFat < 25) {
        category = "Fitness";
      } else if (bodyFat < 32) {
        category = "Average";
      } else {
        category = "Obese";
      }
    }
    
    return {
      "body_fat_percentage": bodyFat.toStringAsFixed(2),
      "unit": "%",
      "category": category,
      "interpretation": "Body fat percentage: ${bodyFat.toStringAsFixed(1)}% ($category)",
    };
  }
  
  /// Calculate Waist-to-Hip Ratio (WHR)
  static Map<String, dynamic> calculateWaistToHipRatio(double waistCm, double hipCm) {
    final whr = waistCm / hipCm;
    
    String risk;
    if (whr < 0.85) {
      risk = "Low risk";
    } else if (whr < 0.9) {
      risk = "Moderate risk";
    } else {
      risk = "High risk";
    }
    
    return {
      "waist_to_hip_ratio": whr.toStringAsFixed(2),
      "risk_level": risk,
      "interpretation": "WHR ${whr.toStringAsFixed(2)} indicates ${risk.toLowerCase()}",
    };
  }
  
  /// Calculate Waist-to-Height Ratio (WtHR)
  static Map<String, dynamic> calculateWaistToHeightRatio(double waistCm, double heightCm) {
    final wthr = waistCm / heightCm;
    
    String risk;
    if (wthr < 0.4) {
      risk = "Low risk";
    } else if (wthr < 0.5) {
      risk = "Moderate risk";
    } else if (wthr < 0.6) {
      risk = "High risk";
    } else {
      risk = "Very high risk";
    }
    
    return {
      "waist_to_height_ratio": wthr.toStringAsFixed(2),
      "risk_level": risk,
      "interpretation": "WtHR ${wthr.toStringAsFixed(2)} indicates ${risk.toLowerCase()}",
    };
  }
  
  /// Calculate Ideal Body Weight using Devine formula
  static Map<String, dynamic> calculateIdealBodyWeight(double heightCm, String gender) {
    final heightIn = heightCm / 2.54;
    double ibwKg;
    
    if (gender.toLowerCase() == 'male' || 
        gender.toLowerCase() == 'm' || 
        gender.toLowerCase() == 'laki-laki' || 
        gender.toLowerCase() == 'pria') {
      ibwKg = 50 + 2.3 * (heightIn - 60);
    } else {
      ibwKg = 45.5 + 2.3 * (heightIn - 60);
    }
    
    return {
      "ideal_body_weight": ibwKg.toStringAsFixed(2),
      "unit": "kg",
      "interpretation": "Ideal body weight: ${ibwKg.toStringAsFixed(1)} kg",
    };
  }
  
  /// Calculate Body Surface Area (BSA) using Mosteller formula
  static Map<String, dynamic> calculateBodySurfaceArea(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    final bsa = sqrt((weightKg * heightM) / 3600);
    
    return {
      "body_surface_area": bsa.toStringAsFixed(2),
      "unit": "m²",
      "interpretation": "Body surface area: ${bsa.toStringAsFixed(2)} m²",
    };
  }
  
  // ============================================
  // ❤️ Kesehatan Jantung & Metabolisme
  // ============================================
  
  /// Calculate Maximum Heart Rate
  static Map<String, dynamic> calculateMaxHeartRate(int age) {
    final maxHr = 220 - age;
    
    return {
      "max_heart_rate": maxHr.toStringAsFixed(0),
      "unit": "bpm",
      "interpretation": "Maximum heart rate: $maxHr bpm",
    };
  }
  
  /// Calculate Target Heart Rate Zone
  static Map<String, dynamic> calculateTargetHeartRate(int age, String intensity) {
    final maxHr = 220 - age;
    Map<String, double> zone;
    
    if (intensity.toLowerCase() == "moderate") {
      zone = {
        "min": maxHr * 0.5,
        "max": maxHr * 0.7,
      };
    } else {
      zone = {
        "min": maxHr * 0.7,
        "max": maxHr * 0.85,
      };
    }
    
    return {
      "target_heart_rate_zone": zone,
      "intensity": intensity,
      "unit": "bpm",
      "interpretation": "Target heart rate zone: ${zone["min"]!.toStringAsFixed(0)}-${zone["max"]!.toStringAsFixed(0)} bpm",
    };
  }
  
  /// Calculate Mean Arterial Pressure (MAP)
  static Map<String, dynamic> calculateMeanArterialPressure(double systolic, double diastolic) {
    final map = diastolic + (systolic - diastolic) / 3;
    
    String category;
    if (map < 70) {
      category = "Low";
    } else if (map < 100) {
      category = "Normal";
    } else if (map < 110) {
      category = "Elevated";
    } else {
      category = "High";
    }
    
    return {
      "mean_arterial_pressure": map.toStringAsFixed(2),
      "unit": "mmHg",
      "category": category,
      "interpretation": "Mean arterial pressure: ${map.toStringAsFixed(0)} mmHg ($category)",
    };
  }
  
  /// Calculate Metabolic Age
  static Map<String, dynamic> calculateMetabolicAge(double bmr, int age, String gender) {
    // Simplified calculation - in real scenario, this would use more complex formulas
    final avgBmr = gender.toLowerCase() == 'male' || 
                   gender.toLowerCase() == 'm' || 
                   gender.toLowerCase() == 'laki-laki' || 
                   gender.toLowerCase() == 'pria'
        ? 2000.0
        : 1800.0;
    
    final metabolicAge = age + ((bmr - avgBmr) / 20).round();
    final status = metabolicAge < age ? "Younger" : metabolicAge > age ? "Older" : "Same";
    
    return {
      "metabolic_age": metabolicAge,
      "actual_age": age,
      "status": status,
      "interpretation": "Metabolic age: $metabolicAge years (${status.toLowerCase()} than actual age)",
    };
  }
  
  // ============================================
  // 🍎 Nutrisi & Gizi
  // ============================================
  
  /// Calculate Daily Calorie Needs
  static Map<String, dynamic> calculateDailyCalories(double tdee, String goal) {
    double dailyCalories;
    
    switch (goal.toLowerCase()) {
      case "lose":
        dailyCalories = tdee - 500; // 500 calorie deficit
        break;
      case "gain":
        dailyCalories = tdee + 500; // 500 calorie surplus
        break;
      default:
        dailyCalories = tdee; // maintain
    }
    
    return {
      "daily_calories": dailyCalories.toStringAsFixed(0),
      "goal": goal,
      "unit": "kcal/day",
      "interpretation": "Daily calorie needs for ${goal.toLowerCase()} goal: ${dailyCalories.toStringAsFixed(0)} kcal/day",
    };
  }
  
  /// Calculate Macronutrients
  static Map<String, dynamic> calculateMacronutrients(
    double calories,
    double proteinPercent,
    double carbPercent,
    double fatPercent,
  ) {
    final proteinCal = calories * (proteinPercent / 100);
    final carbCal = calories * (carbPercent / 100);
    final fatCal = calories * (fatPercent / 100);
    
    final proteinG = proteinCal / 4;
    final carbG = carbCal / 4;
    final fatG = fatCal / 9;
    
    return {
      "protein": {
        "grams": proteinG.toStringAsFixed(1),
        "calories": proteinCal.toStringAsFixed(0),
        "percent": proteinPercent.toStringAsFixed(0),
      },
      "carbohydrates": {
        "grams": carbG.toStringAsFixed(1),
        "calories": carbCal.toStringAsFixed(0),
        "percent": carbPercent.toStringAsFixed(0),
      },
      "fat": {
        "grams": fatG.toStringAsFixed(1),
        "calories": fatCal.toStringAsFixed(0),
        "percent": fatPercent.toStringAsFixed(0),
      },
      "interpretation": "Macronutrient breakdown: ${proteinG.toStringAsFixed(0)}g protein, ${carbG.toStringAsFixed(0)}g carbs, ${fatG.toStringAsFixed(0)}g fat",
    };
  }
  
  // ============================================
  // 🏋️ Kebugaran & Latihan
  // ============================================
  
  /// Calculate One Rep Max (1RM)
  static Map<String, dynamic> calculateOneRepMax(double weight, int reps) {
    // Epley formula: 1RM = weight × (1 + reps/30)
    final oneRm = weight * (1 + reps / 30);
    
    return {
      "one_rep_max": oneRm.toStringAsFixed(2),
      "unit": "kg",
      "interpretation": "One rep max: ${oneRm.toStringAsFixed(1)} kg",
    };
  }
  
  /// Calculate Calories Burned During Exercise
  static Map<String, dynamic> calculateCaloriesBurned(
    double weightKg,
    double durationMinutes,
    double activityMet,
  ) {
    // MET × weight (kg) × time (hours)
    final hours = durationMinutes / 60;
    final caloriesBurned = activityMet * weightKg * hours;
    
    return {
      "calories_burned": caloriesBurned.toStringAsFixed(0),
      "unit": "kcal",
      "interpretation": "Calories burned: ${caloriesBurned.toStringAsFixed(0)} kcal",
    };
  }
  
  /// Estimate VO2 Max
  static Map<String, dynamic> estimateVO2Max(int age, double restingHr, double maxHr) {
    // Simplified estimation
    final vo2Max = 15.3 * (maxHr / restingHr);
    
    String category;
    if (vo2Max < 30) {
      category = "Poor";
    } else if (vo2Max < 40) {
      category = "Fair";
    } else if (vo2Max < 50) {
      category = "Good";
    } else if (vo2Max < 60) {
      category = "Excellent";
    } else {
      category = "Superior";
    }
    
    return {
      "vo2_max": vo2Max.toStringAsFixed(1),
      "unit": "ml/kg/min",
      "category": category,
      "interpretation": "VO₂ Max: ${vo2Max.toStringAsFixed(1)} ml/kg/min ($category)",
    };
  }
  
  /// Estimate Recovery Time After Exercise
  static Map<String, dynamic> estimateRecoveryTime(String intensity, double durationMinutes) {
    double recoveryHours;
    
    switch (intensity.toLowerCase()) {
      case "low":
        recoveryHours = durationMinutes / 60;
        break;
      case "moderate":
        recoveryHours = durationMinutes / 30;
        break;
      case "high":
        recoveryHours = durationMinutes / 15;
        break;
      default:
        recoveryHours = durationMinutes / 30;
    }
    
    return {
      "recovery_time_hours": recoveryHours.toStringAsFixed(1),
      "recovery_time_days": (recoveryHours / 24).toStringAsFixed(2),
      "interpretation": "Estimated recovery time: ${recoveryHours.toStringAsFixed(1)} hours",
    };
  }
  
  // ============================================
  // 💧 Cairan & Hidrasi
  // ============================================
  
  /// Calculate Daily Water Needs
  static Map<String, dynamic> calculateDailyWaterNeeds(double weightKg, String activityLevel) {
    double baseWater = weightKg * 30; // 30ml per kg
    
    double multiplier;
    switch (activityLevel.toLowerCase()) {
      case "high":
        multiplier = 1.5;
        break;
      case "moderate":
        multiplier = 1.2;
        break;
      default:
        multiplier = 1.0;
    }
    
    final dailyWater = baseWater * multiplier;
    
    return {
      "daily_water_needs": (dailyWater / 1000).toStringAsFixed(1),
      "daily_water_ml": dailyWater.toStringAsFixed(0),
      "unit": "L",
      "interpretation": "Daily water needs: ${(dailyWater / 1000).toStringAsFixed(1)} L (${dailyWater.toStringAsFixed(0)} ml)",
    };
  }
  
  /// Calculate Body Water Percentage
  static Map<String, dynamic> calculateBodyWaterPercentage(double weightKg, double bodyFatPercent) {
    final leanBodyMass = weightKg * (1 - bodyFatPercent / 100);
    final waterWeight = leanBodyMass * 0.73; // 73% of lean body mass is water
    final waterPercentage = (waterWeight / weightKg) * 100;
    
    return {
      "body_water_percentage": waterPercentage.toStringAsFixed(1),
      "water_weight_kg": waterWeight.toStringAsFixed(1),
      "unit": "%",
      "interpretation": "Body water percentage: ${waterPercentage.toStringAsFixed(1)}% (${waterWeight.toStringAsFixed(1)} kg)",
    };
  }
  
  // Helper function for log10
  static double log10(double x) {
    return log(x) / ln10;
  }
}

