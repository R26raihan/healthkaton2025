"""
RAG Service - Enhanced Core RAG functionality for Medical Records
"""
from typing import List, Dict, Optional
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime

from ..core.config import (
    LLM_PROVIDER,
    LLM_MODEL_NAME,
    LLM_API_KEY,
    LLM_BASE_URL,
    LLM_SITE_URL,
    LLM_SITE_NAME,
    MAX_CONTEXT_DOCUMENTS,
    SIMILARITY_THRESHOLD
)
# Note: Import schemas from parent
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# For now, define DocumentChunk locally to avoid circular import
from pydantic import BaseModel

class DocumentChunk(BaseModel):
    doc_id: str
    patient_id: int
    record_id: Optional[str]
    chunk_text: str
    similarity_score: float
    metadata: Optional[dict] = None

def search_documents(
    query: str,
    patient_id: Optional[int] = None,
    limit: int = 10,
    threshold: float = 0.7,
    db: Session = None
) -> List[DocumentChunk]:
    """
    Search medical documents by semantic similarity
    
    TODO: Implement actual vector search using:
    - OpenAI embeddings
    - Vector store (Pinecone, Qdrant, FAISS, etc.)
    - Semantic similarity calculation
    
    For now, returns keyword-based search
    """
    # Get documents with extract_text
    if patient_id:
        query_sql = text("""
            SELECT doc_id, patient_id, record_id, extract_text, file_url, created_at
            FROM medical_documents
            WHERE patient_id = :patient_id
            AND extract_text IS NOT NULL
            AND extract_text != ''
            ORDER BY created_at DESC
            LIMIT :limit
        """)
        result = db.execute(query_sql, {"patient_id": patient_id, "limit": limit * 2})
    else:
        query_sql = text("""
            SELECT doc_id, patient_id, record_id, extract_text, file_url, created_at
            FROM medical_documents
            WHERE extract_text IS NOT NULL
            AND extract_text != ''
            ORDER BY created_at DESC
            LIMIT :limit
        """)
        result = db.execute(query_sql, {"limit": limit * 2})
    
    # Simple keyword matching (replace with actual semantic search)
    query_lower = query.lower()
    query_words = set(query_lower.split())
    # Remove common stop words for better matching
    stop_words = {'yang', 'dan', 'atau', 'dari', 'di', 'ke', 'pada', 'untuk', 'dengan', 'bagaimana', 'apa', 'apakah'}
    query_words = {w for w in query_words if w not in stop_words and len(w) > 2}
    
    documents = []
    
    for row in result:
        if not row.extract_text:
            continue
        
        # Simple similarity: count matching words
        text_lower = row.extract_text.lower()
        text_words = set(text_lower.split())
        
        if not query_words:
            continue
        
        matches = len(query_words.intersection(text_words))
        similarity = matches / len(query_words) if query_words else 0
        
        # Lower threshold if no exact matches (allow partial matches)
        effective_threshold = threshold if matches > 0 else threshold * 0.3
        
        if similarity >= effective_threshold:
            # Use full extract_text (model tidak bisa OCR, cukup chunk text saja)
            # Limit to 3000 chars untuk menghindari token limit yang terlalu besar
            full_text = row.extract_text
            chunk_text = full_text[:3000] if len(full_text) > 3000 else full_text
            
            chunk = DocumentChunk(
                doc_id=row.doc_id,
                patient_id=row.patient_id,
                record_id=row.record_id,
                chunk_text=chunk_text,
                similarity_score=similarity,
                metadata={
                    "file_url": row.file_url,
                    "created_at": str(row.created_at),
                    "source": "medical_document"
                }
            )
            documents.append(chunk)
    
    # Sort by similarity and limit
    documents.sort(key=lambda x: x.similarity_score, reverse=True)
    return documents[:limit]

