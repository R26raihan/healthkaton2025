-- ============================================================================
-- SQL Script: Insert Dummy Medical Data for 100 Users
-- ============================================================================
-- Purpose: Generate realistic dummy data for testing RAG service
--          Creates medical records, diagnoses, prescriptions, lab results,
--          allergies, and medical documents for 100 users
--
-- Usage: Run this AFTER creating all tables and indexes
--        mysql -u root -p < DB/insert_dummy_medical_data_100_users.sql
-- ============================================================================

USE healthkon;

-- ============================================================================
-- Helper Functions (if not exists)
-- ============================================================================

-- Function to generate UUID (MySQL 8.0+)
-- For older MySQL versions, use UUID() function directly
SET @uuid_function = IF(
    (SELECT VERSION()) >= '8.0.0',
    'UUID()',
    'UUID()'
);

-- ============================================================================
-- 1. INSERT DUMMY USERS (if users table is empty or you want to add more)
-- ============================================================================
-- Note: Adjust this section based on your existing users
-- This assumes you already have at least 100 users in the users table
-- If not, uncomment and modify the INSERT statements below

/*
-- Generate 100 dummy users (if needed)
-- Note: Passwords are hashed with bcrypt (example: $2b$12$...)
-- You should use actual password hashing in production

INSERT INTO users (name, email, password, phoneNumber, ktpNumber, kkNumber, is_active, created_at)
SELECT 
    CONCAT('User ', n) AS name,
    CONCAT('user', n, '@example.com') AS email,
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5HyvjF5Y5Q5Xe' AS password, -- password: "password123"
    CONCAT('08', LPAD(n, 10, '0')) AS phoneNumber,
    LPAD(n, 16, '0') AS ktpNumber,
    LPAD((n % 10) + 1, 16, '0') AS kkNumber,
    1 AS is_active,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY) AS created_at
FROM (
    SELECT @row := @row + 1 AS n
    FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
         (SELECT @row := 0) r
    LIMIT 100
) numbers;
*/

-- ============================================================================
-- 2. DATA TEMPLATES (Penyakit, Obat, Lab Tests yang Realistis)
-- ============================================================================

-- Common diagnoses in Indonesia
SET @diagnoses_list = 'Diabetes Mellitus Tipe 2,Hipertensi Esensial,Asma Bronkial,Gastritis,Kolesterol Tinggi,Anemia Defisiensi Besi,Infeksi Saluran Kemih,Demam Berdarah Dengue,Typhoid,Demam,Pilek,Batuk,Diare,Maag,Rematik,Asam Urat,Diabetes,Hipertensi,Stroke,Serangan Jantung';

-- Common medications in Indonesia
SET @medications_list = 'Paracetamol,Amoxicillin,Omeprazole,Metformin,Amlodipine,Salbutamol,Antasida,Ibuprofen,Amoxiclav,Cefixime,Azithromycin,Levofloxacin,Ciprofloxacin,Metronidazole,Chlorpheniramine,Dexamethasone,Prednisone,Losartan,Captopril,Furosemide';

-- Common lab tests
SET @lab_tests_list = 'Gula Darah Puasa,HbA1c,Kolesterol Total,HDL,LDL,Trigliserida,Creatinine,Ureum,ALT,AST,Hemoglobin,Leukosit,Trombosit,Urine Lengkap,Glukosa Darah Sewaktu,Asam Urat,Kalsium,Fosfor,TSH,FT4';

-- Common allergies
SET @allergies_list = 'Penicillin,Amoxicillin,Sulfa,Aspirin,Ibuprofen,Latex,Debu,Tungau,Kacang,Susu,Seafood,Udang,Telur,Kedelai,Gandum';

-- ============================================================================
-- 3. INSERT MEDICAL RECORDS, DIAGNOSES, PRESCRIPTIONS, LAB RESULTS
-- ============================================================================

