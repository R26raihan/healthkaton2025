"""
Medical Documents API Routes (Mobile - Read Only for Users)
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...core.database import get_db
from ...core.dependencies import get_current_active_user_for_rm_mobile
import sys
import os

# Add parent directory to import from rm_service
_parent_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.append(_parent_dir)

from rm_service.schemas.medical_document import MedicalDocumentResponse
from rm_service.services.crud import (
    get_medical_document_by_id,
    get_patient_documents,
    get_record_documents,
    get_medical_record,
)

router = APIRouter(prefix="/medical-documents", tags=["Medical Documents (Mobile)"])

@router.get("/my-documents", response_model=List[MedicalDocumentResponse])
async def get_my_documents(
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get all medical documents for current user
    **Requires user authentication** - User can only view their own documents
    """
    documents = get_patient_documents(db, current_user.id)
    return [MedicalDocumentResponse.model_validate(d) for d in documents]

@router.get("/record/{record_id}", response_model=List[MedicalDocumentResponse])
async def get_record_documents_route(
    record_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get all medical documents for a medical record
    **Requires user authentication** - User can only view documents for their own records
    """
    # Verify that the medical record exists and belongs to current user
    record = get_medical_record(db, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Medical record not found")
    if record.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this record"
        )
    
    documents = get_record_documents(db, record_id)
    return [MedicalDocumentResponse.model_validate(d) for d in documents]

@router.get("/{doc_id}", response_model=MedicalDocumentResponse)
async def get_medical_document_route(
    doc_id: str,
    current_user = Depends(get_current_active_user_for_rm_mobile),
    db: Session = Depends(get_db)
):
    """
    Get medical document by ID
    **Requires user authentication** - User can only view their own documents
    """
    document = get_medical_document_by_id(db, doc_id)
    if not document:
        raise HTTPException(status_code=404, detail="Medical document not found")
    
    # Verify that the document belongs to current user
    if document.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this document"
        )
    
    return MedicalDocumentResponse.model_validate(document)

