-- Insert Dummy Data untuk raihansetiawan203@gmail.com
-- Data lengkap untuk mendukung semua fitur aplikasi

USE healthkon;

-- ============================================
-- 0. Tambahkan kolom health profile ke tabel users (jika belum ada)
-- ============================================
-- Stored procedure untuk menambahkan kolom jika belum ada
DELIMITER $$

DROP PROCEDURE IF EXISTS add_column_if_not_exists$$
CREATE PROCEDURE add_column_if_not_exists(
    IN table_name VARCHAR(64),
    IN column_name VARCHAR(64),
    IN column_definition TEXT
)
BEGIN
    DECLARE column_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO column_count
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = table_name
    AND COLUMN_NAME = column_name;
    
    IF column_count = 0 THEN
        SET @sql = CONCAT('ALTER TABLE ', table_name, ' ADD COLUMN ', column_name, ' ', column_definition);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

-- Tambahkan kolom-kolom health profile
CALL add_column_if_not_exists('users', 'blood_type', 'ENUM(''A+'', ''A-'', ''B+'', ''B-'', ''AB+'', ''AB-'', ''O+'', ''O-'') NULL');
CALL add_column_if_not_exists('users', 'birth_date', 'DATE NULL');
CALL add_column_if_not_exists('users', 'gender', 'ENUM(''male'', ''female'', ''other'') NULL');
CALL add_column_if_not_exists('users', 'height_cm', 'INT NULL');
CALL add_column_if_not_exists('users', 'weight_kg', 'DECIMAL(5,2) NULL');

-- Hapus stored procedure setelah digunakan
DROP PROCEDURE IF EXISTS add_column_if_not_exists;

-- ============================================
-- 1. Update User Profile (Personal Health Profile)
-- ============================================
UPDATE users SET 
    blood_type = 'AB+',
    birth_date = '1995-03-15',
    gender = 'male',
    height_cm = 172,
    weight_kg = 68.5
WHERE email = 'raihansetiawan203@gmail.com';

-- Set variabel untuk patient_id (akan digunakan di query berikutnya)
SET @patient_id = (SELECT id FROM users WHERE email = 'raihansetiawan203@gmail.com' LIMIT 1);

-- ============================================
-- 2. Allergies (Alergi)
-- ============================================
INSERT INTO allergies (allergy_id, patient_id, allergy_name, severity, notes) VALUES
(UUID(), @patient_id, 'Penicillin', 'high', 'Alergi berat terhadap Penicillin, menyebabkan ruam dan sesak napas'),
(UUID(), @patient_id, 'Udang', 'moderate', 'Alergi makanan, menyebabkan gatal-gatal dan bengkak ringan'),
(UUID(), @patient_id, 'Debu', 'low', 'Alergi debu ringan, menyebabkan bersin-bersin');

-- ============================================
-- 3. Medical Records (Riwayat Kunjungan)
-- ============================================
-- Set record_id sebagai variabel untuk digunakan di tabel lain
SET @record_id_1 = UUID();
SET @record_id_2 = UUID();
SET @record_id_3 = UUID();
SET @record_id_4 = UUID();

-- Record 1: Kunjungan rutin 3 bulan lalu
INSERT INTO medical_records (record_id, patient_id, visit_date, visit_type, diagnosis_summary, notes, doctor_name, facility_name) VALUES
(@record_id_1, @patient_id, DATE_SUB(NOW(), INTERVAL 90 DAY), 'outpatient', 
 'Kontrol rutin kesehatan, tekanan darah normal, keluhan ringan sakit kepala',
 'Pasien datang untuk kontrol rutin. Tidak ada keluhan serius. Tekanan darah 120/80, nadi 72 bpm. Pasien mengeluh sakit kepala ringan sesekali.',
 'Dr. Sarah Wijaya', 'RS Pusat Jakarta');

