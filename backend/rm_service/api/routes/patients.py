"""
Patient Management API Routes (Admin Only)
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional, List

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.patient import PatientInfo, PatientUpdate, PatientDetailResponse, PatientListResponse
from ...schemas.diagnosis import DiagnosisResponse
from ...schemas.prescription import PrescriptionResponse
from ...schemas.lab_result import LabResultResponse
from ...services.crud import (
    get_patient_by_id,
    search_patients,
    get_all_patients,
    update_patient,
    delete_patient,
    get_complete_patient_data,
)

router = APIRouter(prefix="/patients", tags=["Patient Management (Admin)"])

@router.get("/", response_model=PatientListResponse, status_code=status.HTTP_200_OK)
async def list_patients(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    search: Optional[str] = Query(None, description="Search query (name, email, KTP, phone)"),
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Get list of all patients with pagination and optional search
    
    **Admin only** - Requires petugas authentication
    
    - **skip**: Number of records to skip (for pagination)
    - **limit**: Maximum number of records to return (1-1000)
    - **search**: Optional search query to filter by name, email, KTP number, or phone number
    """
    try:
        if search:
            patients, total = search_patients(db, search_query=search, skip=skip, limit=limit)
        else:
            patients, total = get_all_patients(db, skip=skip, limit=limit)
        
        # Convert to PatientInfo schema
        patient_list = [PatientInfo.model_validate(patient) for patient in patients]
        
        return PatientListResponse(
            patients=patient_list,
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving patients: {str(e)}"
        )

@router.get("/search", response_model=PatientListResponse, status_code=status.HTTP_200_OK)
async def search_patients_endpoint(
    q: str = Query(..., description="Search query (name, email, KTP, phone)"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Search patients by name, email, KTP number, or phone number
    
    **Admin only** - Requires petugas authentication
    
    - **q**: Search query string
    - **skip**: Number of records to skip (for pagination)
    - **limit**: Maximum number of records to return (1-1000)
    """
    try:
        patients, total = search_patients(db, search_query=q, skip=skip, limit=limit)
        
        # Convert to PatientInfo schema
        patient_list = [PatientInfo.model_validate(patient) for patient in patients]
        
        return PatientListResponse(
            patients=patient_list,
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error searching patients: {str(e)}"
        )

@router.get("/{patient_id}", response_model=PatientInfo, status_code=status.HTTP_200_OK)
async def get_patient(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Get patient information by ID
    
    **Admin only** - Requires petugas authentication
    
    - **patient_id**: Patient ID
    """
    try:
        patient = get_patient_by_id(db, patient_id)
        if not patient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )
        
        return PatientInfo.model_validate(patient)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving patient: {str(e)}"
        )

@router.get("/{patient_id}/detail", response_model=PatientDetailResponse, status_code=status.HTTP_200_OK)
async def get_patient_detail(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Get complete patient detail including all medical records, allergies, and documents
    
    **Admin only** - Requires petugas authentication
    
    - **patient_id**: Patient ID
    """
    try:
        patient_data = get_complete_patient_data(db, patient_id)
        if not patient_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )
        
        # Convert to response schema - get_complete_patient_data returns dict with model objects
        from ...schemas.medical_record import MedicalRecordFull
        
        # Convert medical records - diagnoses, prescriptions, lab_results are already model objects
        medical_records = []
        for record_dict in patient_data["medical_records"]:
            # Convert diagnoses, prescriptions, lab_results to response schemas
            diagnoses_list = [DiagnosisResponse.model_validate(d) for d in record_dict.get("diagnoses", [])]
            prescriptions_list = [PrescriptionResponse.model_validate(p) for p in record_dict.get("prescriptions", [])]
            lab_results_list = [LabResultResponse.model_validate(l) for l in record_dict.get("lab_results", [])]
            
            # Build MedicalRecordFull
            medical_record = MedicalRecordFull(
                record_id=record_dict["record_id"],
                patient_id=record_dict["patient_id"],
                visit_date=record_dict["visit_date"],
                visit_type=record_dict["visit_type"],
                diagnosis_summary=record_dict.get("diagnosis_summary"),
                notes=record_dict.get("notes"),
                doctor_name=record_dict.get("doctor_name"),
                facility_name=record_dict.get("facility_name"),
                created_at=record_dict.get("created_at"),
                diagnoses=diagnoses_list,
                prescriptions=prescriptions_list,
                lab_results=lab_results_list
            )
            medical_records.append(medical_record)
        
        # Convert allergies and documents
        from ...schemas.allergy import AllergyResponse
        from ...schemas.medical_document import MedicalDocumentResponse
        
        allergies_list = [AllergyResponse.model_validate(a) for a in patient_data.get("allergies", [])]
        documents_list = [MedicalDocumentResponse.model_validate(d) for d in patient_data.get("medical_documents", [])]
        
        return PatientDetailResponse(
            patient_info=PatientInfo.model_validate(patient_data["patient_info"]),
            medical_records=medical_records,
            allergies=allergies_list,
            medical_documents=documents_list,
            summary=patient_data.get("summary", {})
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving patient detail: {str(e)}"
        )

@router.put("/{patient_id}", response_model=PatientInfo, status_code=status.HTTP_200_OK)
async def update_patient_info(
    patient_id: int,
    patient_update: PatientUpdate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Update patient information
    
    **Admin only** - Requires petugas authentication
    
    - **patient_id**: Patient ID
    - **patient_update**: Patient data to update (all fields optional)
    """
    try:
        # Check if patient exists
        patient = get_patient_by_id(db, patient_id)
        if not patient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )
        
        # Convert Pydantic model to dict, excluding None values
        update_data = patient_update.model_dump(exclude_unset=True)
        
        # Update patient
        updated_patient = update_patient(db, patient_id, update_data)
        if not updated_patient:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update patient"
            )
        
        return PatientInfo.model_validate(updated_patient)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating patient: {str(e)}"
        )

@router.delete("/{patient_id}", status_code=status.HTTP_200_OK)
async def delete_patient_endpoint(
    patient_id: int,
    hard_delete: bool = Query(False, description="Permanently delete patient (default: soft delete)"),
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Delete patient (soft delete by default)
    
    **Admin only** - Requires petugas authentication
    
    - **patient_id**: Patient ID
    - **hard_delete**: If True, permanently delete patient. If False (default), soft delete (set is_active=False)
    """
    try:
        # Check if patient exists
        patient = get_patient_by_id(db, patient_id)
        if not patient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )
        
        # Delete patient
        success = delete_patient(db, patient_id, soft_delete=not hard_delete)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to delete patient"
            )
        
        return {
            "message": "Patient deleted successfully",
            "patient_id": patient_id,
            "hard_delete": hard_delete
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting patient: {str(e)}"
        )

