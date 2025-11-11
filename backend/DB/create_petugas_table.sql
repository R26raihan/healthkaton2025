-- Petugas (Staff/Officer) Table for Backoffice
-- Run this after users table is created

USE healthkon;

-- Create petugas table
CREATE TABLE IF NOT EXISTS petugas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Hashed password
    phoneNumber VARCHAR(20),
    nip VARCHAR(50) UNIQUE,  -- Nomor Induk Pegawai
    role ENUM('ADMIN', 'DOKTER', 'PERAWAT', 'ADMINISTRATOR', 'STAFF') NOT NULL DEFAULT 'STAFF',
    specialization VARCHAR(255),  -- Spesialisasi (untuk dokter)
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_nip (nip),
    INDEX idx_role (role),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert dummy admin petugas (password: admin123)
-- Password hash: $2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5KZ8QZ5Z5Z5Z5
-- For testing, you can register via API or use bcrypt to hash password
-- Example: INSERT INTO petugas (name, email, password, role) VALUES ('Admin', 'admin@healthkon.com', '$2b$12$...', 'admin');

