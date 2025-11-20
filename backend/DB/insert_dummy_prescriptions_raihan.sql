-- Insert Dummy Prescriptions (Obat) yang Banyak untuk raihansetiawan203@gmail.com
-- Script ini akan menambahkan banyak data prescriptions ke medical records yang sudah ada

USE healthkon;

-- Set variabel untuk patient_id
SET @patient_id = (SELECT id FROM users WHERE email = 'raihansetiawan203@gmail.com' LIMIT 1);

-- Jika user tidak ditemukan, berhenti
SELECT IF(@patient_id IS NULL, 'ERROR: User raihansetiawan203@gmail.com tidak ditemukan!', CONCAT('Patient ID: ', @patient_id)) as status;

-- Buat medical records tambahan jika belum ada cukup (menggunakan stored procedure)
DELIMITER $$

DROP PROCEDURE IF EXISTS create_additional_records$$
CREATE PROCEDURE create_additional_records()
BEGIN
    DECLARE v_record_count INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_new_record_id CHAR(36);
    
    SELECT COUNT(*) INTO v_record_count 
    FROM medical_records 
    WHERE patient_id = @patient_id;
    
    -- Buat records tambahan sampai ada 15 records
    WHILE v_record_count < 15 DO
        SET v_new_record_id = UUID();
        INSERT INTO medical_records (
            record_id, patient_id, visit_date, visit_type, 
            diagnosis_summary, notes, doctor_name, facility_name
        ) VALUES (
            v_new_record_id,
            @patient_id,
            DATE_SUB(NOW(), INTERVAL (FLOOR(RAND() * 365)) DAY),
            ELT(1 + FLOOR(RAND() * 3), 'outpatient', 'inpatient', 'emergency'),
            CONCAT('Kunjungan medis - ', 
                   ELT(1 + FLOOR(RAND() * 10), 
                       'Kontrol rutin', 'Konsultasi umum', 'Pemeriksaan kesehatan',
                       'Pengobatan lanjutan', 'Follow up', 'Konsultasi spesialis',
                       'Pemeriksaan laboratorium', 'Terapi', 'Rehabilitasi', 'Pemeriksaan preventif'
                   )
            ),
            CONCAT('Catatan medis untuk kunjungan'),
            CONCAT('Dr. ', ELT(1 + FLOOR(RAND() * 10), 
                'Ahmad Fauzi', 'Sarah Wijaya', 'Budi Santoso', 'Indra Pratama',
                'Siti Nurhaliza', 'Rudi Hartono', 'Dewi Sartika', 'Agus Setiawan',
                'Lina Marlina', 'Hendra Gunawan'
            )),
            ELT(1 + FLOOR(RAND() * 8),
                'RS Pusat Jakarta', 'Klinik Sehat', 'RS Mitra Keluarga',
                'Klinik Orthopedi', 'RS Cipto Mangunkusumo', 'Klinik Pratama',
                'RS Siloam', 'Rumah Sakit Umum Daerah'
            )
        );
        SET v_record_count = v_record_count + 1;
    END WHILE;
END$$

DELIMITER ;

-- Panggil stored procedure untuk membuat records tambahan
CALL create_additional_records();
DROP PROCEDURE IF EXISTS create_additional_records;

-- Sekarang buat stored procedure untuk insert banyak prescriptions
DELIMITER $$

