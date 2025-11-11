# Database Optimization for RAG Service

## Overview
Script SQL ini menambahkan indexes dan optimasi database untuk meningkatkan performa RAG (Retrieval-Augmented Generation) service.

## Files

### 1. `add_indexes_for_rag_optimization.sql`
Script utama untuk menambahkan indexes dan optimasi.

**Isi:**
- **FULLTEXT Indexes**: Untuk pencarian teks cepat pada kolom text (extract_text, diagnosis_summary, notes, dll)
- **Composite Indexes**: Untuk query yang menggunakan multiple columns (patient_id + visit_date, dll)
- **Additional Indexes**: Untuk kolom yang sering digunakan dalam WHERE clause
- **Optional Tables**: Tabel untuk embeddings, query cache, dan logs (dikomentari, untuk future use)

### 2. `verify_indexes.sql`
Script untuk memverifikasi bahwa semua indexes berhasil dibuat.

**Isi:**
- Check indexes pada setiap table
- Check FULLTEXT indexes
- Check table sizes dan index usage
- Test queries untuk FULLTEXT search
- Check index cardinality

### 3. `create_medical_records_tables.sql`
Script existing untuk membuat tabel medis (sudah ada).

## Cara Menggunakan

### Step 1: Buat Tabel (jika belum)
```bash
mysql -u root -p < DB/create_medical_records_tables.sql
```

### Step 2: Tambahkan Indexes
```bash
mysql -u root -p < DB/add_indexes_for_rag_optimization.sql
```

### Step 3: Verifikasi Indexes
```bash
mysql -u root -p < DB/verify_indexes.sql
```

Atau jalankan secara manual:
```bash
mysql -u root -p healthkon
```

Lalu jalankan query dari `verify_indexes.sql`.

## Indexes yang Ditambahkan

### FULLTEXT Indexes
1. **medical_documents.extract_text** - Paling penting untuk RAG document search
2. **medical_records.diagnosis_summary** - Untuk pencarian diagnosis
3. **medical_records.notes** - Untuk pencarian catatan
4. **allergies.notes** - Untuk pencarian catatan alergi
5. **prescriptions.notes** - Untuk pencarian catatan resep
6. **lab_results.interpretation** - Untuk pencarian interpretasi lab

### Composite Indexes
1. **medical_records (patient_id, visit_date DESC)** - Query pasien sorted by date
2. **medical_documents (patient_id, created_at DESC)** - Query dokumen pasien sorted by date
3. **medical_documents (record_id, created_at DESC)** - Query dokumen per record
4. **allergies (patient_id, severity)** - Query alergi pasien by severity
5. **diagnoses (record_id, primary_flag)** - Query primary diagnosis

### Additional Indexes
1. **medical_records.doctor_name** - Pencarian by doctor
2. **medical_records.facility_name** - Pencarian by facility
3. **diagnoses.diagnosis_name** - Pencarian by diagnosis name
4. **prescriptions.drug_code** - Pencarian by drug code
5. **lab_results (test_name, result_value)** - Query test results

## Optional Tables (Future Enhancement)

### 1. document_embeddings
Tabel untuk menyimpan vector embeddings untuk semantic search.
- Uncomment jika ingin implementasi vector-based semantic search
- Menyimpan embeddings dari text documents
- Support chunking untuk dokumen panjang

### 2. rag_query_cache
Tabel untuk caching query dan answer.
- Uncomment jika ingin implementasi query caching
- Meningkatkan performa untuk query yang sering ditanyakan
- Support expiration time

### 3. rag_query_logs
Tabel untuk logging semua query RAG.
- Uncomment jika ingin tracking dan analytics
- Berguna untuk monitoring dan improvement
- Track query patterns dan success rate

## Requirements

### MySQL Version
- **Minimum**: MySQL 5.6+ (untuk FULLTEXT indexes di InnoDB)
- **Recommended**: MySQL 8.0+ (better performance)

### Configuration
Untuk FULLTEXT indexes, pastikan konfigurasi berikut:
```sql
-- Check current settings
SHOW VARIABLES LIKE 'innodb_ft_min_token_size';
SHOW VARIABLES LIKE 'ft_min_word_len';

-- Jika perlu, ubah minimum token size (default: 4)
-- Note: Perlu restart MySQL setelah perubahan
SET GLOBAL innodb_ft_min_token_size = 1;
```