def search_medical_records(
    query: str,
    patient_id: int,
    limit: int = 5,
    db: Session = None
) -> List[DocumentChunk]:
    """
    Search medical records (diagnoses, prescriptions, notes, lab results) for context
    Enhanced with structured data retrieval including lab results
    """
    query_lower = query.lower()
    query_words = set(query_lower.split())
    stop_words = {'yang', 'dan', 'atau', 'dari', 'di', 'ke', 'pada', 'untuk', 'dengan', 'bagaimana', 'apa', 'apakah', 'saya', 'ini', 'itu'}
    query_words = {w for w in query_words if w not in stop_words and len(w) > 2}
    
    # Enhanced query with lab results, doctor info, and facility
    query_sql = text("""
        SELECT 
            mr.record_id,
            mr.patient_id,
            mr.diagnosis_summary,
            mr.notes,
            mr.visit_date,
            mr.visit_type,
            mr.doctor_name,
            mr.facility_name,
            GROUP_CONCAT(DISTINCT d.diagnosis_name SEPARATOR ', ') as diagnoses,
            GROUP_CONCAT(DISTINCT d.icd_code SEPARATOR ', ') as icd_codes,
            GROUP_CONCAT(DISTINCT CONCAT(p.drug_name, ' (', COALESCE(p.dosage, ''), ', ', COALESCE(p.frequency, ''), ')') SEPARATOR '; ') as prescriptions,
            GROUP_CONCAT(DISTINCT CONCAT(lr.test_name, ': ', lr.result_value, ' ', COALESCE(lr.result_unit, ''), 
                         CASE WHEN lr.normal_range IS NOT NULL THEN CONCAT(' [Normal: ', lr.normal_range, ']') ELSE '' END) 
                         SEPARATOR '; ') as lab_results
        FROM medical_records mr
        LEFT JOIN diagnoses d ON mr.record_id = d.record_id
        LEFT JOIN prescriptions p ON mr.record_id = p.record_id
        LEFT JOIN lab_results lr ON mr.record_id = lr.record_id
        WHERE mr.patient_id = :patient_id
        GROUP BY mr.record_id, mr.patient_id, mr.diagnosis_summary, mr.notes, 
                 mr.visit_date, mr.visit_type, mr.doctor_name, mr.facility_name
        ORDER BY mr.visit_date DESC
        LIMIT :limit
    """)
    
    result = db.execute(query_sql, {"patient_id": patient_id, "limit": limit * 3})
    chunks = []
    
    for row in result:
        # Build structured text representation
        visit_date_str = row.visit_date.strftime("%d %B %Y") if row.visit_date else "Tanggal tidak diketahui"
        visit_type_str = row.visit_type or "kunjungan"
        doctor_str = f"Dokter: {row.doctor_name}" if row.doctor_name else ""
        facility_str = f"Fasilitas: {row.facility_name}" if row.facility_name else ""
        
        # Build comprehensive text with structure
        text_parts = []
        
        # Header
        text_parts.append(f"=== Rekam Medis - {visit_date_str} ({visit_type_str}) ===")
        if doctor_str:
            text_parts.append(doctor_str)
        if facility_str:
            text_parts.append(facility_str)
        
        # Diagnoses
        if row.diagnoses:
            icd_part = f" (ICD: {row.icd_codes})" if row.icd_codes else ""
            text_parts.append(f"Diagnosis: {row.diagnoses}{icd_part}")
        
        # Summary
        if row.diagnosis_summary:
            text_parts.append(f"Ringkasan: {row.diagnosis_summary}")
        
        # Notes
        if row.notes:
            text_parts.append(f"Catatan: {row.notes}")
        
        # Prescriptions
        if row.prescriptions:
            text_parts.append(f"Resep Obat: {row.prescriptions}")
        
        # Lab Results
        if row.lab_results:
            text_parts.append(f"Hasil Lab: {row.lab_results}")
        
        combined_text = "\n".join(text_parts)
        combined_text_lower = combined_text.lower()
        text_words = set(combined_text_lower.split())
        
        # Calculate similarity
        if query_words:
            matches = len(query_words.intersection(text_words))
            similarity = matches / len(query_words) if query_words else 0.5
            
            # Boost similarity for medical terms
            medical_keywords = ['diagnosis', 'diagnosa', 'obat', 'resep', 'lab', 'alergi', 'allergy', 
                              'diabetes', 'hipertensi', 'tekanan', 'darah', 'gula', 'kolesterol']
            query_medical_match = any(kw in query_lower for kw in medical_keywords)
            text_medical_match = any(kw in combined_text_lower for kw in medical_keywords)
            if query_medical_match and text_medical_match:
                similarity = min(1.0, similarity + 0.2)
        else:
            # If no query words, give default similarity for recent records
            similarity = 0.3
        
        # Limit chunk size but preserve structure
        if len(combined_text) > 3000:
            # Try to preserve important parts
            important_parts = []
            if row.diagnoses:
                important_parts.append(f"Diagnosis: {row.diagnoses}")
            if row.diagnosis_summary:
                important_parts.append(f"Ringkasan: {row.diagnosis_summary[:500]}")
            if row.prescriptions:
                important_parts.append(f"Resep: {row.prescriptions}")
            combined_text = "\n".join(important_parts)
        
        chunk = DocumentChunk(
            doc_id=f"record_{row.record_id}",
            patient_id=row.patient_id,
            record_id=row.record_id,
            chunk_text=combined_text,
            similarity_score=similarity,
            metadata={
                "visit_date": str(row.visit_date),
                "visit_type": row.visit_type,
                "doctor_name": row.doctor_name,
                "facility_name": row.facility_name,
                "source": "medical_record"
            }
        )
        chunks.append(chunk)
    
    chunks.sort(key=lambda x: x.similarity_score, reverse=True)
    return chunks[:limit]

