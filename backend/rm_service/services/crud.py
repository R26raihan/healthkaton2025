"""
CRUD operations for Medical Records
"""
from sqlalchemy.orm import Session
from typing import List, Optional, Tuple
import uuid

from ..models.medical_record import MedicalRecord
from ..models.diagnosis import Diagnosis
from ..models.prescription import Prescription
from ..models.lab_result import LabResult
from ..models.allergy import Allergy
from ..models.medical_document import MedicalDocument

# Medical Records CRUD
def create_medical_record(db: Session, record_data: dict) -> MedicalRecord:
    """Create a new medical record"""
    from sqlalchemy import text
    from ..models.medical_record import VisitType
    
    # Convert visit_type to UPPERCASE for database (MySQL enum uses UPPERCASE: OUTPATIENT, INPATIENT, EMERGENCY)
    visit_type_value = record_data.get("visit_type")
    if visit_type_value:
        # Handle if it's an enum object (from Pydantic schema - value is lowercase)
        if hasattr(visit_type_value, 'value'):
            # Convert from lowercase ("outpatient") to UPPERCASE ("OUTPATIENT")
            visit_type_str = visit_type_value.value.upper()
        # Handle if it's already a string
        elif isinstance(visit_type_value, str):
            visit_type_str = visit_type_value.upper()
        # Handle if it's a VisitType enum member
        elif isinstance(visit_type_value, VisitType):
            visit_type_str = visit_type_value.value.upper()
        else:
            visit_type_str = str(visit_type_value).upper()
    else:
        visit_type_str = "OUTPATIENT"  # default (UPPERCASE for database)
    
    # Validate visit_type value (UPPERCASE)
    valid_types = ["OUTPATIENT", "INPATIENT", "EMERGENCY"]
    if visit_type_str not in valid_types:
        raise ValueError(f"Invalid visit_type: {visit_type_str}. Must be one of {valid_types}")
    
    # Use raw SQL to insert with proper enum value (UPPERCASE for MySQL enum)
    query = text("""
        INSERT INTO medical_records 
        (record_id, patient_id, visit_date, visit_type, diagnosis_summary, notes, doctor_name, facility_name)
        VALUES 
        (:record_id, :patient_id, :visit_date, :visit_type, :diagnosis_summary, :notes, :doctor_name, :facility_name)
    """)
    
    db.execute(query, {
        "record_id": record_data.get("record_id"),
        "patient_id": record_data.get("patient_id"),
        "visit_date": record_data.get("visit_date"),
        "visit_type": visit_type_str,  # UPPERCASE for MySQL enum
        "diagnosis_summary": record_data.get("diagnosis_summary"),
        "notes": record_data.get("notes"),
        "doctor_name": record_data.get("doctor_name"),
        "facility_name": record_data.get("facility_name"),
    })
    db.commit()
    
    # Get the created record using get_medical_record
    return get_medical_record(db, record_data.get("record_id"))