## Performance Impact

### Positive Impact
- ✅ **Faster Text Search**: FULLTEXT indexes memungkinkan pencarian teks yang sangat cepat
- ✅ **Optimized Queries**: Composite indexes mengoptimalkan query dengan multiple WHERE clauses
- ✅ **Better JOIN Performance**: Indexes pada foreign keys meningkatkan performa JOIN
- ✅ **Sorted Results**: Indexes dengan DESC membantu query yang perlu sorting

### Negative Impact
- ⚠️ **Slower Writes**: Setiap index menambah overhead pada INSERT/UPDATE/DELETE
- ⚠️ **Storage Space**: Indexes membutuhkan storage space tambahan
- ⚠️ **Maintenance**: Indexes perlu di-maintain dan di-update

### Recommendations
1. **Monitor Index Usage**: Gunakan `EXPLAIN` untuk melihat apakah indexes digunakan
2. **Update Statistics**: Jalankan `ANALYZE TABLE` secara berkala
3. **Drop Unused Indexes**: Jika index tidak digunakan, consider untuk drop
4. **Balance**: Jangan over-index, hanya index kolom yang benar-benar digunakan

## Testing

### Test FULLTEXT Search
```sql
-- Test search on medical_documents
SELECT 
    doc_id,
    patient_id,
    LEFT(extract_text, 200) AS text_preview,
    MATCH(extract_text) AGAINST('diabetes' IN NATURAL LANGUAGE MODE) AS relevance
FROM medical_documents
WHERE MATCH(extract_text) AGAINST('diabetes' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC
LIMIT 10;

-- Test search on medical_records
SELECT 
    record_id,
    patient_id,
    diagnosis_summary,
    MATCH(diagnosis_summary, notes) AGAINST('hipertensi' IN NATURAL LANGUAGE MODE) AS relevance
FROM medical_records
WHERE MATCH(diagnosis_summary, notes) AGAINST('hipertensi' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC
LIMIT 10;
```

### Check Index Usage
```sql
-- Check if index is used in query
EXPLAIN SELECT * FROM medical_records 
WHERE patient_id = 1 
ORDER BY visit_date DESC 
LIMIT 10;

-- Should show: key = idx_patient_visit_date
```

## Troubleshooting

### Problem: FULLTEXT index tidak bekerja
**Solution:**
1. Pastikan MySQL version >= 5.6
2. Pastikan table engine = InnoDB
3. Check minimum token size: `SHOW VARIABLES LIKE 'innodb_ft_min_token_size';`
4. Rebuild index: `ALTER TABLE table_name DROP INDEX idx_name; ALTER TABLE table_name ADD FULLTEXT INDEX idx_name (column_name);`

### Problem: Index tidak digunakan
**Solution:**
1. Update statistics: `ANALYZE TABLE table_name;`
2. Check query dengan `EXPLAIN`
3. Pastikan query menggunakan kolom yang di-index
4. Consider composite index jika query menggunakan multiple columns

### Problem: Slow writes setelah menambah index
**Solution:**
1. Monitor index usage
2. Drop unused indexes
3. Consider batch inserts instead of individual inserts
4. Optimize index columns (jangan index kolom yang terlalu panjang)

## Next Steps

1. **Implement Vector Embeddings**: Uncomment `document_embeddings` table untuk semantic search
2. **Implement Query Caching**: Uncomment `rag_query_cache` table untuk caching
3. **Implement Query Logging**: Uncomment `rag_query_logs` table untuk analytics
4. **Monitor Performance**: Gunakan `verify_indexes.sql` untuk monitoring
5. **Optimize Queries**: Gunakan `EXPLAIN` untuk optimize queries

## References

- [MySQL FULLTEXT Indexes](https://dev.mysql.com/doc/refman/8.0/en/fulltext-search.html)
- [MySQL Composite Indexes](https://dev.mysql.com/doc/refman/8.0/en/multiple-column-indexes.html)
- [MySQL Index Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html)

