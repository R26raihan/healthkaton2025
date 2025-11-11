# Medical Records Service

Service untuk mengelola rekam medis pasien dengan struktur lengkap.

## Struktur Folder

```
rm_service/
├── __init__.py
├── main.py                   # Main FastAPI application
├── app.py                    # Backward compatibility entry point
│
├── api/                      # API Layer
│   └── routes/               # API Routes
│       ├── __init__.py
│       └── medical_records.py
│
├── core/                     # Core Configuration
│   ├── __init__.py
│   ├── config.py             # Configuration
│   └── database.py           # Database connection (reuse dari auth)
│
├── models/                   # Database Models (SQLAlchemy)
│   ├── __init__.py
│   ├── medical_record.py     # Medical record header
│   ├── diagnosis.py          # Diagnoses
│   ├── prescription.py        # Prescriptions
│   ├── lab_result.py         # Lab results
│   ├── allergy.py            # Allergies
│   └── medical_document.py   # Medical documents
│
├── schemas/                  # Pydantic Schemas
│   ├── __init__.py
│   ├── medical_record.py
│   ├── diagnosis.py
│   ├── prescription.py
│   ├── lab_result.py
│   ├── allergy.py
│   └── medical_document.py
│
└── services/                 # Business Logic
    ├── __init__.py
    └── crud.py               # CRUD operations
```

## Database Tables

1. **medical_records** - Header rekam medis
2. **diagnoses** - Diagnosis per kunjungan (multi)
3. **prescriptions** - Resep obat
4. **lab_results** - Hasil pemeriksaan lab
5. **allergies** - Alergi pasien
6. **medical_documents** - Dokumen medis (PDF/Image)

## Setup Database

Jalankan SQL script untuk membuat tabel:
```bash
mysql -u root -p < DB/create_medical_records_tables.sql
```

## Cara Menjalankan

```bash
# Menggunakan uvicorn langsung
uvicorn rm_service.main:app --reload --port 8001

# Atau integrasikan dengan running.py
```

## API Endpoints

### Medical Records
- `POST /medical-records/` - Create medical record
- `GET /medical-records/{record_id}` - Get medical record dengan semua data terkait
- `GET /medical-records/patient/{patient_id}` - Get semua rekam medis pasien

### Diagnoses
- `POST /medical-records/{record_id}/diagnoses` - Add diagnosis
- `GET /medical-records/{record_id}/diagnoses` - Get diagnoses untuk rekam medis

### Prescriptions
- `POST /medical-records/{record_id}/prescriptions` - Add prescription
- `GET /medical-records/{record_id}/prescriptions` - Get prescriptions untuk rekam medis

### Lab Results
- `POST /medical-records/{record_id}/lab-results` - Add lab result
- `GET /medical-records/{record_id}/lab-results` - Get lab results untuk rekam medis

### Allergies
- `POST /medical-records/allergies` - Add allergy untuk pasien
- `GET /medical-records/allergies/patient/{patient_id}` - Get allergies pasien
- `DELETE /medical-records/allergies/{allergy_id}` - Delete allergy

### Medical Documents
- `POST /medical-records/documents` - Upload/add medical document
- `GET /medical-records/documents/patient/{patient_id}` - Get documents pasien
- `GET /medical-records/documents/record/{record_id}` - Get documents untuk rekam medis

## Notes

- Menggunakan UUID untuk semua primary keys
- Reuse database connection dari auth service
- Patient ID menggunakan UUID (harus sesuai dengan ID dari users/patients table)