-- Record 2: Kunjungan 1 bulan lalu - keluhan flu
INSERT INTO medical_records (record_id, patient_id, visit_date, visit_type, diagnosis_summary, notes, doctor_name, facility_name) VALUES
(@record_id_2, @patient_id, DATE_SUB(NOW(), INTERVAL 30 DAY), 'outpatient',
 'Flu biasa dengan gejala batuk dan pilek',
 'Pasien datang dengan keluhan batuk, pilek, dan demam ringan selama 3 hari. Tidak ada gejala serius lainnya.',
 'Dr. Ahmad Fauzi', 'Klinik Sehat');

-- Record 3: Kunjungan 2 minggu lalu - kontrol gula darah
INSERT INTO medical_records (record_id, patient_id, visit_date, visit_type, diagnosis_summary, notes, doctor_name, facility_name) VALUES
(@record_id_3, @patient_id, DATE_SUB(NOW(), INTERVAL 14 DAY), 'outpatient',
 'Kontrol gula darah dan kolesterol, hasil dalam batas normal',
 'Pasien melakukan kontrol rutin untuk gula darah dan kolesterol. Hasil lab menunjukkan gula darah puasa 95 mg/dL (normal), kolesterol total 185 mg/dL (normal).',
 'Dr. Indra Pratama', 'RS Mitra Keluarga');

-- Record 4: Kunjungan terakhir - keluhan nyeri sendi
INSERT INTO medical_records (record_id, patient_id, visit_date, visit_type, diagnosis_summary, notes, doctor_name, facility_name) VALUES
(@record_id_4, @patient_id, DATE_SUB(NOW(), INTERVAL 5 DAY), 'outpatient',
 'Nyeri sendi lutut kanan, kemungkinan akibat aktivitas berlebihan',
 'Pasien mengeluh nyeri pada lutut kanan setelah aktivitas olahraga intens. Tidak ada riwayat trauma. Pemeriksaan fisik menunjukkan tidak ada pembengkakan signifikan.',
 'Dr. Budi Santoso', 'Klinik Orthopedi');

-- ============================================
-- 4. Diagnoses (Diagnosis)
-- ============================================
INSERT INTO diagnoses (diagnosis_id, record_id, icd_code, diagnosis_name, primary_flag) VALUES
(UUID(), @record_id_1, 'R51', 'Sakit kepala', TRUE),
(UUID(), @record_id_2, 'J00', 'Common cold (Flu biasa)', TRUE),
(UUID(), @record_id_3, 'Z51.1', 'Kontrol kesehatan rutin', TRUE),
(UUID(), @record_id_4, 'M25.561', 'Nyeri sendi lutut kanan', TRUE),
(UUID(), @record_id_4, 'M79.3', 'Panniculitis, lokasi tidak ditentukan', FALSE);

-- ============================================
-- 5. Prescriptions (Resep Obat)
-- ============================================
INSERT INTO prescriptions (prescription_id, record_id, drug_name, drug_code, dosage, frequency, duration_days, notes) VALUES
(UUID(), @record_id_1, 'Paracetamol 500mg', 'PAR-500', '1 tablet', '3x sehari setelah makan', 3, 'Untuk mengatasi sakit kepala'),
(UUID(), @record_id_2, 'Paracetamol 500mg', 'PAR-500', '1 tablet', '3x sehari setelah makan', 5, 'Untuk demam dan nyeri'),
(UUID(), @record_id_2, 'Dextromethorphan 15mg', 'DEX-15', '1 tablet', '3x sehari', 5, 'Untuk batuk kering'),
(UUID(), @record_id_2, 'Cetirizine 10mg', 'CET-10', '1 tablet', '1x sehari malam', 5, 'Untuk pilek dan alergi'),
(UUID(), @record_id_4, 'Ibuprofen 400mg', 'IBU-400', '1 tablet', '3x sehari setelah makan', 7, 'Untuk nyeri dan inflamasi sendi'),
(UUID(), @record_id_4, 'Glucosamine 500mg', 'GLU-500', '1 tablet', '2x sehari', 30, 'Suplemen untuk kesehatan sendi');

