-- Medical Records Service Tables
-- Run this after users table is created

USE healthkon;

-- 1. Medical Records (Header)
CREATE TABLE IF NOT EXISTS medical_records (
    record_id CHAR(36) PRIMARY KEY,  -- UUID as CHAR(36)
    patient_id INT NOT NULL,          -- FK to users.id
    visit_date DATETIME NOT NULL,
    visit_type ENUM('outpatient', 'inpatient', 'emergency') NOT NULL,
    diagnosis_summary TEXT,
    notes TEXT,
    doctor_name VARCHAR(255),
    facility_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_patient_id (patient_id),
    INDEX idx_visit_date (visit_date),
    INDEX idx_visit_type (visit_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Diagnoses (Multi diagnosis per kunjungan)
CREATE TABLE IF NOT EXISTS diagnoses (
    diagnosis_id CHAR(36) PRIMARY KEY,  -- UUID
    record_id CHAR(36) NOT NULL,         -- FK to medical_records
    icd_code VARCHAR(20),
    diagnosis_name VARCHAR(255) NOT NULL,
    primary_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE CASCADE,
    INDEX idx_record_id (record_id),
    INDEX idx_icd_code (icd_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Prescriptions (Resep obat)
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id CHAR(36) PRIMARY KEY,  -- UUID
    record_id CHAR(36) NOT NULL,          -- FK to medical_records
    drug_name VARCHAR(255) NOT NULL,
    drug_code VARCHAR(50),
    dosage VARCHAR(100),
    frequency VARCHAR(100),               -- Contoh: 3x sehari
    duration_days INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE CASCADE,
    INDEX idx_record_id (record_id),
    INDEX idx_drug_name (drug_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Lab Results (Hasil pemeriksaan lab)
CREATE TABLE IF NOT EXISTS lab_results (
    lab_id CHAR(36) PRIMARY KEY,     -- UUID
    record_id CHAR(36) NOT NULL,     -- FK to medical_records
    test_name VARCHAR(255) NOT NULL, -- Contoh: HbA1c
    result_value VARCHAR(255),
    result_unit VARCHAR(50),         -- mg/dl, %, dll
    normal_range VARCHAR(100),      -- Opsional
    interpretation TEXT,             -- Opsional
    attachment_url TEXT,              -- File lab, opsional
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE CASCADE,
    INDEX idx_record_id (record_id),
    INDEX idx_test_name (test_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Allergies (Alergi pasien)
CREATE TABLE IF NOT EXISTS allergies (
    allergy_id CHAR(36) PRIMARY KEY,  -- UUID
    patient_id INT NOT NULL,           -- FK to users.id
    allergy_name VARCHAR(255) NOT NULL, -- Contoh: Penicillin
    severity ENUM('low', 'moderate', 'high') DEFAULT 'moderate',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_patient_id (patient_id),
    INDEX idx_allergy_name (allergy_name),
    INDEX idx_severity (severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Medical Documents (Unggahan file rekam medis)
CREATE TABLE IF NOT EXISTS medical_documents (
    doc_id CHAR(36) PRIMARY KEY,    -- UUID
    patient_id INT NOT NULL,         -- FK to users.id
    record_id CHAR(36),             -- FK to medical_records (optional)
    file_type ENUM('pdf', 'image') NOT NULL,
    file_url TEXT NOT NULL,          -- Storage URL
    extract_text LONGTEXT,           -- Hasil OCR untuk RAG
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE SET NULL,
    INDEX idx_patient_id (patient_id),
    INDEX idx_record_id (record_id),
    INDEX idx_file_type (file_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