def get_patient_allergies_context(patient_id: int, db: Session) -> Optional[str]:
    """
    Get patient allergies as context string
    """
    query_sql = text("""
        SELECT allergy_name, severity, notes
        FROM allergies
        WHERE patient_id = :patient_id
        ORDER BY created_at DESC
    """)
    
    result = db.execute(query_sql, {"patient_id": patient_id})
    allergies = []
    
    for row in result:
        severity_str = row.severity or "moderate"
        notes_str = f" ({row.notes})" if row.notes else ""
        allergies.append(f"- {row.allergy_name} (Tingkat: {severity_str}){notes_str}")
    
    if allergies:
        return "=== Riwayat Alergi ===\n" + "\n".join(allergies)
    return None

def query_with_rag(
    query: str,
    patient_id: Optional[int] = None,
    max_documents: int = 5,
    similarity_threshold: float = 0.7,
    db: Session = None
) -> Dict:
    """
    Enhanced Query with RAG - Search documents and generate answer using LLM
    
    Searches through:
    1. Medical documents (extract_text)
    2. Medical records (diagnosis_summary, notes, diagnoses, prescriptions, lab_results)
    3. Patient allergies (always included if patient_id provided)
    
    Improved with:
    - Better error handling
    - Structured context building
    - Enhanced prompt engineering
    - Patient allergies integration
    """
    # Validate patient_id if provided (security)
    if patient_id is None:
        raise ValueError("patient_id is required for RAG queries")
    
    # Step 1: Search relevant documents from medical_documents
    relevant_docs = []
    try:
        relevant_docs = search_documents(
            query=query,
            patient_id=patient_id,
            limit=max_documents,
            threshold=similarity_threshold,
            db=db
        )
    except Exception as e:
        # Log error but continue with medical records search
        print(f"Error searching documents: {str(e)}")
    
    # Step 2: Search in medical records (always include for patient context)
    medical_records_context = []
    try:
        medical_records_context = search_medical_records(
            query=query,
            patient_id=patient_id,
            limit=max_documents,
            db=db
        )
        # Combine and deduplicate
        existing_record_ids = {doc.record_id for doc in relevant_docs if doc.record_id}
        for record in medical_records_context:
            if record.record_id not in existing_record_ids:
                relevant_docs.append(record)
    except Exception as e:
        print(f"Error searching medical records: {str(e)}")
    
    # Step 3: Get patient allergies (always include for context)
    allergies_context = None
    try:
        allergies_context = get_patient_allergies_context(patient_id, db)
    except Exception as e:
        print(f"Error retrieving allergies: {str(e)}")
    
    # Step 4: Sort and limit documents by similarity
    relevant_docs.sort(key=lambda x: x.similarity_score, reverse=True)
    relevant_docs = relevant_docs[:max_documents]
    
    # Step 5: Build structured context
    context_parts = []
    sources = []
    
    # Add allergies first if available (important context)
    if allergies_context:
        context_parts.append(allergies_context)
        sources.append("patient_allergies")
    
    # Add medical records and documents
    for doc in relevant_docs:
        # Include metadata in context for better understanding
        metadata_info = ""
        if doc.metadata:
            if doc.metadata.get("visit_date"):
                metadata_info = f"\n[Tanggal: {doc.metadata.get('visit_date')}]"
            if doc.metadata.get("doctor_name"):
                metadata_info += f" [Dokter: {doc.metadata.get('doctor_name')}]"
            if doc.metadata.get("facility_name"):
                metadata_info += f" [Fasilitas: {doc.metadata.get('facility_name')}]"
        
        context_parts.append(f"{doc.chunk_text}{metadata_info}")
        sources.append(doc.doc_id)
    
    # Handle empty context
    if not context_parts:
        return {
            "query": query,
            "answer": "Maaf, tidak ditemukan informasi rekam medis yang relevan untuk menjawab pertanyaan Anda. "
                     "Pastikan Anda telah mengunggah dokumen medis atau memiliki riwayat kunjungan medis.",
            "relevant_documents": [],
            "sources": [],
            "model_used": "none",
            "warning": "No relevant documents found"
        }
    
    context = "\n\n---\n\n".join(context_parts)
    
    # Step 6: Build enhanced prompt for LLM
    system_prompt = """Anda adalah asisten medis yang membantu pasien memahami rekam medis mereka.
Tugas Anda:
1. Jawab pertanyaan dengan jelas dan mudah dipahami menggunakan bahasa Indonesia yang sederhana
2. Gunakan HANYA informasi dari dokumen rekam medis yang diberikan
3. Jika informasi tidak ada di dokumen, katakan dengan jujur bahwa informasi tidak tersedia
4. Untuk pertanyaan tentang alergi, selalu cek bagian riwayat alergi terlebih dahulu
5. Untuk pertanyaan tentang obat, sebutkan nama obat, dosis, dan frekuensi jika tersedia
6. Untuk pertanyaan tentang hasil lab, sebutkan nilai dan rentang normal jika tersedia
7. Jangan memberikan saran medis atau diagnosis baru, hanya jelaskan informasi yang ada
8. Jika ada tanggal kunjungan, sebutkan untuk memberikan konteks waktu
9. Gunakan istilah medis yang tepat tetapi jelaskan dengan bahasa yang mudah dipahami
10. Selalu prioritaskan informasi terbaru jika ada multiple records

Format jawaban:
- Gunakan poin-poin jika informasi banyak
- Sebutkan tanggal jika relevan
- Jelaskan istilah medis jika diperlukan"""
    
    user_prompt = f"""Berikut adalah rekam medis pasien:

{context}

Pertanyaan pasien: {query}

Jawablah pertanyaan tersebut dengan jelas dan mudah dipahami berdasarkan informasi rekam medis di atas. 
Jika informasi tidak tersedia, beri tahu pasien dengan sopan."""
    
    # Step 7: Call LLM using OpenRouter
    try:
        answer = call_llm_with_openrouter(
            query=query,
            context=context,
            system_prompt=system_prompt
        )
        model_used = LLM_MODEL_NAME or "openrouter/unknown"
    except Exception as e:
        # Enhanced error handling
        error_msg = str(e)
        if "rate limit" in error_msg.lower() or "quota" in error_msg.lower():
            answer = "Maaf, layanan sedang sibuk. Silakan coba lagi beberapa saat lagi."
        elif "timeout" in error_msg.lower():
            answer = "Maaf, waktu tunggu habis. Silakan coba lagi dengan pertanyaan yang lebih spesifik."
        else:
            answer = f"Maaf, terjadi kesalahan saat memproses pertanyaan. "
            answer += f"Ditemukan {len(relevant_docs)} dokumen relevan, tetapi tidak dapat menghasilkan jawaban."
            answer += " Silakan coba lagi atau hubungi administrator."
        model_used = f"{LLM_MODEL_NAME}_error"
        print(f"LLM Error: {error_msg}")
    
    return {
        "query": query,
        "answer": answer,
        "relevant_documents": [doc.model_dump() for doc in relevant_docs],
        "sources": sources,
        "model_used": model_used
    }