def get_medical_record(db: Session, record_id: str) -> Optional[MedicalRecord]:
    """Get medical record by ID"""
    from sqlalchemy import text
    from ..models.medical_record import VisitType
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT record_id, patient_id, visit_date, visit_type, diagnosis_summary, 
               notes, doctor_name, facility_name, created_at
        FROM medical_records
        WHERE record_id = :record_id
    """)
    
    result = db.execute(query, {"record_id": record_id}).first()
    
    if not result:
        return None
    
    # Convert visit_type string to enum
    # Database stores UPPERCASE (OUTPATIENT, INPATIENT, EMERGENCY)
    # Python enum uses lowercase values
    visit_type_str = result.visit_type
    if visit_type_str:
        visit_type_str = visit_type_str.lower()  # Convert UPPERCASE to lowercase
    
    visit_type_enum = None
    for vt in VisitType:
        if vt.value == visit_type_str:
            visit_type_enum = vt
            break
    
    if not visit_type_enum:
        visit_type_enum = VisitType.OUTPATIENT  # default
    
    return MedicalRecord(
        record_id=result.record_id,
        patient_id=result.patient_id,
        visit_date=result.visit_date,
        visit_type=visit_type_enum,
        diagnosis_summary=result.diagnosis_summary,
        notes=result.notes,
        doctor_name=result.doctor_name,
        facility_name=result.facility_name,
        created_at=result.created_at
    )

def get_patient_records(db: Session, patient_id: int, skip: int = 0, limit: int = 100) -> List[MedicalRecord]:
    """Get all medical records for a patient"""
    from sqlalchemy import text
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT record_id, patient_id, visit_date, visit_type, diagnosis_summary, 
               notes, doctor_name, facility_name, created_at
        FROM medical_records
        WHERE patient_id = :patient_id
        ORDER BY visit_date DESC
        LIMIT :limit OFFSET :skip
    """)
    
    result = db.execute(query, {"patient_id": patient_id, "limit": limit, "skip": skip})
    records = []
    
    for row in result:
        # Convert visit_type string to enum
        # Database stores UPPERCASE (OUTPATIENT, INPATIENT, EMERGENCY)
        # Python enum uses lowercase values
        visit_type_str = row.visit_type
        if visit_type_str:
            visit_type_str = visit_type_str.lower()  # Convert UPPERCASE to lowercase
        
        from ..models.medical_record import VisitType
        visit_type_enum = None
        for vt in VisitType:
            if vt.value == visit_type_str:
                visit_type_enum = vt
                break
        
        if not visit_type_enum:
            visit_type_enum = VisitType.OUTPATIENT  # default
        
        record = MedicalRecord(
            record_id=row.record_id,
            patient_id=row.patient_id,
            visit_date=row.visit_date,
            visit_type=visit_type_enum,
            diagnosis_summary=row.diagnosis_summary,
            notes=row.notes,
            doctor_name=row.doctor_name,
            facility_name=row.facility_name,
            created_at=row.created_at
        )
        records.append(record)
    
    return records

def update_medical_record(db: Session, record_id: str, record_data: dict) -> Optional[MedicalRecord]:
    """Update a medical record"""
    from sqlalchemy import text
    
    # Get existing record
    record = get_medical_record(db, record_id)
    if not record:
        return None
    
    # Build update query
    update_fields = []
    update_values = {"record_id": record_id}
    
    if "patient_id" in record_data:
        update_fields.append("patient_id = :patient_id")
        update_values["patient_id"] = record_data["patient_id"]
    if "visit_date" in record_data:
        update_fields.append("visit_date = :visit_date")
        update_values["visit_date"] = record_data["visit_date"]
    if "visit_type" in record_data:
        update_fields.append("visit_type = :visit_type")
        # Convert visit_type to UPPERCASE for database
        visit_type_val = record_data["visit_type"]
        if hasattr(visit_type_val, "value"):
            # Pydantic enum - convert to UPPERCASE
            update_values["visit_type"] = visit_type_val.value.upper()
        elif isinstance(visit_type_val, str):
            update_values["visit_type"] = visit_type_val.upper()
        else:
            update_values["visit_type"] = str(visit_type_val).upper()
    if "diagnosis_summary" in record_data:
        update_fields.append("diagnosis_summary = :diagnosis_summary")
        update_values["diagnosis_summary"] = record_data["diagnosis_summary"]
    if "notes" in record_data:
        update_fields.append("notes = :notes")
        update_values["notes"] = record_data["notes"]
    if "doctor_name" in record_data:
        update_fields.append("doctor_name = :doctor_name")
        update_values["doctor_name"] = record_data["doctor_name"]
    if "facility_name" in record_data:
        update_fields.append("facility_name = :facility_name")
        update_values["facility_name"] = record_data["facility_name"]
    
    if not update_fields:
        return record
    
    query = text(f"""
        UPDATE medical_records
        SET {', '.join(update_fields)}
        WHERE record_id = :record_id
    """)
    
    db.execute(query, update_values)
    db.commit()
    
    return get_medical_record(db, record_id)

def delete_medical_record(db: Session, record_id: str) -> bool:
    """Delete a medical record (cascade will delete related records)"""
    record = get_medical_record(db, record_id)
    if not record:
        return False
    
    from sqlalchemy import text
    query = text("DELETE FROM medical_records WHERE record_id = :record_id")
    db.execute(query, {"record_id": record_id})
    db.commit()
    return True