-- ============================================
-- 6. Lab Results (Hasil Lab)
-- ============================================
INSERT INTO lab_results (lab_id, record_id, test_name, result_value, result_unit, normal_range, interpretation, attachment_url) VALUES
(UUID(), @record_id_3, 'Glukosa Puasa', '95', 'mg/dL', '70-100', 'Normal', NULL),
(UUID(), @record_id_3, 'Kolesterol Total', '185', 'mg/dL', '<200', 'Normal', NULL),
(UUID(), @record_id_3, 'Kolesterol LDL', '115', 'mg/dL', '<100', 'Sedikit tinggi, monitor', NULL),
(UUID(), @record_id_3, 'Kolesterol HDL', '55', 'mg/dL', '>40', 'Normal (baik)', NULL),
(UUID(), @record_id_3, 'Trigliserida', '125', 'mg/dL', '<150', 'Normal', NULL),
(UUID(), @record_id_3, 'Hemoglobin (Hb)', '14.5', 'g/dL', '13-17', 'Normal', NULL),
(UUID(), @record_id_3, 'Leukosit (WBC)', '6500', '/uL', '4000-11000', 'Normal', NULL),
(UUID(), @record_id_3, 'Trombosit', '250000', '/uL', '150000-450000', 'Normal', NULL);