def call_llm_with_openrouter(
    query: str,
    context: str,
    system_prompt: str
) -> str:
    """
    Enhanced Call LLM using OpenRouter API
    
    OpenRouter provides access to multiple LLM models through one API.
    Compatible with OpenAI SDK.
    Using DeepSeek model: deepseek/deepseek-r1-0528-qwen3-8b:free
    
    Improvements:
    - Better error handling
    - Token limit management
    - Retry logic for transient errors
    """
    try:
        from openai import OpenAI
        import time
        
        # Configure OpenAI client to use OpenRouter
        client = OpenAI(
            base_url=LLM_BASE_URL or "https://openrouter.ai/api/v1",
            api_key=LLM_API_KEY,
            timeout=60.0  # 60 second timeout
        )
        
        # Estimate token usage (rough: 1 token ≈ 4 characters)
        context_chars = len(context)
        query_chars = len(query)
        prompt_chars = len(system_prompt)
        total_chars = context_chars + query_chars + prompt_chars
        estimated_tokens = total_chars / 4
        
        # Limit context if too long (max ~8000 tokens input, reserve for response)
        max_input_tokens = 6000
        if estimated_tokens > max_input_tokens:
            # Truncate context but keep structure
            max_context_chars = (max_input_tokens * 4) - query_chars - prompt_chars - 500
            if max_context_chars > 0 and len(context) > max_context_chars:
                # Try to preserve important parts (allergies, recent records)
                context_lines = context.split("\n\n---\n\n")
                truncated_context = []
                chars_used = 0
                for line in context_lines:
                    if chars_used + len(line) < max_context_chars:
                        truncated_context.append(line)
                        chars_used += len(line)
                    else:
                        break
                context = "\n\n---\n\n".join(truncated_context)
                if truncated_context:
                    context += "\n\n[Catatan: Beberapa informasi lama tidak ditampilkan untuk menghemat ruang]"
        
        # Build user message
        user_content = f"""Berikut adalah rekam medis pasien:

{context}

Pertanyaan pasien: {query}

Jawablah pertanyaan tersebut dengan jelas dan mudah dipahami berdasarkan informasi rekam medis di atas."""
        
        # Call chat completion with OpenRouter format
        # Retry logic for transient errors
        max_retries = 2
        for attempt in range(max_retries):
            try:
                completion = client.chat.completions.create(
                    extra_headers={
                        "HTTP-Referer": LLM_SITE_URL or "https://github.com/healthkon",
                        "X-Title": LLM_SITE_NAME or "Healthkon BPJS RAG Service"
                    },
                    model=LLM_MODEL_NAME or "deepseek/deepseek-r1-0528-qwen3-8b:free",
                    messages=[
                        {
                            "role": "system",
                            "content": system_prompt
                        },
                        {
                            "role": "user",
                            "content": user_content
                        }
                    ],
                    temperature=0.7,  # Balanced creativity and consistency
                    max_tokens=2500,  # Increased for detailed medical explanations
                    top_p=0.9,
                    frequency_penalty=0.1,  # Slight penalty to avoid repetition
                    presence_penalty=0.1
                )
                
                answer = completion.choices[0].message.content.strip()
                
                # Validate answer
                if not answer or len(answer) < 10:
                    raise Exception("LLM returned empty or too short answer")
                
                return answer
                
            except Exception as e:
                error_msg = str(e).lower()
                # Retry on transient errors
                if attempt < max_retries - 1 and any(keyword in error_msg for keyword in 
                    ['timeout', 'rate limit', 'temporary', 'retry', '503', '502', '429']):
                    wait_time = (attempt + 1) * 2  # Exponential backoff
                    print(f"Retrying LLM call after {wait_time} seconds... (attempt {attempt + 1}/{max_retries})")
                    time.sleep(wait_time)
                    continue
                else:
                    raise
    
    except ImportError:
        raise Exception("OpenAI package not installed. Install with: pip install openai")
    except Exception as e:
        raise Exception(f"Error calling OpenRouter API: {str(e)}")