# Diagnoses CRUD
def create_diagnosis(db: Session, diagnosis_data: dict) -> Diagnosis:
    """Create a new diagnosis"""
    diagnosis = Diagnosis(**diagnosis_data)
    db.add(diagnosis)
    db.commit()
    db.refresh(diagnosis)
    return diagnosis

def get_record_diagnoses(db: Session, record_id: str) -> List[Diagnosis]:
    """Get all diagnoses for a medical record"""
    return db.query(Diagnosis).filter(Diagnosis.record_id == record_id).all()

def get_diagnosis_by_id(db: Session, diagnosis_id: str) -> Optional[Diagnosis]:
    """Get diagnosis by ID"""
    return db.query(Diagnosis).filter(Diagnosis.diagnosis_id == diagnosis_id).first()

def update_diagnosis(db: Session, diagnosis_id: str, diagnosis_data: dict) -> Optional[Diagnosis]:
    """Update a diagnosis"""
    diagnosis = get_diagnosis_by_id(db, diagnosis_id)
    if not diagnosis:
        return None
    
    for key, value in diagnosis_data.items():
        if hasattr(diagnosis, key):
            setattr(diagnosis, key, value)
    
    db.commit()
    db.refresh(diagnosis)
    return diagnosis

def delete_diagnosis(db: Session, diagnosis_id: str) -> bool:
    """Delete a diagnosis"""
    diagnosis = get_diagnosis_by_id(db, diagnosis_id)
    if not diagnosis:
        return False
    
    db.delete(diagnosis)
    db.commit()
    return True

# Prescriptions CRUD
def create_prescription(db: Session, prescription_data: dict) -> Prescription:
    """Create a new prescription"""
    prescription = Prescription(**prescription_data)
    db.add(prescription)
    db.commit()
    db.refresh(prescription)
    return prescription

def get_record_prescriptions(db: Session, record_id: str) -> List[Prescription]:
    """Get all prescriptions for a medical record"""
    return db.query(Prescription).filter(Prescription.record_id == record_id).all()

def get_patient_prescriptions(db: Session, patient_id: int) -> List[Prescription]:
    """Get all prescriptions for a patient across all medical records"""
    from sqlalchemy import text
    
    # Query prescriptions by joining with medical_records to filter by patient_id
    query = text("""
        SELECT p.prescription_id, p.record_id, p.drug_name, p.drug_code, 
               p.dosage, p.frequency, p.duration_days, p.notes, p.created_at
        FROM prescriptions p
        INNER JOIN medical_records mr ON p.record_id = mr.record_id
        WHERE mr.patient_id = :patient_id
        ORDER BY p.created_at DESC
    """)
    
    result = db.execute(query, {"patient_id": patient_id})
    prescriptions = []
    
    for row in result:
        prescription = Prescription(
            prescription_id=row.prescription_id,
            record_id=row.record_id,
            drug_name=row.drug_name,
            drug_code=row.drug_code,
            dosage=row.dosage,
            frequency=row.frequency,
            duration_days=row.duration_days,
            notes=row.notes,
            created_at=row.created_at
        )
        prescriptions.append(prescription)
    
    return prescriptions

def get_prescription_by_id(db: Session, prescription_id: str) -> Optional[Prescription]:
    """Get prescription by ID"""
    return db.query(Prescription).filter(Prescription.prescription_id == prescription_id).first()

def update_prescription(db: Session, prescription_id: str, prescription_data: dict) -> Optional[Prescription]:
    """Update a prescription"""
    prescription = get_prescription_by_id(db, prescription_id)
    if not prescription:
        return None
    
    for key, value in prescription_data.items():
        if hasattr(prescription, key):
            setattr(prescription, key, value)
    
    db.commit()
    db.refresh(prescription)
    return prescription

def delete_prescription(db: Session, prescription_id: str) -> bool:
    """Delete a prescription"""
    prescription = get_prescription_by_id(db, prescription_id)
    if not prescription:
        return False
    
    db.delete(prescription)
    db.commit()
    return True