-- Temporary table to store patient IDs (assuming you have users 1-100)
CREATE TEMPORARY TABLE IF NOT EXISTS temp_patients AS
SELECT id AS patient_id FROM users ORDER BY id LIMIT 100;

-- Variables for loops
SET @patient_counter = 0;
SET @current_patient_id = 0;
SET @record_counter = 0;

-- ============================================================================
-- Main Loop: Generate data for each patient
-- ============================================================================

-- For each patient (1-100), create 1-5 medical records
-- Using stored procedure approach for MySQL

DELIMITER $$

DROP PROCEDURE IF EXISTS GenerateDummyMedicalData$$

CREATE PROCEDURE GenerateDummyMedicalData()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_patient_id INT;
    DECLARE v_record_count INT;
    DECLARE v_record_id CHAR(36);
    DECLARE v_diagnosis_id CHAR(36);
    DECLARE v_prescription_id CHAR(36);
    DECLARE v_lab_id CHAR(36);
    DECLARE v_allergy_id CHAR(36);
    DECLARE v_doc_id CHAR(36);
    DECLARE v_visit_date DATETIME;
    DECLARE v_visit_type VARCHAR(20);
    DECLARE v_diagnosis_name VARCHAR(255);
    DECLARE v_drug_name VARCHAR(255);
    DECLARE v_test_name VARCHAR(255);
    DECLARE v_allergy_name VARCHAR(255);
    DECLARE i INT;
    DECLARE j INT;
    
    -- Cursor for patients
    DECLARE patient_cursor CURSOR FOR 
        SELECT patient_id FROM temp_patients;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN patient_cursor;
    
    patient_loop: LOOP
        FETCH patient_cursor INTO v_patient_id;
        IF done THEN
            LEAVE patient_loop;
        END IF;
        
        -- Generate 1-5 medical records per patient
        SET v_record_count = FLOOR(1 + RAND() * 5);
        SET i = 0;
        
        WHILE i < v_record_count DO
            -- Generate record_id
            SET v_record_id = UUID();
            
            -- Generate visit date (within last 2 years)
            SET v_visit_date = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 730) DAY);
            SET v_visit_date = DATE_ADD(v_visit_date, INTERVAL FLOOR(RAND() * 23) HOUR);
            SET v_visit_date = DATE_ADD(v_visit_date, INTERVAL FLOOR(RAND() * 59) MINUTE);
            
            -- Random visit type
            SET v_visit_type = ELT(1 + FLOOR(RAND() * 3), 'outpatient', 'inpatient', 'emergency');
            
            -- Random diagnosis
            SET v_diagnosis_name = ELT(1 + FLOOR(RAND() * 20), 
                'Diabetes Mellitus Tipe 2',
                'Hipertensi Esensial',
                'Asma Bronkial',
                'Gastritis',
                'Kolesterol Tinggi',
                'Anemia Defisiensi Besi',
                'Infeksi Saluran Kemih',
                'Demam Berdarah Dengue',
                'Typhoid',
                'Demam',
                'Pilek',
                'Batuk',
                'Diare',
                'Maag',
                'Rematik',
                'Asam Urat',
                'Diabetes',
                'Hipertensi',
                'Stroke',
                'Serangan Jantung'
            );
            
            -- Insert medical record
            INSERT INTO medical_records (
                record_id, patient_id, visit_date, visit_type,
                diagnosis_summary, notes, doctor_name, facility_name, created_at
            ) VALUES (
                v_record_id,
                v_patient_id,
                v_visit_date,
                v_visit_type,
                CONCAT('Kunjungan untuk ', v_diagnosis_name, '. Pasien mengeluh gejala yang sesuai dengan diagnosis.'),
                CONCAT('Pasien datang dengan keluhan utama. Pemeriksaan fisik menunjukkan tanda-tanda klinis. '
                      'Diagnosis: ', v_diagnosis_name, '. Diberikan pengobatan sesuai protokol. '
                      'Pasien disarankan kontrol ulang dalam 1-2 minggu.'),
                ELT(1 + FLOOR(RAND() * 10), 
                    'Dr. Ahmad Wijaya', 'Dr. Siti Nurhaliza', 'Dr. Budi Santoso',
                    'Dr. Rina Indrawati', 'Dr. Agus Prasetyo', 'Dr. Dewi Sartika',
                    'Dr. Indra Gunawan', 'Dr. Maya Sari', 'Dr. Fajar Nugroho', 'Dr. Lina Wijaya'
                ),
                ELT(1 + FLOOR(RAND() * 8),
                    'RSUD Dr. Soetomo', 'RS Cipto Mangunkusumo', 'RS Siloam',
                    'RS Pondok Indah', 'RS Medistra', 'Klinik Sehat',
                    'Puskesmas Jakarta Pusat', 'RS Premier Bintaro'
                ),
                v_visit_date
            );
            
            -- Insert 1-3 diagnoses per record
            SET j = 0;
            WHILE j < (1 + FLOOR(RAND() * 3)) DO
                SET v_diagnosis_id = UUID();
                INSERT INTO diagnoses (
                    diagnosis_id, record_id, icd_code, diagnosis_name, primary_flag, created_at
                ) VALUES (
                    v_diagnosis_id,
                    v_record_id,
                    CONCAT('E', LPAD(FLOOR(10 + RAND() * 90), 2, '0'), '.', LPAD(FLOOR(1 + RAND() * 9), 1, '0')),
                    v_diagnosis_name,
                    IF(j = 0, TRUE, FALSE),
                    v_visit_date
                );
                SET j = j + 1;
            END WHILE;
            
            -- Insert 1-4 prescriptions per record
            SET j = 0;
            WHILE j < (1 + FLOOR(RAND() * 4)) DO
                SET v_prescription_id = UUID();
                SET v_drug_name = ELT(1 + FLOOR(RAND() * 20),
                    'Paracetamol', 'Amoxicillin', 'Omeprazole', 'Metformin', 'Amlodipine',
                    'Salbutamol', 'Antasida', 'Ibuprofen', 'Amoxiclav', 'Cefixime',
                    'Azithromycin', 'Levofloxacin', 'Ciprofloxacin', 'Metronidazole',
                    'Chlorpheniramine', 'Dexamethasone', 'Prednisone', 'Losartan', 'Captopril'
                );
                INSERT INTO prescriptions (
                    prescription_id, record_id, drug_name, drug_code, dosage, frequency,
                    duration_days, notes, created_at
                ) VALUES (
                    v_prescription_id,
                    v_record_id,
                    v_drug_name,
                    CONCAT('DRG', LPAD(FLOOR(1000 + RAND() * 9000), 4, '0')),
                    ELT(1 + FLOOR(RAND() * 5), '500mg', '250mg', '100mg', '10mg', '5mg'),
                    ELT(1 + FLOOR(RAND() * 4), '3x sehari', '2x sehari', '1x sehari', 'Sesuai kebutuhan'),
                    FLOOR(3 + RAND() * 14),
                    CONCAT('Minum setelah makan. Hindari alkohol.'),
                    v_visit_date
                );
                SET j = j + 1;
            END WHILE;
            
            -- Insert 0-3 lab results per record (60% chance)
            IF RAND() < 0.6 THEN
                SET j = 0;
                WHILE j < (1 + FLOOR(RAND() * 3)) DO
                    SET v_lab_id = UUID();
                    SET v_test_name = ELT(1 + FLOOR(RAND() * 20),
                        'Gula Darah Puasa', 'HbA1c', 'Kolesterol Total', 'HDL', 'LDL',
                        'Trigliserida', 'Creatinine', 'Ureum', 'ALT', 'AST',
                        'Hemoglobin', 'Leukosit', 'Trombosit', 'Urine Lengkap',
                        'Glukosa Darah Sewaktu', 'Asam Urat', 'Kalsium', 'Fosfor', 'TSH', 'FT4'
                    );
                    INSERT INTO lab_results (
                        lab_id, record_id, test_name, result_value, result_unit,
                        normal_range, interpretation, created_at
                    ) VALUES (
                        v_lab_id,
                        v_record_id,
                        v_test_name,
                        CONCAT(FLOOR(50 + RAND() * 200)),
                        ELT(1 + FLOOR(RAND() * 5), 'mg/dL', 'mmol/L', '%', 'U/L', 'cells/μL'),
                        ELT(1 + FLOOR(RAND() * 5), 
                            '70-100 mg/dL', '4.0-6.0%', '150-200 mg/dL',
                            '3.5-5.0 mmol/L', '10-40 U/L'
                        ),
                        ELT(1 + FLOOR(RAND() * 3), 'Normal', 'Sedikit meningkat', 'Dalam batas normal'),
                        v_visit_date
                    );
                    SET j = j + 1;
                END WHILE;
            END IF;
            
            SET i = i + 1;
        END WHILE;
        
        -- Insert 0-2 allergies per patient (30% chance)
        IF RAND() < 0.3 THEN
            SET j = 0;
            WHILE j < (1 + FLOOR(RAND() * 2)) DO
                SET v_allergy_id = UUID();
                SET v_allergy_name = ELT(1 + FLOOR(RAND() * 15),
                    'Penicillin', 'Amoxicillin', 'Sulfa', 'Aspirin', 'Ibuprofen',
                    'Latex', 'Debu', 'Tungau', 'Kacang', 'Susu',
                    'Seafood', 'Udang', 'Telur', 'Kedelai', 'Gandum'
                );
                INSERT INTO allergies (
                    allergy_id, patient_id, allergy_name, severity, notes, created_at, updated_at
                ) VALUES (
                    v_allergy_id,
                    v_patient_id,
                    v_allergy_name,
                    ELT(1 + FLOOR(RAND() * 3), 'low', 'moderate', 'high'),
                    CONCAT('Alergi terhadap ', v_allergy_name, '. Hindari kontak langsung.'),
                    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY),
                    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
                );
                SET j = j + 1;
            END WHILE;
        END IF;
        
        -- Insert 0-3 medical documents per patient (50% chance)
        IF RAND() < 0.5 THEN
            SET j = 0;
            WHILE j < (1 + FLOOR(RAND() * 3)) DO
                SET v_doc_id = UUID();
                INSERT INTO medical_documents (
                    doc_id, patient_id, record_id, file_type, file_url, extract_text, created_at
                ) VALUES (
                    v_doc_id,
                    v_patient_id,
                    IF(RAND() < 0.7, 
                        (SELECT record_id FROM medical_records WHERE patient_id = v_patient_id ORDER BY RAND() LIMIT 1),
                        NULL
                    ),
                    ELT(1 + FLOOR(RAND() * 2), 'pdf', 'image'),
                    CONCAT('/storage/documents/', v_doc_id, '.pdf'),
                    CONCAT(
                        'HASIL PEMERIKSAAN MEDIS\n',
                        'Pasien: User ', v_patient_id, '\n',
                        'Tanggal: ', DATE_FORMAT(v_visit_date, '%d %B %Y'), '\n',
                        'Dokter: ', ELT(1 + FLOOR(RAND() * 10), 
                            'Dr. Ahmad Wijaya', 'Dr. Siti Nurhaliza', 'Dr. Budi Santoso',
                            'Dr. Rina Indrawati', 'Dr. Agus Prasetyo', 'Dr. Dewi Sartika',
                            'Dr. Indra Gunawan', 'Dr. Maya Sari', 'Dr. Fajar Nugroho', 'Dr. Lina Wijaya'
                        ), '\n\n',
                        'DIAGNOSIS:\n',
                        v_diagnosis_name, '\n\n',
                        'RINGKASAN:\n',
                        'Pasien datang dengan keluhan utama. Pemeriksaan fisik menunjukkan tanda-tanda klinis yang sesuai dengan diagnosis. '
                        'Hasil pemeriksaan penunjang menunjukkan hasil dalam batas normal atau sedikit abnormal. '
                        'Diberikan pengobatan sesuai dengan protokol medis yang berlaku.\n\n',
                        'PENGOBATAN:\n',
                        'Pasien diberikan resep obat yang sesuai dengan diagnosis. '
                        'Dianjurkan untuk kontrol ulang dalam 1-2 minggu untuk evaluasi lebih lanjut.\n\n',
                        'CATATAN:\n',
                        'Pasien disarankan untuk istirahat yang cukup, mengonsumsi makanan bergizi, '
                        'dan menghindari faktor risiko yang dapat memperburuk kondisi. '
                        'Jika gejala memburuk, segera hubungi dokter atau datang ke IGD.\n\n',
                        'Tanda Tangan Dokter\n',
                        ELT(1 + FLOOR(RAND() * 10), 
                            'Dr. Ahmad Wijaya', 'Dr. Siti Nurhaliza', 'Dr. Budi Santoso',
                            'Dr. Rina Indrawati', 'Dr. Agus Prasetyo', 'Dr. Dewi Sartika',
                            'Dr. Indra Gunawan', 'Dr. Maya Sari', 'Dr. Fajar Nugroho', 'Dr. Lina Wijaya'
                        )
                    ),
                    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
                );
                SET j = j + 1;
            END WHILE;
        END IF;
        
    END LOOP;
    
    CLOSE patient_cursor;
