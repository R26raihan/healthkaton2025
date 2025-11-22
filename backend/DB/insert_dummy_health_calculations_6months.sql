-- ============================================
-- Insert Dummy Data Health Calculations & Metrics
-- Data 6 bulan untuk user raihansetiawan203@gmail.com
-- ============================================

USE healthkon_bpjs;

-- Set user_id dari email
SET @user_id = (SELECT id FROM users WHERE email = 'raihansetiawan203@gmail.com' LIMIT 1);

-- Jika user tidak ditemukan, tampilkan error
SELECT IF(@user_id IS NULL, 
    CONCAT('ERROR: User dengan email raihansetiawan203@gmail.com tidak ditemukan!'),
    CONCAT('User ID ditemukan: ', @user_id)
) AS status;

-- ============================================
-- 1. Health Calculations - Data 6 Bulan
-- ============================================
-- Data akan dibuat dengan variasi realistis dari 6 bulan lalu hingga sekarang
-- Frekuensi: 2-3 kali per minggu untuk berbagai jenis perhitungan

-- BMI Calculations (setiap 1-2 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'BMI', 
 JSON_OBJECT('height', 172, 'weight', 70.5, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.8, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 180 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 70.2, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.7, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 69.8, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.6, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 160 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 69.5, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.5, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 69.2, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.4, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 140 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 69.0, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.3, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 68.8, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.2, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 120 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 68.5, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.1, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 68.3, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 23.0, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 100 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 68.0, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.9, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 67.8, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.9, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 80 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 67.5, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.8, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 67.2, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.7, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 60 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 67.0, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.6, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 66.8, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.5, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 40 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 66.5, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.4, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 66.3, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.3, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 20 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 66.0, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.2, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 10 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 65.8, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.2, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 DATE_SUB(NOW(), INTERVAL 5 DAY)),

(@user_id, 'BMI',
 JSON_OBJECT('height', 172, 'weight', 65.5, 'unit_height', 'cm', 'unit_weight', 'kg'),
 JSON_OBJECT('bmi', 22.1, 'category', 'Normal', 'status', 'Healthy', 'normal_range', '18.5-24.9'),
 NOW());

-- BMR Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 70.5, 'activity_level', 'sedentary'),
 JSON_OBJECT('bmr', 1705, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 175 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 69.5, 'activity_level', 'moderate'),
 JSON_OBJECT('bmr', 1685, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 155 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 68.5, 'activity_level', 'active'),
 JSON_OBJECT('bmr', 1665, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 135 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 67.5, 'activity_level', 'moderate'),
 JSON_OBJECT('bmr', 1645, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 115 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 67.0, 'activity_level', 'active'),
 JSON_OBJECT('bmr', 1635, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 95 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 66.5, 'activity_level', 'very_active'),
 JSON_OBJECT('bmr', 1625, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 75 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 66.0, 'activity_level', 'moderate'),
 JSON_OBJECT('bmr', 1615, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 55 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 65.8, 'activity_level', 'active'),
 JSON_OBJECT('bmr', 1610, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 35 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 65.5, 'activity_level', 'very_active'),
 JSON_OBJECT('bmr', 1605, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 DATE_SUB(NOW(), INTERVAL 15 DAY)),

(@user_id, 'BMR',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 65.5, 'activity_level', 'active'),
 JSON_OBJECT('bmr', 1605, 'method', 'Mifflin-St Jeor', 'unit', 'kcal/day', 'description', 'Basal Metabolic Rate'),
 NOW());

-- TDEE Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1705, 'activity_level', 'moderate', 'exercise_days', 3),
 JSON_OBJECT('tdee', 2344, 'bmr', 1705, 'activity_multiplier', 1.375, 'unit', 'kcal/day', 'goal', 'maintenance'),
 DATE_SUB(NOW(), INTERVAL 173 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1685, 'activity_level', 'active', 'exercise_days', 4),
 JSON_OBJECT('tdee', 2523, 'bmr', 1685, 'activity_multiplier', 1.5, 'unit', 'kcal/day', 'goal', 'maintenance'),
 DATE_SUB(NOW(), INTERVAL 153 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1665, 'activity_level', 'very_active', 'exercise_days', 5),
 JSON_OBJECT('tdee', 2701, 'bmr', 1665, 'activity_multiplier', 1.625, 'unit', 'kcal/day', 'goal', 'weight_loss'),
 DATE_SUB(NOW(), INTERVAL 133 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1645, 'activity_level', 'active', 'exercise_days', 4),
 JSON_OBJECT('tdee', 2468, 'bmr', 1645, 'activity_multiplier', 1.5, 'unit', 'kcal/day', 'goal', 'maintenance'),
 DATE_SUB(NOW(), INTERVAL 113 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1635, 'activity_level', 'very_active', 'exercise_days', 5),
 JSON_OBJECT('tdee', 2657, 'bmr', 1635, 'activity_multiplier', 1.625, 'unit', 'kcal/day', 'goal', 'weight_loss'),
 DATE_SUB(NOW(), INTERVAL 93 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1625, 'activity_level', 'very_active', 'exercise_days', 6),
 JSON_OBJECT('tdee', 2641, 'bmr', 1625, 'activity_multiplier', 1.625, 'unit', 'kcal/day', 'goal', 'weight_loss'),
 DATE_SUB(NOW(), INTERVAL 73 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1615, 'activity_level', 'active', 'exercise_days', 4),
 JSON_OBJECT('tdee', 2423, 'bmr', 1615, 'activity_multiplier', 1.5, 'unit', 'kcal/day', 'goal', 'maintenance'),
 DATE_SUB(NOW(), INTERVAL 53 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1610, 'activity_level', 'very_active', 'exercise_days', 5),
 JSON_OBJECT('tdee', 2616, 'bmr', 1610, 'activity_multiplier', 1.625, 'unit', 'kcal/day', 'goal', 'weight_loss'),
 DATE_SUB(NOW(), INTERVAL 33 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1605, 'activity_level', 'very_active', 'exercise_days', 6),
 JSON_OBJECT('tdee', 2608, 'bmr', 1605, 'activity_multiplier', 1.625, 'unit', 'kcal/day', 'goal', 'maintenance'),
 DATE_SUB(NOW(), INTERVAL 13 DAY)),

(@user_id, 'TDEE',
 JSON_OBJECT('bmr', 1605, 'activity_level', 'active', 'exercise_days', 4),
 JSON_OBJECT('tdee', 2408, 'bmr', 1605, 'activity_multiplier', 1.5, 'unit', 'kcal/day', 'goal', 'maintenance'),
 NOW());

-- BodyFat Calculations (setiap 3-4 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 70.5, 'waist', 85, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 18.5, 'body_fat_mass', 13.04, 'lean_body_mass', 57.46, 'category', 'Average', 'unit', '%'),
 DATE_SUB(NOW(), INTERVAL 165 DAY)),

(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 69.0, 'waist', 84, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 17.8, 'body_fat_mass', 12.28, 'lean_body_mass', 56.72, 'category', 'Average', 'unit', '%'),
 DATE_SUB(NOW(), INTERVAL 135 DAY)),

(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 67.5, 'waist', 82, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 17.2, 'body_fat_mass', 11.61, 'lean_body_mass', 55.89, 'category', 'Average', 'unit', '%'),
 DATE_SUB(NOW(), INTERVAL 105 DAY)),