# Lab Results CRUD
def create_lab_result(db: Session, lab_data: dict) -> LabResult:
    """Create a new lab result"""
    lab_result = LabResult(**lab_data)
    db.add(lab_result)
    db.commit()
    db.refresh(lab_result)
    return lab_result

def get_record_lab_results(db: Session, record_id: str) -> List[LabResult]:
    """Get all lab results for a medical record"""
    return db.query(LabResult).filter(LabResult.record_id == record_id).all()

def get_lab_result_by_id(db: Session, lab_id: str) -> Optional[LabResult]:
    """Get lab result by ID"""
    return db.query(LabResult).filter(LabResult.lab_id == lab_id).first()

def update_lab_result(db: Session, lab_id: str, lab_data: dict) -> Optional[LabResult]:
    """Update a lab result"""
    lab_result = get_lab_result_by_id(db, lab_id)
    if not lab_result:
        return None
    
    for key, value in lab_data.items():
        if hasattr(lab_result, key):
            setattr(lab_result, key, value)
    
    db.commit()
    db.refresh(lab_result)
    return lab_result

def delete_lab_result(db: Session, lab_id: str) -> bool:
    """Delete a lab result"""
    lab_result = get_lab_result_by_id(db, lab_id)
    if not lab_result:
        return False
    
    db.delete(lab_result)
    db.commit()
    return True

# Allergies CRUD
def create_allergy(db: Session, allergy_data: dict) -> Allergy:
    """Create a new allergy"""
    allergy = Allergy(**allergy_data)
    db.add(allergy)
    db.commit()
    db.refresh(allergy)
    return allergy

