"""
API Routes untuk cek relasi data
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import Dict, List
import sys
import os

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm

router = APIRouter(prefix="/relations", tags=["Data Relations"])

@router.get("/patient/{patient_id}/summary")
async def get_patient_data_summary(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Get summary data untuk patient tertentu (Backoffice - Petugas only)
    **Requires petugas authentication**
    """
    
    # Query untuk mendapatkan summary
    query = text("""
        SELECT 
            u.id,
            u.name,
            u.email,
            COUNT(DISTINCT mr.record_id) AS total_medical_records,
            COUNT(DISTINCT d.diagnosis_id) AS total_diagnoses,
            COUNT(DISTINCT p.prescription_id) AS total_prescriptions,
            COUNT(DISTINCT lr.lab_id) AS total_lab_results,
            COUNT(DISTINCT a.allergy_id) AS total_allergies,
            COUNT(DISTINCT md.doc_id) AS total_documents
        FROM users u
        LEFT JOIN medical_records mr ON u.id = mr.patient_id
        LEFT JOIN diagnoses d ON mr.record_id = d.record_id
        LEFT JOIN prescriptions p ON mr.record_id = p.record_id
        LEFT JOIN lab_results lr ON mr.record_id = lr.record_id
        LEFT JOIN allergies a ON u.id = a.patient_id
        LEFT JOIN medical_documents md ON u.id = md.patient_id
        WHERE u.id = :patient_id
        GROUP BY u.id, u.name, u.email
    """)
    
    result = db.execute(query, {"patient_id": patient_id}).fetchone()
    
    if not result:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    return {
        "patient_id": result[0],
        "patient_name": result[1],
        "patient_email": result[2],
        "summary": {
            "total_medical_records": result[3] or 0,
            "total_diagnoses": result[4] or 0,
            "total_prescriptions": result[5] or 0,
            "total_lab_results": result[6] or 0,
            "total_allergies": result[7] or 0,
            "total_documents": result[8] or 0
        }
    }

@router.get("/record/{record_id}/full-relation")
async def get_record_full_relation(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Get full relation data untuk satu medical record (Backoffice - Petugas only)
    """
    # Get medical record dengan user info
    record_query = text("""
        SELECT 
            mr.record_id,
            u.id AS patient_id,
            u.name AS patient_name,
            u.email AS patient_email,
            mr.visit_date,
            mr.visit_type,
            mr.diagnosis_summary,
            mr.notes,
            mr.doctor_name,
            mr.facility_name,
            mr.created_at
        FROM medical_records mr
        INNER JOIN users u ON mr.patient_id = u.id
        WHERE mr.record_id = :record_id
    """)
    
    record = db.execute(record_query, {"record_id": record_id}).fetchone()
    
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    # Get diagnoses
    diagnoses_query = text("""
        SELECT diagnosis_id, icd_code, diagnosis_name, primary_flag
        FROM diagnoses
        WHERE record_id = :record_id
    """)
    diagnoses = db.execute(diagnoses_query, {"record_id": record_id}).fetchall()
    
    # Get prescriptions
    prescriptions_query = text("""
        SELECT prescription_id, drug_name, dosage, frequency, duration_days
        FROM prescriptions
        WHERE record_id = :record_id
    """)
    prescriptions = db.execute(prescriptions_query, {"record_id": record_id}).fetchall()
    
    # Get lab results
    lab_query = text("""
        SELECT lab_id, test_name, result_value, result_unit, normal_range
        FROM lab_results
        WHERE record_id = :record_id
    """)
    lab_results = db.execute(lab_query, {"record_id": record_id}).fetchall()
    
    return {
        "record_id": record[0],
        "patient": {
            "id": record[1],
            "name": record[2],
            "email": record[3]
        },
        "visit": {
            "date": str(record[4]),
            "type": record[5],
            "diagnosis_summary": record[6],
            "notes": record[7],
            "doctor_name": record[8],
            "facility_name": record[9],
            "created_at": str(record[10])
        },
        "diagnoses": [
            {
                "diagnosis_id": d[0],
                "icd_code": d[1],
                "diagnosis_name": d[2],
                "primary_flag": bool(d[3])
            } for d in diagnoses
        ],
        "prescriptions": [
            {
                "prescription_id": p[0],
                "drug_name": p[1],
                "dosage": p[2],
                "frequency": p[3],
                "duration_days": p[4]
            } for p in prescriptions
        ],
        "lab_results": [
            {
                "lab_id": l[0],
                "test_name": l[1],
                "result_value": l[2],
                "result_unit": l[3],
                "normal_range": l[4]
            } for l in lab_results
        ]
    }