def embed_document(
    doc_id: str,
    force_reembed: bool = False,
    db: Session = None
) -> Dict:
    """
    Generate embedding for a medical document
    
    TODO: Implement actual embedding generation:
    - Get document from database
    - Generate embedding using OpenAI/text-embedding-ada-002
    - Store embedding in vector store (Pinecone, Qdrant, etc.)
    - Optionally store in database for caching
    """
    # Get document
    query = text("""
        SELECT doc_id, extract_text
        FROM medical_documents
        WHERE doc_id = :doc_id
    """)
    result = db.execute(query, {"doc_id": doc_id}).first()
    
    if not result:
        return {
            "doc_id": doc_id,
            "status": "error",
            "message": "Document not found"
        }
    
    if not result.extract_text:
        return {
            "doc_id": doc_id,
            "status": "skipped",
            "message": "Document has no extract_text"
        }
    
    # TODO: Generate actual embedding
    # Example:
    # embedding = openai.Embedding.create(
    #     model="text-embedding-ada-002",
    #     input=result.extract_text
    # )
    # Store in vector store...
    
    return {
        "doc_id": doc_id,
        "status": "success",
        "message": "Embedding generated (placeholder - implement actual embedding)",
        "embedding_dimension": 1536  # OpenAI ada-002 dimension
    }

