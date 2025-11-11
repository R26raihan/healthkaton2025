-- ============================================================================
-- SQL Script: Verify Indexes for RAG Optimization
-- ============================================================================
-- Purpose: Verify that all indexes were created successfully
-- Run this after running add_indexes_for_rag_optimization.sql
-- ============================================================================

USE healthkon;

-- ============================================================================
-- 1. Check Indexes on Each Table
-- ============================================================================

-- Check indexes on medical_documents
SELECT 
    'medical_documents' AS table_name,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE,
    COMMENT
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND TABLE_NAME = 'medical_documents'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Check indexes on medical_records
SELECT 
    'medical_records' AS table_name,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE,
    COMMENT
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND TABLE_NAME = 'medical_records'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Check indexes on allergies
SELECT 
    'allergies' AS table_name,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE,
    COMMENT
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND TABLE_NAME = 'allergies'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Check indexes on diagnoses
SELECT 
    'diagnoses' AS table_name,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE,
    COMMENT
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND TABLE_NAME = 'diagnoses'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Check indexes on prescriptions
SELECT 
    'prescriptions' AS table_name,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE,
    COMMENT
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND TABLE_NAME = 'prescriptions'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Check indexes on lab_results
SELECT 
    'lab_results' AS table_name,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE,
    COMMENT
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND TABLE_NAME = 'lab_results'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- ============================================================================
-- 2. Check FULLTEXT Indexes Specifically
-- ============================================================================

SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon' 
  AND INDEX_TYPE = 'FULLTEXT'
ORDER BY TABLE_NAME, INDEX_NAME;

-- ============================================================================
-- 3. Check Table Sizes and Index Usage
-- ============================================================================

SELECT 
    TABLE_NAME,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Size (MB)',
    ROUND((DATA_LENGTH / 1024 / 1024), 2) AS 'Data (MB)',
    ROUND((INDEX_LENGTH / 1024 / 1024), 2) AS 'Indexes (MB)',
    TABLE_ROWS AS 'Estimated Rows'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'healthkon'
  AND TABLE_NAME IN (
    'medical_records',
    'medical_documents',
    'allergies',
    'diagnoses',
    'prescriptions',
    'lab_results'
  )
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- ============================================================================
-- 4. Test FULLTEXT Search (Example Queries)
-- ============================================================================

-- Test full-text search on medical_documents
-- Note: Replace 'diabetes' with actual search term
/*
SELECT 
    doc_id,
    patient_id,
    LEFT(extract_text, 200) AS text_preview,
    MATCH(extract_text) AGAINST('diabetes' IN NATURAL LANGUAGE MODE) AS relevance
FROM medical_documents
WHERE MATCH(extract_text) AGAINST('diabetes' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC
LIMIT 10;
*/

-- Test full-text search on medical_records
/*
SELECT 
    record_id,
    patient_id,
    diagnosis_summary,
    MATCH(diagnosis_summary) AGAINST('diabetes' IN NATURAL LANGUAGE MODE) AS relevance
FROM medical_records
WHERE MATCH(diagnosis_summary) AGAINST('diabetes' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC
LIMIT 10;
*/

-- ============================================================================
-- 5. Check Index Cardinality (Usefulness)
-- ============================================================================

SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    CASE 
        WHEN CARDINALITY IS NULL THEN 'Unknown'
        WHEN CARDINALITY = 0 THEN 'Not used'
        WHEN CARDINALITY < 10 THEN 'Low (may not be useful)'
        WHEN CARDINALITY < 100 THEN 'Medium'
        ELSE 'High (good)'
    END AS usefulness
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'healthkon'
  AND TABLE_NAME IN (
    'medical_records',
    'medical_documents',
    'allergies',
    'diagnoses',
    'prescriptions',
    'lab_results'
  )
  AND SEQ_IN_INDEX = 1  -- Only check first column of composite indexes
ORDER BY TABLE_NAME, INDEX_NAME;

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1. Run these queries to verify indexes were created
-- 2. Check FULLTEXT indexes are available (MySQL 5.6+)
-- 3. Monitor index usage over time
-- 4. Update statistics: ANALYZE TABLE table_name;
-- 5. If indexes are not used, consider dropping them to improve write performance