END$$

DELIMITER ;

-- ============================================================================
-- Execute the procedure
-- ============================================================================

CALL GenerateDummyMedicalData();

-- ============================================================================
-- Clean up
-- ============================================================================

DROP PROCEDURE IF EXISTS GenerateDummyMedicalData;
DROP TEMPORARY TABLE IF EXISTS temp_patients;

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Count records per table
SELECT 'medical_records' AS table_name, COUNT(*) AS record_count FROM medical_records
UNION ALL
SELECT 'diagnoses', COUNT(*) FROM diagnoses
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM prescriptions
UNION ALL
SELECT 'lab_results', COUNT(*) FROM lab_results
UNION ALL
SELECT 'allergies', COUNT(*) FROM allergies
UNION ALL
SELECT 'medical_documents', COUNT(*) FROM medical_documents;

-- Count records per patient
SELECT 
    patient_id,
    COUNT(*) AS record_count
FROM medical_records
GROUP BY patient_id
ORDER BY patient_id
LIMIT 10;

-- Sample data
SELECT * FROM medical_records ORDER BY created_at DESC LIMIT 5;
SELECT * FROM diagnoses ORDER BY created_at DESC LIMIT 5;
SELECT * FROM prescriptions ORDER BY created_at DESC LIMIT 5;
SELECT * FROM lab_results ORDER BY created_at DESC LIMIT 5;
SELECT * FROM allergies ORDER BY created_at DESC LIMIT 5;
SELECT doc_id, patient_id, LEFT(extract_text, 100) AS text_preview FROM medical_documents ORDER BY created_at DESC LIMIT 5;

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1. This script generates realistic dummy data for 100 users
-- 2. Each user gets 1-5 medical records
-- 3. Each record has 1-3 diagnoses, 1-4 prescriptions
-- 4. 60% of records have lab results (0-3 per record)
-- 5. 30% of patients have allergies (0-2 per patient)
-- 6. 50% of patients have medical documents (0-3 per patient)
-- 7. All dates are randomized within the last 2 years
-- 8. All text is in Indonesian (Bahasa Indonesia)
-- 9. extract_text in medical_documents contains realistic medical document text
-- 10. Run this AFTER creating all tables and indexes

