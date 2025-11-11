"""
RAG API Routes - Admin/Doctor/Staff Only (Petugas Authentication)
"""
import time
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List, TYPE_CHECKING

# HTTPBearer untuk Swagger UI - bisa langsung paste token
security = HTTPBearer(auto_error=False)

# Lazy-initialized database engine and session (singleton pattern)
_auth_engine = None
_auth_session_local = None

def _get_auth_db_session():
    """Get auth database session - lazy initialization to avoid circular import"""
    global _auth_engine, _auth_session_local
    
    if _auth_engine is None:
        import os
        from dotenv import load_dotenv
        load_dotenv()
        
        DB_USER = os.getenv("DB_USER", "root")
        DB_PASSWORD = os.getenv("DB_PASSWORD", "")
        DB_HOST = os.getenv("DB_HOST", "localhost")
        DB_PORT = int(os.getenv("DB_PORT", "3306"))
        DB_NAME = os.getenv("DB_NAME", "healthkon")
        
        from sqlalchemy import create_engine
        from sqlalchemy.orm import sessionmaker
        from sqlalchemy.pool import QueuePool
        
        DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
        _auth_engine = create_engine(
            DATABASE_URL,
            poolclass=QueuePool,
            pool_pre_ping=True,
            pool_recycle=300,
            pool_size=5,
            max_overflow=10,
            connect_args={
                "connect_timeout": 10,
                "read_timeout": 10,
                "write_timeout": 10,
                "charset": "utf8mb4",
            }
        )
        _auth_session_local = sessionmaker(autocommit=False, autoflush=False, bind=_auth_engine)
    
    return _auth_session_local()

async def get_current_petugas_from_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get current petugas from Bearer token - RAG Service hanya bisa diakses oleh petugas (admin, dokter, staff)"""
    # Lazy import to avoid circular import
    from auth.models.petugas import Petugas
    from auth.services.security import verify_token
    import traceback
    
    db = None
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials. Only petugas (admin, dokter, staff) can access this service.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    if not credentials:
        raise credentials_exception
    
    try:
        token = credentials.credentials
        if not token:
            raise credentials_exception
        
        # Verify token - lazy import to avoid circular import
        token_data = verify_token(token)
        db = _get_auth_db_session()
        
        # Query petugas by email - RAG Service hanya untuk petugas
        petugas = db.query(Petugas).filter(Petugas.email == token_data.email).first()
        
        if petugas is None:
            if db:
                db.close()
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. This service is only accessible by petugas (admin, dokter, staff). Please login as petugas."
            )
        
        return petugas
        
    except HTTPException:
        if db:
            try:
                db.close()
            except:
                pass
        raise
    except Exception as e:
        if db:
            try:
                db.close()
            except:
                pass
        raise credentials_exception

async def get_current_active_petugas_for_rag(
    current_petugas = Depends(get_current_petugas_from_token)
):
    """Get current active petugas for RAG service - hanya petugas yang bisa akses"""
    if not current_petugas:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Petugas not authenticated"
        )
    if not current_petugas.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive petugas account"
        )
    return current_petugas

from ...core.database import get_db
from typing import Optional
from ...schemas.rag import (
    QueryRequest,
    QueryResponse,
    SearchRequest,
    SearchResponse,
    EmbedDocumentRequest,
    EmbedDocumentResponse,
    ChatRequest,
    ChatResponse
)
from ...services.rag import (
    search_documents,
    query_with_rag,
    embed_document
)

router = APIRouter(prefix="/rag", tags=["RAG"])

@router.post("/query", response_model=QueryResponse)
async def rag_query(
    request: QueryRequest,
    current_petugas = Depends(get_current_active_petugas_for_rag),
    db: Session = Depends(get_db)
):
    """
    Query with RAG - Ask questions about medical records
    
    **Admin/Doctor/Staff Only** - Requires petugas authentication
    
    Enhanced endpoint that:
    1. Searches relevant documents from medical records and medical_documents
    2. Includes patient allergies in context
    3. Retrieves structured data (diagnoses, prescriptions, lab results)
    4. Sends query + context to LLM model with enhanced prompts
    5. Returns answer with sources and metadata
    
    **Example queries:**
    - "Apakah pasien memiliki alergi?"
    - "Bagaimana riwayat diabetes pasien?"
    - "Obat apa yang sedang dikonsumsi pasien?"
    - "Apa hasil lab terakhir pasien?"
    
    **Note:** patient_id is required for security and proper context retrieval.
    """
    start_time = time.time()
    
    try:
        # Validate patient_id
        if request.patient_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="patient_id is required for RAG queries"
            )
        
        # Validate query
        if not request.query or len(request.query.strip()) < 3:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Query must be at least 3 characters long"
            )
        
        result = query_with_rag(
            query=request.query.strip(),
            patient_id=request.patient_id,
            max_documents=request.max_documents or 5,
            similarity_threshold=request.similarity_threshold or 0.7,
            db=db
        )
        
        processing_time = time.time() - start_time
        result["processing_time"] = processing_time
        
        return QueryResponse(**result)
    
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except ValueError as e:
        # Handle validation errors
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        # Handle other errors
        error_detail = str(e)
        # Don't expose internal errors to client
        if "database" in error_detail.lower() or "connection" in error_detail.lower():
            error_detail = "Database error. Please try again later."
        elif "llm" in error_detail.lower() or "openrouter" in error_detail.lower():
            error_detail = "AI service temporarily unavailable. Please try again later."
        
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing RAG query: {error_detail}"
        )

@router.post("/search", response_model=SearchResponse)
async def search_medical_documents(
    request: SearchRequest,
    current_petugas = Depends(get_current_active_petugas_for_rag),
    db: Session = Depends(get_db)
):
    """
    Search medical documents by semantic similarity
    
    **Admin/Doctor/Staff Only** - Requires petugas authentication
    
    This endpoint searches through extract_text in medical_documents
    and returns most relevant documents based on query.
    
    **Use case:**
    - Find documents related to specific condition
    - Search for specific medical terms
    - Find relevant medical records for a query
    """
    try:
        results = search_documents(
            query=request.query,
            patient_id=request.patient_id,
            limit=request.limit or 10,
            threshold=request.threshold or 0.7,
            db=db
        )
        
        return SearchResponse(
            query=request.query,
            results=results,
            total_found=len(results)
        )
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error searching documents: {str(e)}"
        )

@router.post("/embed/{doc_id}", response_model=EmbedDocumentResponse)
async def embed_medical_document(
    doc_id: str,
    force_reembed: bool = False,
    current_petugas = Depends(get_current_active_petugas_for_rag),
    db: Session = Depends(get_db)
):
    """
    Generate embedding for a medical document
    
    **Admin/Doctor/Staff Only** - Requires petugas authentication
    
    This endpoint generates vector embedding for extract_text
    to enable semantic search. Usually called automatically
    when document is uploaded.
    """
    try:
        result = embed_document(
            doc_id=doc_id,
            force_reembed=force_reembed,
            db=db
        )
        
        return EmbedDocumentResponse(**result)
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error embedding document: {str(e)}"
        )

# Note: /chat endpoint telah dipindah ke rag_service_mobile untuk user

@router.get("/health")
async def rag_health():
    """Health check for RAG service"""
    return {
        "status": "healthy",
        "service": "RAG Service",
        "llm_model": "configured",  # You can check actual model status
        "vector_store": "configured"  # You can check actual store status
    }