DROP PROCEDURE IF EXISTS insert_many_prescriptions$$
CREATE PROCEDURE insert_many_prescriptions(IN total_count INT)
BEGIN
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_random_record_id CHAR(36);
    DECLARE v_drug_name VARCHAR(255);
    DECLARE v_drug_code VARCHAR(50);
    DECLARE v_dosage VARCHAR(100);
    DECLARE v_frequency VARCHAR(100);
    DECLARE v_duration_days INT;
    DECLARE v_notes TEXT;
    
    WHILE v_counter < total_count DO
        -- Ambil random record_id dari user ini
        SELECT record_id INTO v_random_record_id
        FROM medical_records 
        WHERE patient_id = @patient_id 
        ORDER BY RAND() 
        LIMIT 1;
        
        -- Pilih random drug
        SET v_drug_name = ELT(1 + FLOOR(RAND() * 30),
            'Paracetamol 500mg', 'Amoxicillin 500mg', 'Omeprazole 20mg', 
            'Metformin 500mg', 'Amlodipine 5mg', 'Salbutamol 100mcg',
            'Antasida', 'Ibuprofen 400mg', 'Amoxiclav 625mg', 'Cefixime 200mg',
            'Azithromycin 500mg', 'Levofloxacin 500mg', 'Ciprofloxacin 500mg',
            'Metronidazole 500mg', 'Chlorpheniramine 4mg', 'Dexamethasone 0.5mg',
            'Prednisone 5mg', 'Losartan 50mg', 'Captopril 25mg', 'Atorvastatin 20mg',
            'Simvastatin 20mg', 'Clopidogrel 75mg', 'Aspirin 100mg', 'Warfarin 2mg',
            'Furosemide 40mg', 'Spironolactone 25mg', 'Digoxin 0.25mg', 
            'Propranolol 40mg', 'Bisoprolol 2.5mg', 'Metoprolol 50mg'
        );
        
        -- Generate drug code
        SET v_drug_code = CONCAT(
            UPPER(SUBSTRING(v_drug_name, 1, 3)),
            '-',
            LPAD(FLOOR(100 + RAND() * 900), 3, '0')
        );
        
        -- Random dosage
        SET v_dosage = ELT(1 + FLOOR(RAND() * 8),
            '1 tablet', '2 tablet', '1 kapsul', '1 sachet', 
            '500mg', '250mg', '10ml', '1 vial'
        );
        
        -- Random frequency
        SET v_frequency = ELT(1 + FLOOR(RAND() * 6),
            '3x sehari setelah makan', '2x sehari setelah makan', 
            '1x sehari pagi', '1x sehari malam', 
            'Sesuai kebutuhan', 'Setiap 6 jam'
        );
        
        -- Random duration (3-30 days)
        SET v_duration_days = FLOOR(3 + RAND() * 28);
        
        -- Random notes
        SET v_notes = ELT(1 + FLOOR(RAND() * 5),
            'Minum setelah makan. Hindari alkohol.',
            'Minum sebelum makan dengan air putih.',
            'Minum dengan banyak air. Hindari sinar matahari langsung.',
            'Minum sesuai petunjuk dokter. Jangan melebihi dosis.',
            'Simpan di tempat sejuk dan kering. Jauhkan dari jangkauan anak-anak.'
        );
        
        -- Insert prescription
        INSERT INTO prescriptions (
            prescription_id, record_id, drug_name, drug_code, 
            dosage, frequency, duration_days, notes, created_at
        ) VALUES (
            UUID(),
            v_random_record_id,
            v_drug_name,
            v_drug_code,
            v_dosage,
            v_frequency,
            v_duration_days,
            v_notes,
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
        );
        
        SET v_counter = v_counter + 1;
    END WHILE;
END$$

DELIMITER ;

-- Panggil stored procedure untuk insert 50 prescriptions
CALL insert_many_prescriptions(50);
DROP PROCEDURE IF EXISTS insert_many_prescriptions;

-- Verifikasi hasil
SELECT 
    'Prescriptions inserted successfully!' as status,
    @patient_id as patient_id,
    (SELECT name FROM users WHERE id = @patient_id) as patient_name,
    (SELECT COUNT(*) FROM medical_records WHERE patient_id = @patient_id) as total_medical_records,
    (SELECT COUNT(*) FROM prescriptions p 
     INNER JOIN medical_records mr ON p.record_id = mr.record_id 
     WHERE mr.patient_id = @patient_id) as total_prescriptions,
    (SELECT COUNT(DISTINCT drug_name) FROM prescriptions p 
     INNER JOIN medical_records mr ON p.record_id = mr.record_id 
     WHERE mr.patient_id = @patient_id) as unique_drugs;

-- Tampilkan sample prescriptions
SELECT 
    p.prescription_id,
    p.drug_name,
    p.drug_code,
    p.dosage,
    p.frequency,
    p.duration_days,
    p.created_at,
    mr.visit_date,
    mr.doctor_name,
    mr.facility_name
FROM prescriptions p
INNER JOIN medical_records mr ON p.record_id = mr.record_id
WHERE mr.patient_id = @patient_id
ORDER BY p.created_at DESC
LIMIT 20;

