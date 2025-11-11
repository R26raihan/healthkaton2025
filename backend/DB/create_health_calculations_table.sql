-- ============================================
-- Health Calculations Table
-- Menyimpan hasil perhitungan kesehatan pengguna
-- ============================================

USE healthkon_bpjs;

CREATE TABLE IF NOT EXISTS health_calculations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    calculation_type VARCHAR(50) NOT NULL COMMENT 'BMI, BMR, TDEE, BodyFat, dll',
    input_data JSON NOT NULL COMMENT 'Data input untuk perhitungan (height, weight, age, dll)',
    result_data JSON NOT NULL COMMENT 'Hasil perhitungan dan detail',
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_calculation_type (calculation_type),
    INDEX idx_calculated_at (calculated_at),
    INDEX idx_user_calculation_type (user_id, calculation_type),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Health Metrics History Table
-- Menyimpan riwayat metrik kesehatan untuk tracking dan statistik
-- ============================================

CREATE TABLE IF NOT EXISTS health_metrics_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    metric_type VARCHAR(50) NOT NULL COMMENT 'BMI, Weight, BodyFat, HeartRate, BMR, TDEE, dll',
    metric_value DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL COMMENT 'kg, cm, bpm, %, kcal/day, dll',
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    
    INDEX idx_user_id (user_id),
    INDEX idx_metric_type (metric_type),
    INDEX idx_recorded_at (recorded_at),
    INDEX idx_user_metric_type (user_id, metric_type),
    INDEX idx_user_recorded_at (user_id, recorded_at),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