def get_patient_allergies(db: Session, patient_id: int) -> List[Allergy]:
    """Get all allergies for a patient"""
    from sqlalchemy import text
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT allergy_id, patient_id, allergy_name, severity, notes, created_at, updated_at
        FROM allergies
        WHERE patient_id = :patient_id
        ORDER BY created_at DESC
    """)
    
    result = db.execute(query, {"patient_id": patient_id})
    allergies = []
    
    for row in result:
        # Convert severity string to enum
        severity_str = row.severity.lower() if row.severity else "moderate"
        from ..models.allergy import AllergySeverity
        severity_enum = None
        for sev in AllergySeverity:
            if sev.value == severity_str:
                severity_enum = sev
                break
        
        if not severity_enum:
            severity_enum = AllergySeverity.MODERATE  # default
        
        allergy = Allergy(
            allergy_id=row.allergy_id,
            patient_id=row.patient_id,
            allergy_name=row.allergy_name,
            severity=severity_enum,
            notes=row.notes,
            created_at=row.created_at,
            updated_at=row.updated_at
        )
        allergies.append(allergy)
    
    return allergies

def get_allergy_by_id(db: Session, allergy_id: str) -> Optional[Allergy]:
    """Get allergy by ID"""
    from sqlalchemy import text
    from ..models.allergy import AllergySeverity
    
    query = text("""
        SELECT allergy_id, patient_id, allergy_name, severity, notes, created_at, updated_at
        FROM allergies
        WHERE allergy_id = :allergy_id
    """)
    
    result = db.execute(query, {"allergy_id": allergy_id}).first()
    
    if not result:
        return None
    
    # Convert severity string to enum
    severity_str = result.severity.lower() if result.severity else "moderate"
    severity_enum = None
    for sev in AllergySeverity:
        if sev.value == severity_str:
            severity_enum = sev
            break
    
    if not severity_enum:
        severity_enum = AllergySeverity.MODERATE  # default
    
    return Allergy(
        allergy_id=result.allergy_id,
        patient_id=result.patient_id,
        allergy_name=result.allergy_name,
        severity=severity_enum,
        notes=result.notes,
        created_at=result.created_at,
        updated_at=result.updated_at
    )

def update_allergy(db: Session, allergy_id: str, allergy_data: dict) -> Optional[Allergy]:
    """Update an allergy"""
    from sqlalchemy import text
    
    allergy = get_allergy_by_id(db, allergy_id)
    if not allergy:
        return None
    
    # Build update query
    update_fields = []
    update_values = {"allergy_id": allergy_id}
    
    if "patient_id" in allergy_data:
        update_fields.append("patient_id = :patient_id")
        update_values["patient_id"] = allergy_data["patient_id"]
    if "allergy_name" in allergy_data:
        update_fields.append("allergy_name = :allergy_name")
        update_values["allergy_name"] = allergy_data["allergy_name"]
    if "severity" in allergy_data:
        update_fields.append("severity = :severity")
        update_values["severity"] = allergy_data["severity"].value if hasattr(allergy_data["severity"], "value") else str(allergy_data["severity"])
    if "notes" in allergy_data:
        update_fields.append("notes = :notes")
        update_values["notes"] = allergy_data["notes"]
    
    if not update_fields:
        return allergy
    
    update_fields.append("updated_at = NOW()")
    
    query = text(f"""
        UPDATE allergies
        SET {', '.join(update_fields)}
        WHERE allergy_id = :allergy_id
    """)
    
    db.execute(query, update_values)
    db.commit()
    
    return get_allergy_by_id(db, allergy_id)

def delete_allergy(db: Session, allergy_id: str) -> bool:
    """Delete an allergy"""
    allergy = db.query(Allergy).filter(Allergy.allergy_id == allergy_id).first()
    if allergy:
        db.delete(allergy)
        db.commit()
        return True
    return False

# Medical Documents CRUD
def create_medical_document(db: Session, doc_data: dict) -> MedicalDocument:
    """Create a new medical document"""
    document = MedicalDocument(**doc_data)
    db.add(document)
    db.commit()
    db.refresh(document)
    return document

def get_patient_documents(db: Session, patient_id: int) -> List[MedicalDocument]:
    """Get all documents for a patient"""
    from sqlalchemy import text
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT doc_id, patient_id, record_id, file_type, file_url, extract_text, created_at
        FROM medical_documents
        WHERE patient_id = :patient_id
        ORDER BY created_at DESC
    """)
    
    result = db.execute(query, {"patient_id": patient_id})
    documents = []
    
    for row in result:
        # Convert file_type string to enum
        file_type_str = row.file_type.lower() if row.file_type else "pdf"
        from ..models.medical_document import FileType
        file_type_enum = None
        for ft in FileType:
            if ft.value == file_type_str:
                file_type_enum = ft
                break
        
        if not file_type_enum:
            file_type_enum = FileType.PDF  # default
        
        document = MedicalDocument(
            doc_id=row.doc_id,
            patient_id=row.patient_id,
            record_id=row.record_id,
            file_type=file_type_enum,
            file_url=row.file_url,
            extract_text=row.extract_text,
            created_at=row.created_at
        )
        documents.append(document)
    
    return documents