-- ============================================
-- 7. Medical Documents (Dokumen Medis dengan extract_text untuk RAG)
-- ============================================
-- Set variabel untuk extract_text
SET @lab_text = CONCAT('HASIL PEMERIKSAAN LABORATORIUM
Nama: Raihan Setiawan
Tanggal: ', DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 14 DAY), '%d-%m-%Y'), '

GLUKOSA PUASA: 95 mg/dL (Normal: 70-100)
KOLESTEROL TOTAL: 185 mg/dL (Normal: <200)
KOLESTEROL LDL: 115 mg/dL (Normal: <100) - Sedikit tinggi
KOLESTEROL HDL: 55 mg/dL (Normal: >40) - Baik
TRIGLISERIDA: 125 mg/dL (Normal: <150)

HEMOGLOBIN: 14.5 g/dL (Normal: 13-17)
LEUKOSIT: 6500 /uL (Normal: 4000-11000)
TROMBOSIT: 250000 /uL (Normal: 150000-450000)

KESIMPULAN: Hasil pemeriksaan laboratorium dalam batas normal. Kolesterol LDL sedikit tinggi, disarankan untuk mengontrol pola makan dan olahraga teratur.');

SET @record_text = CONCAT('REKAM MEDIS
Nama Pasien: Raihan Setiawan
Tanggal Kunjungan: ', DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 5 DAY), '%d-%m-%Y'), '
Dokter: Dr. Budi Santoso
Fasilitas: Klinik Orthopedi

KELUHAN UTAMA:
Pasien mengeluh nyeri pada lutut kanan yang muncul setelah aktivitas olahraga intens. Nyeri dirasakan terutama saat menekuk lutut dan berjalan menaiki tangga.

PEMERIKSAAN FISIK:
- Lutut kanan: Tidak ada pembengkakan signifikan
- Range of motion: Terbatas saat fleksi penuh
- Palpasi: Nyeri tekan pada area patella
- Tidak ada instabilitas sendi

DIAGNOSIS:
1. Nyeri sendi lutut kanan (M25.561)
2. Kemungkinan akibat aktivitas berlebihan atau overuse

PENGOBATAN:
1. Ibuprofen 400mg, 3x sehari setelah makan, selama 7 hari
2. Glucosamine 500mg, 2x sehari, selama 30 hari
3. Istirahat dari aktivitas olahraga berat selama 1 minggu
4. Kompres dingin pada area nyeri

KONTROL:
Kontrol kembali dalam 2 minggu jika keluhan berlanjut.');

INSERT INTO medical_documents (doc_id, patient_id, record_id, file_type, file_url, extract_text, created_at) VALUES
(UUID(), @patient_id, @record_id_3, 'pdf', 'https://storage.example.com/lab-results/lab-001.pdf', @lab_text, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(UUID(), @patient_id, @record_id_4, 'pdf', 'https://storage.example.com/medical-records/record-004.pdf', @record_text, DATE_SUB(NOW(), INTERVAL 5 DAY));

-- ============================================
-- 8. Vaccinations (Vaksinasi) - Jika tabel ada, uncomment baris di bawah
-- ============================================
-- INSERT INTO vaccinations (vaccination_id, patient_id, vaccine_name, vaccine_type, dose_number, vaccination_date, facility_name, doctor_name, batch_number, notes) VALUES
-- (UUID(), @patient_id, 'COVID-19 (Sinovac)', 'COVID-19', 1, '2021-07-20', 'RS Pusat Jakarta', 'Dr. Sarah Wijaya', 'SV-2021-ABC123', 'Vaksinasi COVID-19 dosis pertama'),
-- (UUID(), @patient_id, 'COVID-19 (Sinovac)', 'COVID-19', 2, '2021-08-20', 'RS Pusat Jakarta', 'Dr. Sarah Wijaya', 'SV-2021-ABC456', 'Vaksinasi COVID-19 dosis kedua'),
-- (UUID(), @patient_id, 'COVID-19 (Booster)', 'COVID-19', 3, '2022-02-15', 'RS Pusat Jakarta', 'Dr. Sarah Wijaya', 'SV-2022-XYZ789', 'Vaksinasi booster COVID-19');

-- ============================================
-- 9. Lifestyle Tracking (7 hari terakhir) - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO lifestyle_tracking (tracking_id, patient_id, tracking_date, sleep_hours, sleep_quality, bedtime, wake_time, steps_count, distance_km, calories_burned, water_intake_ml, breakfast_notes, lunch_notes, dinner_notes, snacks_count) VALUES
-- (UUID(), @patient_id, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 7.5, 'good', '22:30:00', '06:00:00', 8234, 6.0, 310, 2200, 'Nasi goreng, telur', 'Nasi, ayam, sayur', 'Nasi, ikan, tahu', 1),
-- (UUID(), @patient_id, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 8.0, 'excellent', '22:00:00', '06:00:00', 9543, 7.0, 350, 2500, 'Oatmeal, buah', 'Nasi, capcay, ayam', 'Pasta, salad', 0),
-- (UUID(), @patient_id, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 6.5, 'fair', '23:00:00', '05:30:00', 6789, 5.0, 280, 1800, 'Roti, susu', 'Mie ayam', 'Nasi, rendang', 2)
-- ON DUPLICATE KEY UPDATE sleep_hours = VALUES(sleep_hours);

-- ============================================
-- 10. Health Metrics (Pengukuran kesehatan) - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO health_metrics (metric_id, patient_id, record_date, height_cm, weight_kg, bmi, body_fat_percentage, waist_circumference_cm, systolic_bp, diastolic_bp, heart_rate, body_temperature, blood_glucose_fasting, cholesterol_total, cholesterol_ldl, cholesterol_hdl, triglycerides, notes) VALUES
-- (UUID(), @patient_id, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 172, 69.0, 23.3, 18.0, 82, 120, 80, 72, 36.6, 95, 185, 115, 55, 125, 'Pemeriksaan rutin - semua normal'),
-- (UUID(), @patient_id, CURDATE(), 172, 68.5, 23.1, 17.8, 81, 118, 78, 70, 36.5, NULL, NULL, NULL, NULL, NULL, 'Pengukuran terbaru - BMI normal, tekanan darah optimal');

-- ============================================
-- 11. Medication Reminders - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO medication_reminders (reminder_id, patient_id, prescription_id, drug_name, dosage, frequency, start_date, end_date, reminder_times, is_active, notification_enabled, taken_count, missed_count, notes) VALUES
-- (UUID(), @patient_id, NULL, 'Ibuprofen 400mg', '1 tablet', '3x sehari setelah makan', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), '08:00:00', TRUE, TRUE, 12, 1, 'Obat nyeri sendi - minum setelah makan'),
-- (UUID(), @patient_id, NULL, 'Glucosamine 500mg', '1 tablet', '2x sehari', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), '09:00:00', TRUE, TRUE, 8, 2, 'Suplemen sendi');

-- ============================================
-- 12. Mood Tracking - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO mood_tracking (mood_id, patient_id, tracking_date, mood_rating, mood_label, energy_level, sleep_quality, stress_level, journal_entry, triggers, notes) VALUES
-- (UUID(), @patient_id, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 7, 'happy', 7, 7, 3, 'Hari ini produktif, kerja lancar. Olahraga pagi membuat badan segar.', 'Olahraga pagi, kerja lancar', NULL),
-- (UUID(), @patient_id, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 6, 'neutral', 6, 8, 4, 'Hari biasa, tidak ada hal khusus. Tidur cukup nyenyak.', 'Tidur cukup', NULL)
-- ON DUPLICATE KEY UPDATE mood_rating = VALUES(mood_rating);

-- ============================================
-- 13. Symptoms - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO symptoms (symptom_id, patient_id, symptom_name, severity, start_date, end_date, location, frequency, associated_symptoms, notes) VALUES
-- (UUID(), @patient_id, 'Nyeri lutut kanan', 6, DATE_SUB(NOW(), INTERVAL 5 DAY), NULL, 'Lutut kanan', 'intermittent', 'Kaku saat pagi', 'Setelah aktivitas olahraga intens');

-- ============================================
-- 14. Disease Risk Predictions - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO disease_risk_predictions (prediction_id, patient_id, disease_type, risk_score, risk_level, age_factor, bmi_factor, family_history, lifestyle_score, medical_history_score, recommendations, next_checkup_date, prediction_date) VALUES
-- (REPLACE(UUID(), '-', ''), @patient_id, 'diabetes', 28.0, 'low', 12.0, 10.0, FALSE, 8.0, 3.0, 'Pertahankan pola makan sehat, olahraga rutin, kontrol gula darah setiap 6 bulan', DATE_ADD(CURDATE(), INTERVAL 6 MONTH), DATE_SUB(CURDATE(), INTERVAL 14 DAY)),
-- (REPLACE(UUID(), '-', ''), @patient_id, 'hypertension', 25.0, 'low', 12.0, 8.0, FALSE, 9.0, 2.0, 'Tekanan darah saat ini normal, pertahankan gaya hidup sehat', DATE_ADD(CURDATE(), INTERVAL 6 MONTH), DATE_SUB(CURDATE(), INTERVAL 14 DAY)),
-- (REPLACE(UUID(), '-', ''), @patient_id, 'cholesterol', 38.0, 'moderate', 12.0, 15.0, FALSE, 8.0, 8.0, 'Kolesterol LDL sedikit tinggi, kontrol pola makan, olahraga teratur, cek lab 3 bulan', DATE_ADD(CURDATE(), INTERVAL 3 MONTH), DATE_SUB(CURDATE(), INTERVAL 14 DAY));

-- ============================================
-- 15. Emergency Contacts - Jika tabel ada, uncomment
-- ============================================
-- INSERT INTO emergency_contacts (contact_id, patient_id, contact_name, relationship, phone_number, alternate_phone, email, address, is_primary, can_authorize, notes) VALUES
-- (REPLACE(UUID(), '-', ''), @patient_id, 'Siti Nurhaliza', 'spouse', '081234567890', '081234567891', 'siti.nurhaliza@email.com', 'Jl. Merdeka No. 123, Jakarta', TRUE, TRUE, 'Istri - kontak utama'),
-- (REPLACE(UUID(), '-', ''), @patient_id, 'Budi Santoso', 'sibling', '081345678901', NULL, NULL, 'Jl. Sudirman No. 45, Jakarta', FALSE, FALSE, 'Saudara laki-laki');

-- ============================================
-- Verifikasi Data
-- ============================================
SELECT 
    'Data inserted successfully!' as status,
    @patient_id as patient_id,
    (SELECT name FROM users WHERE id = @patient_id) as patient_name,
    (SELECT COUNT(*) FROM medical_records WHERE patient_id = @patient_id) as medical_records_count,
    (SELECT COUNT(*) FROM allergies WHERE patient_id = @patient_id) as allergies_count,
    (SELECT COUNT(*) FROM medical_documents WHERE patient_id = @patient_id) as documents_count;

