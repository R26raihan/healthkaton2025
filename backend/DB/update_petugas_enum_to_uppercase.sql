-- Update petugas table enum to UPPERCASE
-- Run this if the table already exists with lowercase enum values

USE healthkon;

-- Check if table exists
-- If table exists with lowercase enum, we need to alter it
-- First, let's check the current enum values
-- SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_SCHEMA = 'healthkon' AND TABLE_NAME = 'petugas' AND COLUMN_NAME = 'role';

-- Alter the enum column to use UPPERCASE values
ALTER TABLE petugas 
MODIFY COLUMN role ENUM('ADMIN', 'DOKTER', 'PERAWAT', 'ADMINISTRATOR', 'STAFF') NOT NULL DEFAULT 'STAFF';

-- If there are existing records with lowercase values, update them
-- Update existing records to UPPERCASE
UPDATE petugas SET role = UPPER(role) WHERE role IS NOT NULL;

-- Verify the change
-- SELECT DISTINCT role FROM petugas;