def get_record_documents(db: Session, record_id: str) -> List[MedicalDocument]:
    """Get all documents for a medical record"""
    from sqlalchemy import text
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT doc_id, patient_id, record_id, file_type, file_url, extract_text, created_at
        FROM medical_documents
        WHERE record_id = :record_id
        ORDER BY created_at DESC
    """)
    
    result = db.execute(query, {"record_id": record_id})
    documents = []
    
    for row in result:
        # Convert file_type string to enum
        file_type_str = row.file_type.lower() if row.file_type else "pdf"
        from ..models.medical_document import FileType
        file_type_enum = None
        for ft in FileType:
            if ft.value == file_type_str:
                file_type_enum = ft
                break
        
        if not file_type_enum:
            file_type_enum = FileType.PDF  # default
        
        document = MedicalDocument(
            doc_id=row.doc_id,
            patient_id=row.patient_id,
            record_id=row.record_id,
            file_type=file_type_enum,
            file_url=row.file_url,
            extract_text=row.extract_text,
            created_at=row.created_at
        )
        documents.append(document)
    
    return documents

def get_medical_document_by_id(db: Session, doc_id: str) -> Optional[MedicalDocument]:
    """Get medical document by ID"""
    from sqlalchemy import text
    from ..models.medical_document import FileType
    
    query = text("""
        SELECT doc_id, patient_id, record_id, file_type, file_url, extract_text, created_at
        FROM medical_documents
        WHERE doc_id = :doc_id
    """)
    
    result = db.execute(query, {"doc_id": doc_id}).first()
    
    if not result:
        return None
    
    # Convert file_type string to enum
    file_type_str = result.file_type.lower() if result.file_type else "pdf"
    file_type_enum = None
    for ft in FileType:
        if ft.value == file_type_str:
            file_type_enum = ft
            break
    
    if not file_type_enum:
        file_type_enum = FileType.PDF  # default
    
    return MedicalDocument(
        doc_id=result.doc_id,
        patient_id=result.patient_id,
        record_id=result.record_id,
        file_type=file_type_enum,
        file_url=result.file_url,
        extract_text=result.extract_text,
        created_at=result.created_at
    )

def update_medical_document(db: Session, doc_id: str, doc_data: dict) -> Optional[MedicalDocument]:
    """Update a medical document"""
    from sqlalchemy import text
    
    document = get_medical_document_by_id(db, doc_id)
    if not document:
        return None
    
    # Build update query
    update_fields = []
    update_values = {"doc_id": doc_id}
    
    if "patient_id" in doc_data:
        update_fields.append("patient_id = :patient_id")
        update_values["patient_id"] = doc_data["patient_id"]
    if "record_id" in doc_data:
        update_fields.append("record_id = :record_id")
        update_values["record_id"] = doc_data["record_id"]
    if "file_type" in doc_data:
        update_fields.append("file_type = :file_type")
        update_values["file_type"] = doc_data["file_type"].value if hasattr(doc_data["file_type"], "value") else str(doc_data["file_type"])
    if "file_url" in doc_data:
        update_fields.append("file_url = :file_url")
        update_values["file_url"] = doc_data["file_url"]
    if "extract_text" in doc_data:
        update_fields.append("extract_text = :extract_text")
        update_values["extract_text"] = doc_data["extract_text"]
    
    if not update_fields:
        return document
    
    query = text(f"""
        UPDATE medical_documents
        SET {', '.join(update_fields)}
        WHERE doc_id = :doc_id
    """)
    
    db.execute(query, update_values)
    db.commit()
    
    return get_medical_document_by_id(db, doc_id)

def delete_medical_document(db: Session, doc_id: str) -> bool:
    """Delete a medical document"""
    from sqlalchemy import text
    query = text("DELETE FROM medical_documents WHERE doc_id = :doc_id")
    result = db.execute(query, {"doc_id": doc_id})
    db.commit()
    return result.rowcount > 0

def get_patient_by_id(db: Session, patient_id: int):
    """Get patient/user information by ID"""
    # Import here to avoid circular dependency
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    from auth.models.user import User
    
    return db.query(User).filter(User.id == patient_id).first()

def get_complete_patient_data(db: Session, patient_id: int) -> Optional[dict]:
    """
    Get complete patient data including:
    - Patient info
    - All medical records with diagnoses, prescriptions, lab results
    - All allergies
    - All medical documents
    - Summary statistics
    """
    # Get patient info
    patient = get_patient_by_id(db, patient_id)
    if not patient:
        return None
    
    # Get all medical records for this patient
    records = get_patient_records(db, patient_id, skip=0, limit=1000)
    
    # Build complete records with all related data
    complete_records = []
    for record in records:
        # Handle visit_type enum
        visit_type_value = record.visit_type
        if hasattr(record.visit_type, 'value'):
            visit_type_value = record.visit_type.value
        elif isinstance(record.visit_type, str):
            visit_type_value = record.visit_type
        else:
            visit_type_value = str(record.visit_type)
        
        record_dict = {
            "record_id": record.record_id,
            "patient_id": record.patient_id,
            "visit_date": record.visit_date,
            "visit_type": visit_type_value,
            "diagnosis_summary": record.diagnosis_summary,
            "notes": record.notes,
            "doctor_name": record.doctor_name,
            "facility_name": record.facility_name,
            "created_at": record.created_at,
            "diagnoses": get_record_diagnoses(db, record.record_id),
            "prescriptions": get_record_prescriptions(db, record.record_id),
            "lab_results": get_record_lab_results(db, record.record_id),
        }
        complete_records.append(record_dict)
    
    # Get all allergies
    allergies = get_patient_allergies(db, patient_id)
    
    # Get all documents
    documents = get_patient_documents(db, patient_id)
    
    # Build summary
    summary = {
        "total_records": len(records),
        "total_allergies": len(allergies),
        "total_documents": len(documents),
        "latest_visit": records[0].visit_date if records else None,
    }
    
    return {
        "patient_info": patient,
        "medical_records": complete_records,
        "allergies": allergies,
        "medical_documents": documents,
        "summary": summary
    }

# Patient Management CRUD Operations (Admin)
def search_patients(db: Session, search_query: Optional[str] = None, skip: int = 0, limit: int = 100) -> Tuple[List, int]:
    """
    Search patients by name, email, KTP number, or phone number
    Returns: (list of patients, total count)
    Note: MySQL LIKE is case-insensitive with utf8mb4_unicode_ci collation
    """
    # Import here to avoid circular dependency
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    from auth.models.user import User
    from sqlalchemy import or_, func
    
    query = db.query(User)
    
    # Apply search filter
    if search_query:
        search_term = f"%{search_query}%"
        # Use LIKE for MySQL (case-insensitive with utf8mb4_unicode_ci collation)
        # Using LOWER() for better compatibility
        query = query.filter(
            or_(
                func.lower(User.name).like(func.lower(search_term)),
                func.lower(User.email).like(func.lower(search_term)),
                User.phoneNumber.like(search_term),
                User.ktpNumber.like(search_term),
                User.kkNumber.like(search_term)
            )
        )
    
    # Get total count
    total = query.count()
    
    # Apply pagination and order
    patients = query.order_by(User.created_at.desc()).offset(skip).limit(limit).all()
    
    return patients, total

def get_all_patients(db: Session, skip: int = 0, limit: int = 100) -> Tuple[List, int]:
    """
    Get all patients with pagination
    Returns: (list of patients, total count)
    """
    # Import here to avoid circular dependency
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    from auth.models.user import User
    
    query = db.query(User)
    
    # Get total count
    total = query.count()
    
    # Apply pagination and order
    patients = query.order_by(User.created_at.desc()).offset(skip).limit(limit).all()
    
    return patients, total

def update_patient(db: Session, patient_id: int, patient_data: dict) -> Optional:
    """
    Update patient information
    """
    # Import here to avoid circular dependency
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    from auth.models.user import User
    
    patient = db.query(User).filter(User.id == patient_id).first()
    if not patient:
        return None
    
    # Update fields
    if "name" in patient_data and patient_data["name"] is not None:
        patient.name = patient_data["name"]
    if "email" in patient_data and patient_data["email"] is not None:
        patient.email = patient_data["email"]
    if "phoneNumber" in patient_data and patient_data["phoneNumber"] is not None:
        patient.phoneNumber = patient_data["phoneNumber"]
    if "ktpNumber" in patient_data and patient_data["ktpNumber"] is not None:
        patient.ktpNumber = patient_data["ktpNumber"]
    if "kkNumber" in patient_data and patient_data["kkNumber"] is not None:
        patient.kkNumber = patient_data["kkNumber"]
    if "is_active" in patient_data and patient_data["is_active"] is not None:
        patient.is_active = patient_data["is_active"]
    
    db.commit()
    db.refresh(patient)
    return patient

def delete_patient(db: Session, patient_id: int, soft_delete: bool = True) -> bool:
    """
    Delete patient (soft delete by default - sets is_active to False)
    If soft_delete is False, permanently delete the patient
    """
    # Import here to avoid circular dependency
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    from auth.models.user import User
    
    patient = db.query(User).filter(User.id == patient_id).first()
    if not patient:
        return False
    
    if soft_delete:
        # Soft delete: set is_active to False
        patient.is_active = False
        db.commit()
        db.refresh(patient)
    else:
        # Hard delete: permanently remove from database
        db.delete(patient)
        db.commit()
    
    return True

