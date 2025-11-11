"""
Data Relations API Routes (Mobile - Read Only for Users)
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text

from ...core.database import get_db
from ...core.dependencies import get_current_active_user_for_rm_mobile

router = APIRouter(prefix="/relations", tags=["Data Relations (Mobile)"])

@router.get("/my-data-summary")
async def get_my_data_summary(
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get summary data for current user (all relations)
    **Requires user authentication** - User can only view their own data summary
    """
    patient_id = current_user.id
    
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
        raise HTTPException(status_code=404, detail="User data not found")
    
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

