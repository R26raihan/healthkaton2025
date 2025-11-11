"""
Medical Records API Routes
"""
import uuid
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.medical_record import MedicalRecordCreate, MedicalRecordResponse, MedicalRecordFull
from ...schemas.diagnosis import DiagnosisCreate, DiagnosisResponse
from ...schemas.prescription import PrescriptionCreate, PrescriptionResponse
from ...schemas.lab_result import LabResultCreate, LabResultResponse
from ...schemas.allergy import AllergyCreate, AllergyResponse
from ...schemas.medical_document import MedicalDocumentCreate, MedicalDocumentResponse
from ...schemas.patient import PatientDetailResponse, PatientInfo
from ...services.crud import (
    create_medical_record,
    get_medical_record,
    get_patient_records,
    update_medical_record,
    delete_medical_record,
    create_diagnosis,
    get_record_diagnoses,
    create_prescription,
    get_record_prescriptions,
    create_lab_result,
    get_record_lab_results,
    create_allergy,
    get_patient_allergies,
    delete_allergy,
    create_medical_document,
    get_patient_documents,
    get_record_documents,
    get_complete_patient_data,
)

router = APIRouter(prefix="/medical-records", tags=["Medical Records"])

# Medical Records Routes
@router.post("/", response_model=MedicalRecordResponse, status_code=status.HTTP_201_CREATED)
async def create_record(
    record: MedicalRecordCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Create a new medical record (Backoffice - Petugas only)
    
    **Requires petugas authentication** - Only petugas (staff) can create medical records
    
    **Request Body:**
    - `patient_id`: int (required) - ID pasien dari table users
    - `visit_date`: DateTime (ISO format, e.g., "2024-01-15T10:30:00")
    - `visit_type`: Enum - "outpatient", "inpatient", or "emergency"
    - `diagnosis_summary`: Optional string
    - `notes`: Optional string
    - `doctor_name`: Optional string
    - `facility_name`: Optional string
    
    **Example:**
    ```json
    {
        "patient_id": 1,
        "visit_date": "2024-01-15T10:30:00",
        "visit_type": "outpatient",
        "diagnosis_summary": "Regular checkup",
        "notes": "Patient is healthy",
        "doctor_name": "Dr. Smith",
        "facility_name": "Hospital ABC"
    }
    ```
    
    **Response:**
    Returns the created medical record with `record_id` that can be used to add
    diagnoses, prescriptions, and lab results.
    """
    try:
        # Validate that petugas exists (should already be validated by auth, but double-check)
        if not current_petugas or not current_petugas.id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Petugas not authenticated"
            )
        
        record_data = record.model_dump()
        record_data["record_id"] = str(uuid.uuid4())
        # patient_id harus diisi di request body untuk backoffice
        if "patient_id" not in record_data or not record_data["patient_id"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="patient_id is required"
            )
        
        # Create the medical record
        created_record = create_medical_record(db, record_data)
        
        # Return response
        return MedicalRecordResponse.model_validate(created_record)
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        # Log error for debugging
        import traceback
        print(f"[RM] Error creating medical record: {str(e)}")
        print(f"[RM] Traceback: {traceback.format_exc()}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error creating medical record: {str(e)}"
        )

@router.get("/{record_id}", response_model=MedicalRecordFull)
async def get_record(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get medical record by ID with all related data (Backoffice - Petugas only)"""
    from ...schemas.diagnosis import DiagnosisResponse
    from ...schemas.prescription import PrescriptionResponse
    from ...schemas.lab_result import LabResultResponse
    
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    # Get related data
    diagnoses = [DiagnosisResponse.model_validate(d) for d in get_record_diagnoses(db, record_id)]
    prescriptions = [PrescriptionResponse.model_validate(p) for p in get_record_prescriptions(db, record_id)]
    lab_results = [LabResultResponse.model_validate(l) for l in get_record_lab_results(db, record_id)]
    
    record_dict = MedicalRecordResponse.model_validate(record).model_dump()
    record_dict["diagnoses"] = [d.model_dump() for d in diagnoses]
    record_dict["prescriptions"] = [p.model_dump() for p in prescriptions]
    record_dict["lab_results"] = [l.model_dump() for l in lab_results]
    
    return record_dict

@router.get("/patient/{patient_id}/records", response_model=List[MedicalRecordResponse])
async def get_patient_records_route(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Get all medical records for a patient by ID (Backoffice - Petugas only)
    **Requires petugas authentication** - Petugas can view records for any patient
    """
    return get_patient_records(db, patient_id, skip, limit)

@router.put("/{record_id}", response_model=MedicalRecordResponse)
async def update_record(
    record_id: str,
    record: MedicalRecordCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Update a medical record (Backoffice - Petugas only)"""
    # Check if record exists - petugas can update any record
    existing_record = get_medical_record(db, record_id)
    if not existing_record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    record_data = record.model_dump()
    updated_record = update_medical_record(db, record_id, record_data)
    if not updated_record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    return MedicalRecordResponse.model_validate(updated_record)

@router.delete("/{record_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_record(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Delete a medical record (Backoffice - Petugas only)"""
    # Check if record exists - petugas can delete any record
    existing_record = get_medical_record(db, record_id)
    if not existing_record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    success = delete_medical_record(db, record_id)
    if not success:
        raise HTTPException(status_code=404, detail="Medical record not found")
    return None

# Diagnoses Routes (Backoffice - Petugas only)
@router.post("/{record_id}/diagnoses", response_model=DiagnosisResponse, status_code=status.HTTP_201_CREATED)
async def add_diagnosis(
    record_id: str,
    diagnosis: DiagnosisCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Add diagnosis to a medical record (Backoffice - Petugas only)"""
    # Verify record exists
    if not get_medical_record(db, record_id):
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    diagnosis_data = diagnosis.model_dump()
    diagnosis_data["diagnosis_id"] = str(uuid.uuid4())
    diagnosis_data["record_id"] = record_id
    return create_diagnosis(db, diagnosis_data)

@router.get("/{record_id}/diagnoses", response_model=List[DiagnosisResponse])
async def get_diagnoses(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all diagnoses for a medical record (Backoffice - Petugas only)"""
    return get_record_diagnoses(db, record_id)

# Prescriptions Routes (Backoffice - Petugas only)
@router.post("/{record_id}/prescriptions", response_model=PrescriptionResponse, status_code=status.HTTP_201_CREATED)
async def add_prescription(
    record_id: str,
    prescription: PrescriptionCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Add prescription to a medical record (Backoffice - Petugas only)"""
    if not get_medical_record(db, record_id):
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    prescription_data = prescription.model_dump()
    prescription_data["prescription_id"] = str(uuid.uuid4())
    prescription_data["record_id"] = record_id
    return create_prescription(db, prescription_data)

@router.get("/{record_id}/prescriptions", response_model=List[PrescriptionResponse])
async def get_prescriptions(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all prescriptions for a medical record (Backoffice - Petugas only)"""
    return get_record_prescriptions(db, record_id)

# Lab Results Routes (Backoffice - Petugas only)
@router.post("/{record_id}/lab-results", response_model=LabResultResponse, status_code=status.HTTP_201_CREATED)
async def add_lab_result(
    record_id: str,
    lab_result: LabResultCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Add lab result to a medical record (Backoffice - Petugas only)"""
    if not get_medical_record(db, record_id):
        raise HTTPException(status_code=404, detail="Medical record not found")
    
    lab_data = lab_result.model_dump()
    lab_data["lab_id"] = str(uuid.uuid4())
    lab_data["record_id"] = record_id
    return create_lab_result(db, lab_data)

@router.get("/{record_id}/lab-results", response_model=List[LabResultResponse])
async def get_lab_results(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all lab results for a medical record (Backoffice - Petugas only)"""
    return get_record_lab_results(db, record_id)


# Patient Detail Routes (Backoffice - Petugas only)
@router.get("/patients/{patient_id}/detail", response_model=PatientDetailResponse)
async def get_patient_detail(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """
    Get complete patient detail with all medical data
    
    Returns:
    - Patient information (name, email, phone, etc.)
    - All medical records with diagnoses, prescriptions, lab results
    - All allergies
    - All medical documents
    - Summary statistics
    
    **Parameters:**
    - `patient_id` (int): ID pasien (sama dengan users.id)
    
    **Example:**
    - GET /medical-records/patients/1/detail
    """
    import traceback
    from ...schemas.diagnosis import DiagnosisResponse
    from ...schemas.prescription import PrescriptionResponse
    from ...schemas.lab_result import LabResultResponse
    
    try:
        # Get complete patient data
        patient_data = get_complete_patient_data(db, patient_id)
        
        if not patient_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )
        
        # Format patient info
        try:
            patient_info = PatientInfo.model_validate(patient_data["patient_info"])
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error formatting patient info: {str(e)}"
            )
        
        # Format medical records with all related data
        formatted_records = []
        for record in patient_data["medical_records"]:
            try:
                record_response = MedicalRecordResponse.model_validate({
                    "record_id": record["record_id"],
                    "patient_id": record["patient_id"],
                    "visit_date": record["visit_date"],
                    "visit_type": record["visit_type"],
                    "diagnosis_summary": record["diagnosis_summary"],
                    "notes": record["notes"],
                    "doctor_name": record["doctor_name"],
                    "facility_name": record["facility_name"],
                    "created_at": record["created_at"],
                })
                
                # Add related data
                diagnoses = []
                for d in record["diagnoses"]:
                    try:
                        diagnoses.append(DiagnosisResponse.model_validate(d).model_dump())
                    except Exception as e:
                        # Skip invalid diagnosis, log error
                        print(f"Warning: Skipping invalid diagnosis: {e}")
                
                prescriptions = []
                for p in record["prescriptions"]:
                    try:
                        prescriptions.append(PrescriptionResponse.model_validate(p).model_dump())
                    except Exception as e:
                        print(f"Warning: Skipping invalid prescription: {e}")
                
                lab_results = []
                for l in record["lab_results"]:
                    try:
                        lab_results.append(LabResultResponse.model_validate(l).model_dump())
                    except Exception as e:
                        print(f"Warning: Skipping invalid lab result: {e}")
                
                record_dict = record_response.model_dump()
                record_dict["diagnoses"] = diagnoses
                record_dict["prescriptions"] = prescriptions
                record_dict["lab_results"] = lab_results
                
                formatted_records.append(record_dict)
            except Exception as e:
                print(f"Error formatting record {record.get('record_id', 'unknown')}: {e}")
                traceback.print_exc()
                # Continue with other records
        
        # Format allergies
        allergies = []
        for a in patient_data["allergies"]:
            try:
                allergies.append(AllergyResponse.model_validate(a).model_dump())
            except Exception as e:
                print(f"Warning: Skipping invalid allergy: {e}")
        
        # Format documents
        documents = []
        for d in patient_data["medical_documents"]:
            try:
                documents.append(MedicalDocumentResponse.model_validate(d).model_dump())
            except Exception as e:
                print(f"Warning: Skipping invalid document: {e}")
        
        return {
            "patient_info": patient_info.model_dump(),
            "medical_records": formatted_records,
            "allergies": allergies,
            "medical_documents": documents,
            "summary": patient_data["summary"]
        }
    
    except HTTPException:
        raise
    except Exception as e:
        error_msg = str(e)
        traceback_str = traceback.format_exc()
        print(f"Error in get_patient_detail: {error_msg}")
        print(traceback_str)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {error_msg}"
        )