(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 66.5, 'waist', 81, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 16.8, 'body_fat_mass', 11.17, 'lean_body_mass', 55.33, 'category', 'Fitness', 'unit', '%'),
 DATE_SUB(NOW(), INTERVAL 75 DAY)),

(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 66.0, 'waist', 80, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 16.5, 'body_fat_mass', 10.89, 'lean_body_mass', 55.11, 'category', 'Fitness', 'unit', '%'),
 DATE_SUB(NOW(), INTERVAL 45 DAY)),

(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 65.5, 'waist', 79, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 16.2, 'body_fat_mass', 10.61, 'lean_body_mass', 54.89, 'category', 'Fitness', 'unit', '%'),
 DATE_SUB(NOW(), INTERVAL 15 DAY)),

(@user_id, 'BodyFat',
 JSON_OBJECT('age', 29, 'gender', 'male', 'height', 172, 'weight', 65.5, 'waist', 79, 'neck', 38),
 JSON_OBJECT('body_fat_percentage', 16.1, 'body_fat_mass', 10.55, 'lean_body_mass', 54.95, 'category', 'Fitness', 'unit', '%'),
 NOW());

-- Ideal Weight Calculations (setiap bulan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'IdealWeight',
 JSON_OBJECT('height', 172, 'gender', 'male', 'frame_size', 'medium'),
 JSON_OBJECT('ideal_weight_kg', 67.5, 'ideal_weight_range_min', 64.0, 'ideal_weight_range_max', 71.0, 'current_weight', 70.5, 'difference', -3.0, 'unit', 'kg'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'IdealWeight',
 JSON_OBJECT('height', 172, 'gender', 'male', 'frame_size', 'medium'),
 JSON_OBJECT('ideal_weight_kg', 67.5, 'ideal_weight_range_min', 64.0, 'ideal_weight_range_max', 71.0, 'current_weight', 66.5, 'difference', 1.0, 'unit', 'kg'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'IdealWeight',
 JSON_OBJECT('height', 172, 'gender', 'male', 'frame_size', 'medium'),
 JSON_OBJECT('ideal_weight_kg', 67.5, 'ideal_weight_range_min', 64.0, 'ideal_weight_range_max', 71.0, 'current_weight', 65.5, 'difference', 2.0, 'unit', 'kg'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'IdealWeight',
 JSON_OBJECT('height', 172, 'gender', 'male', 'frame_size', 'medium'),
 JSON_OBJECT('ideal_weight_kg', 67.5, 'ideal_weight_range_min', 64.0, 'ideal_weight_range_max', 71.0, 'current_weight', 65.5, 'difference', 2.0, 'unit', 'kg'),
 NOW());

-- IdealBodyWeight (alternate name used in code)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'IdealBodyWeight',
 JSON_OBJECT('height', 172, 'gender', 'male', 'frame_size', 'medium'),
 JSON_OBJECT('ideal_weight_kg', 67.5, 'ideal_weight_range_min', 64.0, 'ideal_weight_range_max', 71.0, 'current_weight', 65.5, 'difference', 2.0, 'unit', 'kg'),
 DATE_SUB(NOW(), INTERVAL 60 DAY));

-- RecoveryTime Calculations (setiap 1-2 minggu setelah latihan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'moderate', 'duration_minutes', 45),
 JSON_OBJECT('recovery_time_hours', 24, 'recovery_time_days', 1, 'interpretation', 'Pemulihan penuh dalam 24 jam'),
 DATE_SUB(NOW(), INTERVAL 175 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'high', 'duration_minutes', 60),
 JSON_OBJECT('recovery_time_hours', 48, 'recovery_time_days', 2, 'interpretation', 'Pemulihan penuh dalam 48 jam'),
 DATE_SUB(NOW(), INTERVAL 160 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'moderate', 'duration_minutes', 30),
 JSON_OBJECT('recovery_time_hours', 18, 'recovery_time_days', 0.75, 'interpretation', 'Pemulihan penuh dalam 18 jam'),
 DATE_SUB(NOW(), INTERVAL 145 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'high', 'duration_minutes', 90),
 JSON_OBJECT('recovery_time_hours', 72, 'recovery_time_days', 3, 'interpretation', 'Pemulihan penuh dalam 72 jam'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'low', 'duration_minutes', 20),
 JSON_OBJECT('recovery_time_hours', 12, 'recovery_time_days', 0.5, 'interpretation', 'Pemulihan penuh dalam 12 jam'),
 DATE_SUB(NOW(), INTERVAL 115 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'moderate', 'duration_minutes', 50),
 JSON_OBJECT('recovery_time_hours', 24, 'recovery_time_days', 1, 'interpretation', 'Pemulihan penuh dalam 24 jam'),
 DATE_SUB(NOW(), INTERVAL 100 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'high', 'duration_minutes', 75),
 JSON_OBJECT('recovery_time_hours', 60, 'recovery_time_days', 2.5, 'interpretation', 'Pemulihan penuh dalam 60 jam'),
 DATE_SUB(NOW(), INTERVAL 85 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'moderate', 'duration_minutes', 40),
 JSON_OBJECT('recovery_time_hours', 20, 'recovery_time_days', 0.83, 'interpretation', 'Pemulihan penuh dalam 20 jam'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'high', 'duration_minutes', 80),
 JSON_OBJECT('recovery_time_hours', 64, 'recovery_time_days', 2.67, 'interpretation', 'Pemulihan penuh dalam 64 jam'),
 DATE_SUB(NOW(), INTERVAL 55 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'moderate', 'duration_minutes', 35),
 JSON_OBJECT('recovery_time_hours', 18, 'recovery_time_days', 0.75, 'interpretation', 'Pemulihan penuh dalam 18 jam'),
 DATE_SUB(NOW(), INTERVAL 40 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'high', 'duration_minutes', 70),
 JSON_OBJECT('recovery_time_hours', 56, 'recovery_time_days', 2.33, 'interpretation', 'Pemulihan penuh dalam 56 jam'),
 DATE_SUB(NOW(), INTERVAL 25 DAY)),

(@user_id, 'RecoveryTime',
 JSON_OBJECT('intensity', 'moderate', 'duration_minutes', 45),
 JSON_OBJECT('recovery_time_hours', 24, 'recovery_time_days', 1, 'interpretation', 'Pemulihan penuh dalam 24 jam'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- VO2Max Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 72, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 42.5, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 70, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 43.2, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 68, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 44.1, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 67, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 44.8, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 66, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 45.5, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 65, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 46.2, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 64, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 46.9, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 63, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 47.6, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'VO2Max',
 JSON_OBJECT('age', 29, 'resting_hr', 62, 'max_hr', 191),
 JSON_OBJECT('vo2_max', 48.3, 'unit', 'ml/kg/min', 'category', 'Good', 'interpretation', 'Kebugaran kardiovaskular baik'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- CaloriesBurned Calculations (setiap 1-2 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 70.5, 'duration_minutes', 45, 'activity_met', 6.0),
 JSON_OBJECT('calories_burned', 318, 'unit', 'kcal', 'activity', 'Running'),
 DATE_SUB(NOW(), INTERVAL 175 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 69.5, 'duration_minutes', 60, 'activity_met', 8.0),
 JSON_OBJECT('calories_burned', 556, 'unit', 'kcal', 'activity', 'Cycling'),
 DATE_SUB(NOW(), INTERVAL 160 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 68.5, 'duration_minutes', 30, 'activity_met', 3.5),
 JSON_OBJECT('calories_burned', 120, 'unit', 'kcal', 'activity', 'Walking'),
 DATE_SUB(NOW(), INTERVAL 145 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 67.5, 'duration_minutes', 45, 'activity_met', 7.0),
 JSON_OBJECT('calories_burned', 354, 'unit', 'kcal', 'activity', 'Swimming'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 67.0, 'duration_minutes', 60, 'activity_met', 5.0),
 JSON_OBJECT('calories_burned', 335, 'unit', 'kcal', 'activity', 'Weight Training'),
 DATE_SUB(NOW(), INTERVAL 115 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 66.5, 'duration_minutes', 40, 'activity_met', 6.5),
 JSON_OBJECT('calories_burned', 288, 'unit', 'kcal', 'activity', 'Running'),
 DATE_SUB(NOW(), INTERVAL 100 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 66.0, 'duration_minutes', 50, 'activity_met', 4.0),
 JSON_OBJECT('calories_burned', 220, 'unit', 'kcal', 'activity', 'Yoga'),
 DATE_SUB(NOW(), INTERVAL 85 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 65.5, 'duration_minutes', 45, 'activity_met', 7.5),
 JSON_OBJECT('calories_burned', 369, 'unit', 'kcal', 'activity', 'HIIT'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 65.0, 'duration_minutes', 35, 'activity_met', 6.0),
 JSON_OBJECT('calories_burned', 228, 'unit', 'kcal', 'activity', 'Running'),
 DATE_SUB(NOW(), INTERVAL 55 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 64.5, 'duration_minutes', 55, 'activity_met', 8.5),
 JSON_OBJECT('calories_burned', 502, 'unit', 'kcal', 'activity', 'Cycling'),
 DATE_SUB(NOW(), INTERVAL 40 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 64.0, 'duration_minutes', 30, 'activity_met', 3.5),
 JSON_OBJECT('calories_burned', 112, 'unit', 'kcal', 'activity', 'Walking'),
 DATE_SUB(NOW(), INTERVAL 25 DAY)),

(@user_id, 'CaloriesBurned',
 JSON_OBJECT('weight_kg', 63.8, 'duration_minutes', 45, 'activity_met', 7.0),
 JSON_OBJECT('calories_burned', 335, 'unit', 'kcal', 'activity', 'Swimming'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- OneRepMax Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 80, 'reps', 8),
 JSON_OBJECT('one_rep_max', 100, 'unit', 'kg', 'method', 'Epley'),
 DATE_SUB(NOW(), INTERVAL 165 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 85, 'reps', 6),
 JSON_OBJECT('one_rep_max', 102, 'unit', 'kg', 'method', 'Epley'),
 DATE_SUB(NOW(), INTERVAL 145 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 90, 'reps', 5),
 JSON_OBJECT('one_rep_max', 105, 'unit', 'kg', 'method', 'Epley'),
 DATE_SUB(NOW(), INTERVAL 125 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 95, 'reps', 4),
 JSON_OBJECT('one_rep_max', 108, 'unit', 'kg', 'method', 'Epley'),
 DATE_SUB(NOW(), INTERVAL 105 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 100, 'reps', 3),
 JSON_OBJECT('one_rep_max', 112, 'unit', 'kg', 'method', 'Epley'),
 DATE_SUB(NOW(), INTERVAL 85 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 105, 'reps', 2),
 JSON_OBJECT('one_rep_max', 115, 'unit', 'kg', 'method', 'Epley'),
 DATE_SUB(NOW(), INTERVAL 65 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 110, 'reps', 1),
 JSON_OBJECT('one_rep_max', 110, 'unit', 'kg', 'method', 'Direct'),
 DATE_SUB(NOW(), INTERVAL 45 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 112, 'reps', 1),
 JSON_OBJECT('one_rep_max', 112, 'unit', 'kg', 'method', 'Direct'),
 DATE_SUB(NOW(), INTERVAL 25 DAY)),

(@user_id, 'OneRepMax',
 JSON_OBJECT('weight', 115, 'reps', 1),
 JSON_OBJECT('one_rep_max', 115, 'unit', 'kg', 'method', 'Direct'),
 DATE_SUB(NOW(), INTERVAL 5 DAY));

-- MetabolicAge Calculations (setiap bulan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'MetabolicAge',
 JSON_OBJECT('bmr', 1705, 'age', 29, 'gender', 'male'),
 JSON_OBJECT('metabolic_age', 31, 'actual_age', 29, 'status', 'Older', 'interpretation', 'Metabolic age lebih tua dari usia aktual'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'MetabolicAge',
 JSON_OBJECT('bmr', 1685, 'age', 29, 'gender', 'male'),
 JSON_OBJECT('metabolic_age', 30, 'actual_age', 29, 'status', 'Older', 'interpretation', 'Metabolic age lebih tua dari usia aktual'),
 DATE_SUB(NOW(), INTERVAL 120 DAY)),

(@user_id, 'MetabolicAge',
 JSON_OBJECT('bmr', 1665, 'age', 29, 'gender', 'male'),
 JSON_OBJECT('metabolic_age', 29, 'actual_age', 29, 'status', 'Same', 'interpretation', 'Metabolic age sama dengan usia aktual'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'MetabolicAge',
 JSON_OBJECT('bmr', 1645, 'age', 29, 'gender', 'male'),
 JSON_OBJECT('metabolic_age', 28, 'actual_age', 29, 'status', 'Younger', 'interpretation', 'Metabolic age lebih muda dari usia aktual'),
 DATE_SUB(NOW(), INTERVAL 60 DAY)),

(@user_id, 'MetabolicAge',
 JSON_OBJECT('bmr', 1625, 'age', 29, 'gender', 'male'),
 JSON_OBJECT('metabolic_age', 27, 'actual_age', 29, 'status', 'Younger', 'interpretation', 'Metabolic age lebih muda dari usia aktual'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'MetabolicAge',
 JSON_OBJECT('bmr', 1615, 'age', 29, 'gender', 'male'),
 JSON_OBJECT('metabolic_age', 26, 'actual_age', 29, 'status', 'Younger', 'interpretation', 'Metabolic age lebih muda dari usia aktual'),
 NOW());

-- BodyWater Calculations (setiap 3-4 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'BodyWater',
 JSON_OBJECT('weight_kg', 70.5, 'body_fat_percent', 18.5),
 JSON_OBJECT('body_water_percentage', 58.2, 'water_weight_kg', 41.0, 'unit', '%', 'interpretation', 'Tingkat hidrasi tubuh normal'),
 DATE_SUB(NOW(), INTERVAL 165 DAY)),

(@user_id, 'BodyWater',
 JSON_OBJECT('weight_kg', 69.0, 'body_fat_percent', 17.8),
 JSON_OBJECT('body_water_percentage', 58.8, 'water_weight_kg', 40.6, 'unit', '%', 'interpretation', 'Tingkat hidrasi tubuh normal'),
 DATE_SUB(NOW(), INTERVAL 135 DAY)),

(@user_id, 'BodyWater',
 JSON_OBJECT('weight_kg', 67.5, 'body_fat_percent', 17.2),
 JSON_OBJECT('body_water_percentage', 59.2, 'water_weight_kg', 40.0, 'unit', '%', 'interpretation', 'Tingkat hidrasi tubuh normal'),
 DATE_SUB(NOW(), INTERVAL 105 DAY)),

(@user_id, 'BodyWater',
 JSON_OBJECT('weight_kg', 66.5, 'body_fat_percent', 16.8),
 JSON_OBJECT('body_water_percentage', 59.6, 'water_weight_kg', 39.6, 'unit', '%', 'interpretation', 'Tingkat hidrasi tubuh normal'),
 DATE_SUB(NOW(), INTERVAL 75 DAY)),

(@user_id, 'BodyWater',
 JSON_OBJECT('weight_kg', 66.0, 'body_fat_percent', 16.5),
 JSON_OBJECT('body_water_percentage', 59.9, 'water_weight_kg', 39.5, 'unit', '%', 'interpretation', 'Tingkat hidrasi tubuh normal'),
 DATE_SUB(NOW(), INTERVAL 45 DAY)),

(@user_id, 'BodyWater',
 JSON_OBJECT('weight_kg', 65.5, 'body_fat_percent', 16.1),
 JSON_OBJECT('body_water_percentage', 60.2, 'water_weight_kg', 39.4, 'unit', '%', 'interpretation', 'Tingkat hidrasi tubuh normal'),
 DATE_SUB(NOW(), INTERVAL 15 DAY));

-- Macronutrients Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2400, 'protein_percent', 30, 'carb_percent', 40, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 180, 'calories', 720, 'percent', 30), 'carbohydrates', JSON_OBJECT('grams', 240, 'calories', 960, 'percent', 40), 'fat', JSON_OBJECT('grams', 80, 'calories', 720, 'percent', 30), 'interpretation', 'Distribusi makronutrien seimbang'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2500, 'protein_percent', 35, 'carb_percent', 35, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 219, 'calories', 875, 'percent', 35), 'carbohydrates', JSON_OBJECT('grams', 219, 'calories', 875, 'percent', 35), 'fat', JSON_OBJECT('grams', 83, 'calories', 750, 'percent', 30), 'interpretation', 'Distribusi makronutrien tinggi protein'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2300, 'protein_percent', 30, 'carb_percent', 40, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 173, 'calories', 690, 'percent', 30), 'carbohydrates', JSON_OBJECT('grams', 230, 'calories', 920, 'percent', 40), 'fat', JSON_OBJECT('grams', 77, 'calories', 690, 'percent', 30), 'interpretation', 'Distribusi makronutrien seimbang'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2600, 'protein_percent', 25, 'carb_percent', 45, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 163, 'calories', 650, 'percent', 25), 'carbohydrates', JSON_OBJECT('grams', 293, 'calories', 1170, 'percent', 45), 'fat', JSON_OBJECT('grams', 87, 'calories', 780, 'percent', 30), 'interpretation', 'Distribusi makronutrien tinggi karbohidrat'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2400, 'protein_percent', 30, 'carb_percent', 40, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 180, 'calories', 720, 'percent', 30), 'carbohydrates', JSON_OBJECT('grams', 240, 'calories', 960, 'percent', 40), 'fat', JSON_OBJECT('grams', 80, 'calories', 720, 'percent', 30), 'interpretation', 'Distribusi makronutrien seimbang'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2500, 'protein_percent', 35, 'carb_percent', 35, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 219, 'calories', 875, 'percent', 35), 'carbohydrates', JSON_OBJECT('grams', 219, 'calories', 875, 'percent', 35), 'fat', JSON_OBJECT('grams', 83, 'calories', 750, 'percent', 30), 'interpretation', 'Distribusi makronutrien tinggi protein'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2400, 'protein_percent', 30, 'carb_percent', 40, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 180, 'calories', 720, 'percent', 30), 'carbohydrates', JSON_OBJECT('grams', 240, 'calories', 960, 'percent', 40), 'fat', JSON_OBJECT('grams', 80, 'calories', 720, 'percent', 30), 'interpretation', 'Distribusi makronutrien seimbang'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2600, 'protein_percent', 25, 'carb_percent', 45, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 163, 'calories', 650, 'percent', 25), 'carbohydrates', JSON_OBJECT('grams', 293, 'calories', 1170, 'percent', 45), 'fat', JSON_OBJECT('grams', 87, 'calories', 780, 'percent', 30), 'interpretation', 'Distribusi makronutrien tinggi karbohidrat'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'Macronutrients',
 JSON_OBJECT('calories', 2400, 'protein_percent', 30, 'carb_percent', 40, 'fat_percent', 30),
 JSON_OBJECT('protein', JSON_OBJECT('grams', 180, 'calories', 720, 'percent', 30), 'carbohydrates', JSON_OBJECT('grams', 240, 'calories', 960, 'percent', 40), 'fat', JSON_OBJECT('grams', 80, 'calories', 720, 'percent', 30), 'interpretation', 'Distribusi makronutrien seimbang'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- MAP (Mean Arterial Pressure) Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'MAP',
 JSON_OBJECT('systolic', 120, 'diastolic', 80),
 JSON_OBJECT('map', 93.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 118, 'diastolic', 78),
 JSON_OBJECT('map', 91.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 115, 'diastolic', 75),
 JSON_OBJECT('map', 88.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 117, 'diastolic', 77),
 JSON_OBJECT('map', 90.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 116, 'diastolic', 76),
 JSON_OBJECT('map', 89.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 114, 'diastolic', 74),
 JSON_OBJECT('map', 87.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 115, 'diastolic', 75),
 JSON_OBJECT('map', 88.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 113, 'diastolic', 73),
 JSON_OBJECT('map', 86.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'MAP',
 JSON_OBJECT('systolic', 112, 'diastolic', 72),
 JSON_OBJECT('map', 85.3, 'unit', 'mmHg', 'status', 'Normal', 'interpretation', 'Tekanan darah arteri rata-rata normal'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- BodySurfaceArea Calculations (setiap bulan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'BodySurfaceArea',
 JSON_OBJECT('weight_kg', 70.5, 'height_cm', 172),
 JSON_OBJECT('bsa', 1.85, 'unit', 'm²', 'method', 'Du Bois'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'BodySurfaceArea',
 JSON_OBJECT('weight_kg', 69.0, 'height_cm', 172),
 JSON_OBJECT('bsa', 1.83, 'unit', 'm²', 'method', 'Du Bois'),
 DATE_SUB(NOW(), INTERVAL 120 DAY)),

(@user_id, 'BodySurfaceArea',
 JSON_OBJECT('weight_kg', 67.5, 'height_cm', 172),
 JSON_OBJECT('bsa', 1.81, 'unit', 'm²', 'method', 'Du Bois'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'BodySurfaceArea',
 JSON_OBJECT('weight_kg', 66.5, 'height_cm', 172),
 JSON_OBJECT('bsa', 1.79, 'unit', 'm²', 'method', 'Du Bois'),
 DATE_SUB(NOW(), INTERVAL 60 DAY)),

(@user_id, 'BodySurfaceArea',
 JSON_OBJECT('weight_kg', 65.5, 'height_cm', 172),
 JSON_OBJECT('bsa', 1.77, 'unit', 'm²', 'method', 'Du Bois'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'BodySurfaceArea',
 JSON_OBJECT('weight_kg', 65.5, 'height_cm', 172),
 JSON_OBJECT('bsa', 1.77, 'unit', 'm²', 'method', 'Du Bois'),
 NOW());

-- TargetHeartRate Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'moderate'),
 JSON_OBJECT('target_hr_min', 114, 'target_hr_max', 152, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '60-80%'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'vigorous'),
 JSON_OBJECT('target_hr_min', 152, 'target_hr_max', 172, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '80-90%'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'moderate'),
 JSON_OBJECT('target_hr_min', 114, 'target_hr_max', 152, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '60-80%'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'light'),
 JSON_OBJECT('target_hr_min', 95, 'target_hr_max', 114, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '50-60%'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'moderate'),
 JSON_OBJECT('target_hr_min', 114, 'target_hr_max', 152, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '60-80%'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'vigorous'),
 JSON_OBJECT('target_hr_min', 152, 'target_hr_max', 172, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '80-90%'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'moderate'),
 JSON_OBJECT('target_hr_min', 114, 'target_hr_max', 152, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '60-80%'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'light'),
 JSON_OBJECT('target_hr_min', 95, 'target_hr_max', 114, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '50-60%'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'TargetHeartRate',
 JSON_OBJECT('age', 29, 'intensity', 'moderate'),
 JSON_OBJECT('target_hr_min', 114, 'target_hr_max', 152, 'max_hr', 191, 'unit', 'bpm', 'intensity_percent', '60-80%'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- WaistToHeight Calculations (setiap bulan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'WaistToHeight',
 JSON_OBJECT('waist_cm', 85, 'height_cm', 172),
 JSON_OBJECT('waist_to_height_ratio', 0.494, 'status', 'Normal', 'interpretation', 'Rasio pinggang-tinggi normal'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'WaistToHeight',
 JSON_OBJECT('waist_cm', 84, 'height_cm', 172),
 JSON_OBJECT('waist_to_height_ratio', 0.488, 'status', 'Normal', 'interpretation', 'Rasio pinggang-tinggi normal'),
 DATE_SUB(NOW(), INTERVAL 120 DAY)),

(@user_id, 'WaistToHeight',
 JSON_OBJECT('waist_cm', 82, 'height_cm', 172),
 JSON_OBJECT('waist_to_height_ratio', 0.477, 'status', 'Normal', 'interpretation', 'Rasio pinggang-tinggi normal'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'WaistToHeight',
 JSON_OBJECT('waist_cm', 81, 'height_cm', 172),
 JSON_OBJECT('waist_to_height_ratio', 0.471, 'status', 'Normal', 'interpretation', 'Rasio pinggang-tinggi normal'),
 DATE_SUB(NOW(), INTERVAL 60 DAY)),

(@user_id, 'WaistToHeight',
 JSON_OBJECT('waist_cm', 80, 'height_cm', 172),
 JSON_OBJECT('waist_to_height_ratio', 0.465, 'status', 'Normal', 'interpretation', 'Rasio pinggang-tinggi normal'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'WaistToHeight',
 JSON_OBJECT('waist_cm', 79, 'height_cm', 172),
 JSON_OBJECT('waist_to_height_ratio', 0.460, 'status', 'Normal', 'interpretation', 'Rasio pinggang-tinggi normal'),
 NOW());

-- DailyCalories Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2400, 'goal', 'maintenance'),
 JSON_OBJECT('daily_calories', 2400, 'unit', 'kcal/day', 'goal', 'maintenance', 'interpretation', 'Kalori harian untuk maintenance'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2500, 'goal', 'weight_loss'),
 JSON_OBJECT('daily_calories', 2000, 'unit', 'kcal/day', 'goal', 'weight_loss', 'deficit', 500, 'interpretation', 'Kalori harian untuk weight loss (deficit 500 kcal)'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2400, 'goal', 'maintenance'),
 JSON_OBJECT('daily_calories', 2400, 'unit', 'kcal/day', 'goal', 'maintenance', 'interpretation', 'Kalori harian untuk maintenance'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2600, 'goal', 'weight_loss'),
 JSON_OBJECT('daily_calories', 2100, 'unit', 'kcal/day', 'goal', 'weight_loss', 'deficit', 500, 'interpretation', 'Kalori harian untuk weight loss (deficit 500 kcal)'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2500, 'goal', 'weight_loss'),
 JSON_OBJECT('daily_calories', 2000, 'unit', 'kcal/day', 'goal', 'weight_loss', 'deficit', 500, 'interpretation', 'Kalori harian untuk weight loss (deficit 500 kcal)'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2400, 'goal', 'maintenance'),
 JSON_OBJECT('daily_calories', 2400, 'unit', 'kcal/day', 'goal', 'maintenance', 'interpretation', 'Kalori harian untuk maintenance'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2600, 'goal', 'weight_loss'),
 JSON_OBJECT('daily_calories', 2100, 'unit', 'kcal/day', 'goal', 'weight_loss', 'deficit', 500, 'interpretation', 'Kalori harian untuk weight loss (deficit 500 kcal)'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2400, 'goal', 'maintenance'),
 JSON_OBJECT('daily_calories', 2400, 'unit', 'kcal/day', 'goal', 'maintenance', 'interpretation', 'Kalori harian untuk maintenance'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'DailyCalories',
 JSON_OBJECT('tdee', 2500, 'goal', 'weight_loss'),
 JSON_OBJECT('daily_calories', 2000, 'unit', 'kcal/day', 'goal', 'weight_loss', 'deficit', 500, 'interpretation', 'Kalori harian untuk weight loss (deficit 500 kcal)'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- WaterNeeds Calculations (setiap 2-3 minggu)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 70.5, 'activity_level', 'moderate'),
 JSON_OBJECT('water_needs_ml', 2820, 'water_needs_liters', 2.82, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas sedang'),
 DATE_SUB(NOW(), INTERVAL 170 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 69.5, 'activity_level', 'active'),
 JSON_OBJECT('water_needs_ml', 3120, 'water_needs_liters', 3.12, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas aktif'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 68.5, 'activity_level', 'moderate'),
 JSON_OBJECT('water_needs_ml', 2740, 'water_needs_liters', 2.74, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas sedang'),
 DATE_SUB(NOW(), INTERVAL 130 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 67.5, 'activity_level', 'very_active'),
 JSON_OBJECT('water_needs_ml', 3380, 'water_needs_liters', 3.38, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas sangat aktif'),
 DATE_SUB(NOW(), INTERVAL 110 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 67.0, 'activity_level', 'active'),
 JSON_OBJECT('water_needs_ml', 3010, 'water_needs_liters', 3.01, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas aktif'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 66.5, 'activity_level', 'moderate'),
 JSON_OBJECT('water_needs_ml', 2660, 'water_needs_liters', 2.66, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas sedang'),
 DATE_SUB(NOW(), INTERVAL 70 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 66.0, 'activity_level', 'very_active'),
 JSON_OBJECT('water_needs_ml', 3300, 'water_needs_liters', 3.30, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas sangat aktif'),
 DATE_SUB(NOW(), INTERVAL 50 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 65.5, 'activity_level', 'active'),
 JSON_OBJECT('water_needs_ml', 2940, 'water_needs_liters', 2.94, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas aktif'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'WaterNeeds',
 JSON_OBJECT('weight_kg', 65.0, 'activity_level', 'moderate'),
 JSON_OBJECT('water_needs_ml', 2600, 'water_needs_liters', 2.60, 'unit', 'ml/day', 'interpretation', 'Kebutuhan air harian untuk aktivitas sedang'),
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- WaistToHip Calculations (setiap bulan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'WaistToHip',
 JSON_OBJECT('waist_cm', 85, 'hip_cm', 95),
 JSON_OBJECT('waist_to_hip_ratio', 0.895, 'risk_level', 'Low', 'interpretation', 'Rasio pinggang-pinggul normal, risiko rendah'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'WaistToHip',
 JSON_OBJECT('waist_cm', 84, 'hip_cm', 94),
 JSON_OBJECT('waist_to_hip_ratio', 0.894, 'risk_level', 'Low', 'interpretation', 'Rasio pinggang-pinggul normal, risiko rendah'),
 DATE_SUB(NOW(), INTERVAL 120 DAY)),

(@user_id, 'WaistToHip',
 JSON_OBJECT('waist_cm', 82, 'hip_cm', 93),
 JSON_OBJECT('waist_to_hip_ratio', 0.882, 'risk_level', 'Low', 'interpretation', 'Rasio pinggang-pinggul normal, risiko rendah'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'WaistToHip',
 JSON_OBJECT('waist_cm', 81, 'hip_cm', 92),
 JSON_OBJECT('waist_to_hip_ratio', 0.880, 'risk_level', 'Low', 'interpretation', 'Rasio pinggang-pinggul normal, risiko rendah'),
 DATE_SUB(NOW(), INTERVAL 60 DAY)),

(@user_id, 'WaistToHip',
 JSON_OBJECT('waist_cm', 80, 'hip_cm', 91),
 JSON_OBJECT('waist_to_hip_ratio', 0.879, 'risk_level', 'Low', 'interpretation', 'Rasio pinggang-pinggul normal, risiko rendah'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'WaistToHip',
 JSON_OBJECT('waist_cm', 79, 'hip_cm', 90),
 JSON_OBJECT('waist_to_hip_ratio', 0.878, 'risk_level', 'Low', 'interpretation', 'Rasio pinggang-pinggul normal, risiko rendah'),
 NOW());

-- MaxHeartRate Calculations (setiap 2-3 bulan)
INSERT INTO health_calculations (user_id, calculation_type, input_data, result_data, calculated_at) VALUES
(@user_id, 'MaxHeartRate',
 JSON_OBJECT('age', 29),
 JSON_OBJECT('max_hr', 191, 'unit', 'bpm', 'method', '220 - age', 'interpretation', 'Maksimum heart rate berdasarkan usia'),
 DATE_SUB(NOW(), INTERVAL 150 DAY)),

(@user_id, 'MaxHeartRate',
 JSON_OBJECT('age', 29),
 JSON_OBJECT('max_hr', 191, 'unit', 'bpm', 'method', '220 - age', 'interpretation', 'Maksimum heart rate berdasarkan usia'),
 DATE_SUB(NOW(), INTERVAL 90 DAY)),

(@user_id, 'MaxHeartRate',
 JSON_OBJECT('age', 29),
 JSON_OBJECT('max_hr', 191, 'unit', 'bpm', 'method', '220 - age', 'interpretation', 'Maksimum heart rate berdasarkan usia'),
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(@user_id, 'MaxHeartRate',
 JSON_OBJECT('age', 29),
 JSON_OBJECT('max_hr', 191, 'unit', 'bpm', 'method', '220 - age', 'interpretation', 'Maksimum heart rate berdasarkan usia'),
 NOW());

-- ============================================
-- 2. Health Metrics History - Data 6 Bulan
-- ============================================
-- Data tracking harian/mingguan untuk berbagai metrik kesehatan

-- Weight tracking (setiap minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'Weight', 70.5, 'kg', DATE_SUB(NOW(), INTERVAL 180 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 70.2, 'kg', DATE_SUB(NOW(), INTERVAL 173 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 69.8, 'kg', DATE_SUB(NOW(), INTERVAL 166 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 69.5, 'kg', DATE_SUB(NOW(), INTERVAL 159 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 69.2, 'kg', DATE_SUB(NOW(), INTERVAL 152 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 69.0, 'kg', DATE_SUB(NOW(), INTERVAL 145 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 68.8, 'kg', DATE_SUB(NOW(), INTERVAL 138 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 68.5, 'kg', DATE_SUB(NOW(), INTERVAL 131 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 68.3, 'kg', DATE_SUB(NOW(), INTERVAL 124 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 68.0, 'kg', DATE_SUB(NOW(), INTERVAL 117 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 67.8, 'kg', DATE_SUB(NOW(), INTERVAL 110 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 67.5, 'kg', DATE_SUB(NOW(), INTERVAL 103 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 67.2, 'kg', DATE_SUB(NOW(), INTERVAL 96 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 67.0, 'kg', DATE_SUB(NOW(), INTERVAL 89 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 66.8, 'kg', DATE_SUB(NOW(), INTERVAL 82 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 66.5, 'kg', DATE_SUB(NOW(), INTERVAL 75 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 66.3, 'kg', DATE_SUB(NOW(), INTERVAL 68 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 66.0, 'kg', DATE_SUB(NOW(), INTERVAL 61 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 65.8, 'kg', DATE_SUB(NOW(), INTERVAL 54 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 65.5, 'kg', DATE_SUB(NOW(), INTERVAL 47 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 65.3, 'kg', DATE_SUB(NOW(), INTERVAL 40 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 65.0, 'kg', DATE_SUB(NOW(), INTERVAL 33 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 64.8, 'kg', DATE_SUB(NOW(), INTERVAL 26 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 64.5, 'kg', DATE_SUB(NOW(), INTERVAL 19 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 64.3, 'kg', DATE_SUB(NOW(), INTERVAL 12 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 64.0, 'kg', DATE_SUB(NOW(), INTERVAL 5 DAY), 'Pengukuran berat badan mingguan'),
(@user_id, 'Weight', 63.8, 'kg', NOW(), 'Pengukuran berat badan mingguan');

-- BMI tracking (setiap minggu, sesuai dengan weight)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'BMI', 23.8, '', DATE_SUB(NOW(), INTERVAL 180 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.7, '', DATE_SUB(NOW(), INTERVAL 173 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.6, '', DATE_SUB(NOW(), INTERVAL 166 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.5, '', DATE_SUB(NOW(), INTERVAL 159 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.4, '', DATE_SUB(NOW(), INTERVAL 152 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.3, '', DATE_SUB(NOW(), INTERVAL 145 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.2, '', DATE_SUB(NOW(), INTERVAL 138 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.1, '', DATE_SUB(NOW(), INTERVAL 131 DAY), 'BMI calculation'),
(@user_id, 'BMI', 23.0, '', DATE_SUB(NOW(), INTERVAL 124 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.9, '', DATE_SUB(NOW(), INTERVAL 117 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.9, '', DATE_SUB(NOW(), INTERVAL 110 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.8, '', DATE_SUB(NOW(), INTERVAL 103 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.7, '', DATE_SUB(NOW(), INTERVAL 96 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.6, '', DATE_SUB(NOW(), INTERVAL 89 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.5, '', DATE_SUB(NOW(), INTERVAL 82 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.4, '', DATE_SUB(NOW(), INTERVAL 75 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.3, '', DATE_SUB(NOW(), INTERVAL 68 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.2, '', DATE_SUB(NOW(), INTERVAL 61 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.2, '', DATE_SUB(NOW(), INTERVAL 54 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.1, '', DATE_SUB(NOW(), INTERVAL 47 DAY), 'BMI calculation'),
(@user_id, 'BMI', 22.0, '', DATE_SUB(NOW(), INTERVAL 40 DAY), 'BMI calculation'),
(@user_id, 'BMI', 21.9, '', DATE_SUB(NOW(), INTERVAL 33 DAY), 'BMI calculation'),
(@user_id, 'BMI', 21.8, '', DATE_SUB(NOW(), INTERVAL 26 DAY), 'BMI calculation'),
(@user_id, 'BMI', 21.7, '', DATE_SUB(NOW(), INTERVAL 19 DAY), 'BMI calculation'),
(@user_id, 'BMI', 21.6, '', DATE_SUB(NOW(), INTERVAL 12 DAY), 'BMI calculation'),
(@user_id, 'BMI', 21.5, '', DATE_SUB(NOW(), INTERVAL 5 DAY), 'BMI calculation'),
(@user_id, 'BMI', 21.5, '', NOW(), 'BMI calculation');

-- BodyFat tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'BodyFat', 18.5, '%', DATE_SUB(NOW(), INTERVAL 165 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 18.2, '%', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 17.8, '%', DATE_SUB(NOW(), INTERVAL 135 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 17.5, '%', DATE_SUB(NOW(), INTERVAL 120 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 17.2, '%', DATE_SUB(NOW(), INTERVAL 105 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 16.8, '%', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 16.5, '%', DATE_SUB(NOW(), INTERVAL 75 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 16.3, '%', DATE_SUB(NOW(), INTERVAL 60 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 16.2, '%', DATE_SUB(NOW(), INTERVAL 45 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 16.1, '%', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 16.0, '%', DATE_SUB(NOW(), INTERVAL 15 DAY), 'Body fat measurement'),
(@user_id, 'BodyFat', 15.9, '%', NOW(), 'Body fat measurement');

-- BMR tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'BMR', 1705, 'kcal/day', DATE_SUB(NOW(), INTERVAL 175 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1695, 'kcal/day', DATE_SUB(NOW(), INTERVAL 155 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1685, 'kcal/day', DATE_SUB(NOW(), INTERVAL 135 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1675, 'kcal/day', DATE_SUB(NOW(), INTERVAL 115 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1665, 'kcal/day', DATE_SUB(NOW(), INTERVAL 95 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1655, 'kcal/day', DATE_SUB(NOW(), INTERVAL 75 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1645, 'kcal/day', DATE_SUB(NOW(), INTERVAL 55 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1635, 'kcal/day', DATE_SUB(NOW(), INTERVAL 35 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1625, 'kcal/day', DATE_SUB(NOW(), INTERVAL 15 DAY), 'BMR calculation'),
(@user_id, 'BMR', 1615, 'kcal/day', NOW(), 'BMR calculation');

-- TDEE tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'TDEE', 2344, 'kcal/day', DATE_SUB(NOW(), INTERVAL 173 DAY), 'TDEE calculation - moderate activity'),
(@user_id, 'TDEE', 2523, 'kcal/day', DATE_SUB(NOW(), INTERVAL 153 DAY), 'TDEE calculation - active'),
(@user_id, 'TDEE', 2701, 'kcal/day', DATE_SUB(NOW(), INTERVAL 133 DAY), 'TDEE calculation - very active'),
(@user_id, 'TDEE', 2468, 'kcal/day', DATE_SUB(NOW(), INTERVAL 113 DAY), 'TDEE calculation - active'),
(@user_id, 'TDEE', 2657, 'kcal/day', DATE_SUB(NOW(), INTERVAL 93 DAY), 'TDEE calculation - very active'),
(@user_id, 'TDEE', 2641, 'kcal/day', DATE_SUB(NOW(), INTERVAL 73 DAY), 'TDEE calculation - very active'),
(@user_id, 'TDEE', 2423, 'kcal/day', DATE_SUB(NOW(), INTERVAL 53 DAY), 'TDEE calculation - active'),
(@user_id, 'TDEE', 2616, 'kcal/day', DATE_SUB(NOW(), INTERVAL 33 DAY), 'TDEE calculation - very active'),
(@user_id, 'TDEE', 2608, 'kcal/day', DATE_SUB(NOW(), INTERVAL 13 DAY), 'TDEE calculation - very active'),
(@user_id, 'TDEE', 2408, 'kcal/day', NOW(), 'TDEE calculation - active');

-- HeartRate tracking (setiap beberapa hari)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'HeartRate', 72, 'bpm', DATE_SUB(NOW(), INTERVAL 180 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 70, 'bpm', DATE_SUB(NOW(), INTERVAL 160 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 68, 'bpm', DATE_SUB(NOW(), INTERVAL 140 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 69, 'bpm', DATE_SUB(NOW(), INTERVAL 120 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 67, 'bpm', DATE_SUB(NOW(), INTERVAL 100 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 66, 'bpm', DATE_SUB(NOW(), INTERVAL 80 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 65, 'bpm', DATE_SUB(NOW(), INTERVAL 60 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 64, 'bpm', DATE_SUB(NOW(), INTERVAL 40 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 63, 'bpm', DATE_SUB(NOW(), INTERVAL 20 DAY), 'Resting heart rate'),
(@user_id, 'HeartRate', 62, 'bpm', NOW(), 'Resting heart rate');

-- VO2Max tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'VO2Max', 42.5, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 170 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 43.2, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 150 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 44.1, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 130 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 44.8, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 110 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 45.5, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 90 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 46.2, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 70 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 46.9, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 50 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 47.6, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 30 DAY), 'VO2Max measurement'),
(@user_id, 'VO2Max', 48.3, 'ml/kg/min', DATE_SUB(NOW(), INTERVAL 10 DAY), 'VO2Max measurement');

-- MAP tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'MAP', 93.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 170 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 91.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 88.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 130 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 90.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 110 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 89.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 87.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 70 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 88.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 50 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 86.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Mean arterial pressure'),
(@user_id, 'MAP', 85.3, 'mmHg', DATE_SUB(NOW(), INTERVAL 10 DAY), 'Mean arterial pressure');

-- WaistToHip tracking (setiap bulan)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'WaistToHip', 0.895, '', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Waist to hip ratio'),
(@user_id, 'WaistToHip', 0.894, '', DATE_SUB(NOW(), INTERVAL 120 DAY), 'Waist to hip ratio'),
(@user_id, 'WaistToHip', 0.882, '', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Waist to hip ratio'),
(@user_id, 'WaistToHip', 0.880, '', DATE_SUB(NOW(), INTERVAL 60 DAY), 'Waist to hip ratio'),
(@user_id, 'WaistToHip', 0.879, '', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Waist to hip ratio'),
(@user_id, 'WaistToHip', 0.878, '', NOW(), 'Waist to hip ratio');

-- WaistToHeight tracking (setiap bulan)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'WaistToHeight', 0.494, '', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Waist to height ratio'),
(@user_id, 'WaistToHeight', 0.488, '', DATE_SUB(NOW(), INTERVAL 120 DAY), 'Waist to height ratio'),
(@user_id, 'WaistToHeight', 0.477, '', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Waist to height ratio'),
(@user_id, 'WaistToHeight', 0.471, '', DATE_SUB(NOW(), INTERVAL 60 DAY), 'Waist to height ratio'),
(@user_id, 'WaistToHeight', 0.465, '', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Waist to height ratio'),
(@user_id, 'WaistToHeight', 0.460, '', NOW(), 'Waist to height ratio');

-- MaxHeartRate tracking (setiap 2-3 bulan)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'MaxHeartRate', 191, 'bpm', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Maximum heart rate'),
(@user_id, 'MaxHeartRate', 191, 'bpm', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Maximum heart rate'),
(@user_id, 'MaxHeartRate', 191, 'bpm', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Maximum heart rate'),
(@user_id, 'MaxHeartRate', 191, 'bpm', NOW(), 'Maximum heart rate');

-- TargetHeartRate tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'TargetHeartRate', 133, 'bpm', DATE_SUB(NOW(), INTERVAL 170 DAY), 'Target heart rate (moderate)'),
(@user_id, 'TargetHeartRate', 162, 'bpm', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Target heart rate (vigorous)'),
(@user_id, 'TargetHeartRate', 133, 'bpm', DATE_SUB(NOW(), INTERVAL 130 DAY), 'Target heart rate (moderate)'),
(@user_id, 'TargetHeartRate', 105, 'bpm', DATE_SUB(NOW(), INTERVAL 110 DAY), 'Target heart rate (light)'),
(@user_id, 'TargetHeartRate', 133, 'bpm', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Target heart rate (moderate)'),
(@user_id, 'TargetHeartRate', 162, 'bpm', DATE_SUB(NOW(), INTERVAL 70 DAY), 'Target heart rate (vigorous)'),
(@user_id, 'TargetHeartRate', 133, 'bpm', DATE_SUB(NOW(), INTERVAL 50 DAY), 'Target heart rate (moderate)'),
(@user_id, 'TargetHeartRate', 105, 'bpm', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Target heart rate (light)'),
(@user_id, 'TargetHeartRate', 133, 'bpm', DATE_SUB(NOW(), INTERVAL 10 DAY), 'Target heart rate (moderate)');

-- WaterNeeds tracking (setiap 2-3 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'WaterNeeds', 2820, 'ml/day', DATE_SUB(NOW(), INTERVAL 170 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 3120, 'ml/day', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 2740, 'ml/day', DATE_SUB(NOW(), INTERVAL 130 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 3380, 'ml/day', DATE_SUB(NOW(), INTERVAL 110 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 3010, 'ml/day', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 2660, 'ml/day', DATE_SUB(NOW(), INTERVAL 70 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 3300, 'ml/day', DATE_SUB(NOW(), INTERVAL 50 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 2940, 'ml/day', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Daily water needs'),
(@user_id, 'WaterNeeds', 2600, 'ml/day', DATE_SUB(NOW(), INTERVAL 10 DAY), 'Daily water needs');

-- CaloriesBurned tracking (setiap 1-2 minggu)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'CaloriesBurned', 318, 'kcal', DATE_SUB(NOW(), INTERVAL 175 DAY), 'Calories burned - Running'),
(@user_id, 'CaloriesBurned', 556, 'kcal', DATE_SUB(NOW(), INTERVAL 160 DAY), 'Calories burned - Cycling'),
(@user_id, 'CaloriesBurned', 120, 'kcal', DATE_SUB(NOW(), INTERVAL 145 DAY), 'Calories burned - Walking'),
(@user_id, 'CaloriesBurned', 354, 'kcal', DATE_SUB(NOW(), INTERVAL 130 DAY), 'Calories burned - Swimming'),
(@user_id, 'CaloriesBurned', 335, 'kcal', DATE_SUB(NOW(), INTERVAL 115 DAY), 'Calories burned - Weight Training'),
(@user_id, 'CaloriesBurned', 288, 'kcal', DATE_SUB(NOW(), INTERVAL 100 DAY), 'Calories burned - Running'),
(@user_id, 'CaloriesBurned', 220, 'kcal', DATE_SUB(NOW(), INTERVAL 85 DAY), 'Calories burned - Yoga'),
(@user_id, 'CaloriesBurned', 369, 'kcal', DATE_SUB(NOW(), INTERVAL 70 DAY), 'Calories burned - HIIT'),
(@user_id, 'CaloriesBurned', 228, 'kcal', DATE_SUB(NOW(), INTERVAL 55 DAY), 'Calories burned - Running'),
(@user_id, 'CaloriesBurned', 502, 'kcal', DATE_SUB(NOW(), INTERVAL 40 DAY), 'Calories burned - Cycling'),
(@user_id, 'CaloriesBurned', 112, 'kcal', DATE_SUB(NOW(), INTERVAL 25 DAY), 'Calories burned - Walking'),
(@user_id, 'CaloriesBurned', 335, 'kcal', DATE_SUB(NOW(), INTERVAL 10 DAY), 'Calories burned - Swimming');

-- BodySurfaceArea tracking (setiap bulan)
INSERT INTO health_metrics_history (user_id, metric_type, metric_value, unit, recorded_at, notes) VALUES
(@user_id, 'BodySurfaceArea', 1.85, 'm²', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Body surface area'),
(@user_id, 'BodySurfaceArea', 1.83, 'm²', DATE_SUB(NOW(), INTERVAL 120 DAY), 'Body surface area'),
(@user_id, 'BodySurfaceArea', 1.81, 'm²', DATE_SUB(NOW(), INTERVAL 90 DAY), 'Body surface area'),
(@user_id, 'BodySurfaceArea', 1.79, 'm²', DATE_SUB(NOW(), INTERVAL 60 DAY), 'Body surface area'),
(@user_id, 'BodySurfaceArea', 1.77, 'm²', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Body surface area'),
(@user_id, 'BodySurfaceArea', 1.77, 'm²', NOW(), 'Body surface area');

-- ============================================
-- Verifikasi Data
-- ============================================
SELECT 
    'Data inserted successfully!' AS status,
    @user_id AS user_id,
    (SELECT name FROM users WHERE id = @user_id) AS user_name,
    (SELECT email FROM users WHERE id = @user_id) AS user_email,
    (SELECT COUNT(*) FROM health_calculations WHERE user_id = @user_id) AS health_calculations_count,
    (SELECT COUNT(*) FROM health_metrics_history WHERE user_id = @user_id) AS health_metrics_count,
    (SELECT MIN(calculated_at) FROM health_calculations WHERE user_id = @user_id) AS earliest_calculation,
    (SELECT MAX(calculated_at) FROM health_calculations WHERE user_id = @user_id) AS latest_calculation,
    (SELECT MIN(recorded_at) FROM health_metrics_history WHERE user_id = @user_id) AS earliest_metric,
    (SELECT MAX(recorded_at) FROM health_metrics_history WHERE user_id = @user_id) AS latest_metric;

-- Summary by calculation type
SELECT 
    calculation_type,
    COUNT(*) AS count,
    MIN(calculated_at) AS first_calculation,
    MAX(calculated_at) AS last_calculation
FROM health_calculations 
WHERE user_id = @user_id 
GROUP BY calculation_type
ORDER BY calculation_type;

-- Summary by metric type
SELECT 
    metric_type,
    COUNT(*) AS count,
    AVG(metric_value) AS avg_value,
    MIN(metric_value) AS min_value,
    MAX(metric_value) AS max_value,
    MIN(recorded_at) AS first_record,
    MAX(recorded_at) AS last_record
FROM health_metrics_history 
WHERE user_id = @user_id 
GROUP BY metric_type
ORDER BY metric_type;

