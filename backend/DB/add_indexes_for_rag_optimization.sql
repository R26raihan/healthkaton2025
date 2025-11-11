-- ============================================================================
-- SQL Script: Add Indexes for RAG Optimization
-- ============================================================================
-- Purpose: Optimize database queries for RAG (Retrieval-Augmented Generation)
--          service by adding indexes for full-text search and common queries
-- 
-- Run this after creating all tables (users, medical_records, etc.)
-- ============================================================================

USE healthkon;

-- ============================================================================
-- 1. FULLTEXT INDEXES for Text Search (MySQL InnoDB)
-- ============================================================================
-- Note: FULLTEXT indexes are available in MySQL 5.6+ for InnoDB tables
-- These indexes enable fast full-text search on text columns

-- Full-text search on medical_documents.extract_text (most important for RAG)
-- This allows fast semantic search on extracted text from PDF/images
ALTER TABLE medical_documents 
ADD FULLTEXT INDEX idx_ft_extract_text (extract_text(500))
COMMENT 'Full-text index for RAG document search';

-- Full-text search on medical_records.diagnosis_summary
ALTER TABLE medical_records 
ADD FULLTEXT INDEX idx_ft_diagnosis_summary (diagnosis_summary(500))
COMMENT 'Full-text index for diagnosis search';

-- Full-text search on medical_records.notes
ALTER TABLE medical_records 
ADD FULLTEXT INDEX idx_ft_notes (notes(500))
COMMENT 'Full-text index for notes search';

-- Full-text search on allergies.notes (if users search allergy details)
ALTER TABLE allergies 
ADD FULLTEXT INDEX idx_ft_allergy_notes (notes(200))
COMMENT 'Full-text index for allergy notes search';

-- Full-text search on prescriptions.notes
ALTER TABLE prescriptions 
ADD FULLTEXT INDEX idx_ft_prescription_notes (notes(200))
COMMENT 'Full-text index for prescription notes search';

-- Full-text search on lab_results.interpretation
ALTER TABLE lab_results 
ADD FULLTEXT INDEX idx_ft_lab_interpretation (interpretation(500))
COMMENT 'Full-text index for lab interpretation search';

-- ============================================================================
-- 2. COMPOSITE INDEXES for Common Query Patterns
-- ============================================================================
-- These indexes optimize queries that filter by multiple columns

-- Composite index for patient + visit_date (common pattern: get patient records by date)
ALTER TABLE medical_records 
ADD INDEX idx_patient_visit_date (patient_id, visit_date DESC)
COMMENT 'Composite index for patient records sorted by date';

-- Composite index for patient + created_at (for recent documents)
ALTER TABLE medical_documents 
ADD INDEX idx_patient_created (patient_id, created_at DESC)
COMMENT 'Composite index for patient documents sorted by creation date';

-- Composite index for record + created_at (for related documents)
ALTER TABLE medical_documents 
ADD INDEX idx_record_created (record_id, created_at DESC)
COMMENT 'Composite index for record documents sorted by creation date';

-- Composite index for patient + severity (for allergy queries)
ALTER TABLE allergies 
ADD INDEX idx_patient_severity (patient_id, severity)
COMMENT 'Composite index for patient allergies by severity';

-- Composite index for record + primary_flag (for primary diagnosis)
ALTER TABLE diagnoses 
ADD INDEX idx_record_primary (record_id, primary_flag)
COMMENT 'Composite index for primary diagnoses per record';

-- ============================================================================
-- 3. ADDITIONAL INDEXES for Query Optimization
-- ============================================================================

-- Index on medical_records.doctor_name (for doctor-based queries)
ALTER TABLE medical_records 
ADD INDEX idx_doctor_name (doctor_name(100))
COMMENT 'Index for doctor name searches';

-- Index on medical_records.facility_name (for facility-based queries)
ALTER TABLE medical_records 
ADD INDEX idx_facility_name (facility_name(100))
COMMENT 'Index for facility name searches';

-- Index on diagnoses.diagnosis_name (for diagnosis name searches)
ALTER TABLE diagnoses 
ADD INDEX idx_diagnosis_name (diagnosis_name(100))
COMMENT 'Index for diagnosis name searches';

-- Index on prescriptions.drug_code (for drug code lookups)
ALTER TABLE prescriptions 
ADD INDEX idx_drug_code (drug_code)
COMMENT 'Index for drug code searches';

