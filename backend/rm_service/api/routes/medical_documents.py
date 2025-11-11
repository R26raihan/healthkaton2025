"""
Medical Documents API Routes
"""
import uuid
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...core.dependencies import get_current_active_petugas_for_rm
from ...schemas.medical_document import MedicalDocumentCreate, MedicalDocumentResponse
from ...services.crud import (
    create_medical_document,
    get_medical_document_by_id,
    get_patient_documents,
    get_record_documents,
    update_medical_document,
    delete_medical_document,
)

router = APIRouter(prefix="/medical-documents", tags=["Medical Documents"])

# Medical Documents Routes
@router.post("/", response_model=MedicalDocumentResponse, status_code=status.HTTP_201_CREATED)
async def create_medical_document_route(
    document: MedicalDocumentCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Create a new medical document for a patient (Backoffice - Petugas only)"""
    doc_data = document.model_dump()
    doc_data["doc_id"] = str(uuid.uuid4())
    # patient_id harus diisi di request body
    if "patient_id" not in doc_data or not doc_data["patient_id"]:
        raise HTTPException(status_code=400, detail="patient_id is required")
    return create_medical_document(db, doc_data)

@router.get("/patient/{patient_id}", response_model=List[MedicalDocumentResponse])
async def get_patient_documents_route(
    patient_id: int,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all medical documents for a patient by ID (Backoffice - Petugas only)"""
    documents = get_patient_documents(db, patient_id)
    return [MedicalDocumentResponse.model_validate(d) for d in documents]

@router.get("/record/{record_id}", response_model=List[MedicalDocumentResponse])
async def get_record_documents_route(
    record_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get all medical documents for a medical record (Backoffice - Petugas only)"""
    documents = get_record_documents(db, record_id)
    return [MedicalDocumentResponse.model_validate(d) for d in documents]

@router.get("/{doc_id}", response_model=MedicalDocumentResponse)
async def get_medical_document_route(
    doc_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Get medical document by ID (Backoffice - Petugas only)"""
    document = get_medical_document_by_id(db, doc_id)
    if not document:
        raise HTTPException(status_code=404, detail="Medical document not found")
    
    return MedicalDocumentResponse.model_validate(document)

@router.put("/{doc_id}", response_model=MedicalDocumentResponse)
async def update_medical_document_route(
    doc_id: str,
    document: MedicalDocumentCreate,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Update a medical document (Backoffice - Petugas only)"""
    existing_document = get_medical_document_by_id(db, doc_id)
    if not existing_document:
        raise HTTPException(status_code=404, detail="Medical document not found")
    
    doc_data = document.model_dump()
    updated_document = update_medical_document(db, doc_id, doc_data)
    if not updated_document:
        raise HTTPException(status_code=404, detail="Medical document not found")
    return MedicalDocumentResponse.model_validate(updated_document)

@router.delete("/{doc_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_medical_document_route(
    doc_id: str,
    current_petugas = Depends(get_current_active_petugas_for_rm),
    db: Session = Depends(get_db)
):
    """Delete a medical document (Backoffice - Petugas only)"""
    existing_document = get_medical_document_by_id(db, doc_id)
    if not existing_document:
        raise HTTPException(status_code=404, detail="Medical document not found")
    
    success = delete_medical_document(db, doc_id)
    if not success:
        raise HTTPException(status_code=404, detail="Medical document not found")
    return None