-- Index on lab_results.result_value (for value-based queries)
-- Note: This might not be very useful for exact matches, but helps with range queries
ALTER TABLE lab_results 
ADD INDEX idx_test_result (test_name, result_value(50))
COMMENT 'Composite index for test name and result value';

-- ============================================================================
-- 4. OPTIONAL: Table for Document Embeddings (Future Enhancement)
-- ============================================================================
-- This table stores vector embeddings for semantic search
-- Uncomment if you plan to implement vector-based semantic search

/*
CREATE TABLE IF NOT EXISTS document_embeddings (
    embedding_id CHAR(36) PRIMARY KEY,  -- UUID
    doc_id CHAR(36) NOT NULL,           -- FK to medical_documents
    chunk_index INT NOT NULL DEFAULT 0, -- Index of chunk if document is chunked
    embedding_text TEXT NOT NULL,       -- Text that was embedded
    embedding_vector JSON,              -- Vector embedding (stored as JSON array)
    embedding_model VARCHAR(100),       -- Model used (e.g., 'text-embedding-ada-002')
    embedding_dimension INT,            -- Dimension of embedding vector
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doc_id) REFERENCES medical_documents(doc_id) ON DELETE CASCADE,
    INDEX idx_doc_id (doc_id),
    INDEX idx_chunk_index (chunk_index),
    INDEX idx_embedding_model (embedding_model)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Stores vector embeddings for semantic search (future enhancement)';
*/

-- ============================================================================
-- 5. OPTIONAL: Table for Query Cache (Performance Optimization)
-- ============================================================================
-- This table caches frequently asked questions and their answers
-- Uncomment if you want to implement query caching

/*
CREATE TABLE IF NOT EXISTS rag_query_cache (
    cache_id CHAR(36) PRIMARY KEY,  -- UUID
    patient_id INT NOT NULL,        -- FK to users.id
    query_hash VARCHAR(64) NOT NULL, -- SHA256 hash of query + patient_id
    query_text TEXT NOT NULL,       -- Original query
    answer_text TEXT NOT NULL,      -- Cached answer
    sources JSON,                   -- Cached sources (document IDs)
    model_used VARCHAR(100),        -- LLM model used
    hit_count INT DEFAULT 1,        -- Number of times this cache was hit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,           -- When cache expires
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_query_hash (query_hash),
    INDEX idx_patient_id (patient_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_last_accessed (last_accessed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Cache for RAG queries to improve performance';
*/

-- ============================================================================
-- 6. OPTIONAL: Table for RAG Query Logs (Analytics & Monitoring)
-- ============================================================================
-- This table logs all RAG queries for analytics and monitoring
-- Uncomment if you want to track query patterns and improve the service

/*
CREATE TABLE IF NOT EXISTS rag_query_logs (
    log_id CHAR(36) PRIMARY KEY,   -- UUID
    patient_id INT NOT NULL,       -- FK to users.id
    query_text TEXT NOT NULL,      -- User query
    answer_text TEXT,              -- Generated answer (optional, for debugging)
    sources JSON,                  -- Sources used (document IDs)
    model_used VARCHAR(100),       -- LLM model used
    processing_time DECIMAL(10,3), -- Processing time in seconds
    success BOOLEAN DEFAULT TRUE,  -- Whether query was successful
    error_message TEXT,            -- Error message if failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_patient_id (patient_id),
    INDEX idx_created_at (created_at),
    INDEX idx_success (success)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Logs all RAG queries for analytics and monitoring';
*/

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these queries to verify indexes were created successfully

-- Check all indexes on medical_documents
-- SHOW INDEXES FROM medical_documents;

-- Check all indexes on medical_records
-- SHOW INDEXES FROM medical_records;

-- Check all indexes on allergies
-- SHOW INDEXES FROM allergies;

-- Check table sizes and index usage
-- SELECT 
--     TABLE_NAME,
--     ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Size (MB)',
--     TABLE_ROWS
-- FROM information_schema.TABLES
-- WHERE TABLE_SCHEMA = 'healthkon'
-- ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1. FULLTEXT indexes require MySQL 5.6+ with InnoDB engine
-- 2. FULLTEXT indexes have a minimum word length (default: 4 characters)
--    To change: SET GLOBAL innodb_ft_min_token_size = 1;
-- 3. FULLTEXT indexes are useful for MATCH() AGAINST() queries
-- 4. Composite indexes are most effective when queries use the leftmost columns
-- 5. Indexes improve read performance but slightly slow down writes
-- 6. Monitor index usage with: SHOW INDEXES FROM table_name;
-- 7. Uncomment optional tables if you need them for future enhancements

