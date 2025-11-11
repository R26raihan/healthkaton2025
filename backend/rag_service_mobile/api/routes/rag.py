"""
RAG API Routes Mobile - User-friendly Medical Records Q&A for Mobile App
"""
import time
import sys
import os
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

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

async def get_current_user_from_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get current user from Bearer token - RAG Service Mobile hanya untuk user (bukan petugas)"""
    # Lazy import to avoid circular import
    from auth.models.user import User
    from auth.models.petugas import Petugas
    from auth.services.security import verify_token
    import traceback
    
    db = None
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials. This service is only accessible by regular users.",
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
        
        # Check if it's a petugas (reject petugas)
        petugas = db.query(Petugas).filter(Petugas.email == token_data.email).first()
        if petugas:
            if db:
                db.close()
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. This service is only accessible by regular users, not petugas (staff). Please login as a regular user."
            )
        
        # Query user by email - RAG Service Mobile hanya untuk user
        user = db.query(User).filter(User.email == token_data.email).first()
        
        if user is None:
            if db:
                db.close()
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. User not found. Please login as a regular user."
            )
        
        return user
        
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

async def get_current_active_user_for_rag_mobile(
    current_user = Depends(get_current_user_from_token)
):
    """Get current active user for RAG Mobile service - hanya user yang bisa akses"""
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not authenticated"
        )
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user account"
        )
    return current_user

from ...core.database import get_db
from ...schemas.rag import ChatRequest, ChatResponse
from ...services.rag import query_with_rag_mobile

router = APIRouter(prefix="/rag", tags=["RAG Mobile"])

@router.post("/chat", response_model=ChatResponse, status_code=status.HTTP_200_OK)
async def chat_with_medical_records(
    request: ChatRequest,
    current_user = Depends(get_current_active_user_for_rag_mobile),
    db: Session = Depends(get_db)
):
    """
    **Mobile Endpoint** - Tanya jawab tentang rekam medis dan data kesehatan user yang sedang login
    
    🎯 **Service khusus untuk pengguna mobile** dengan:
    - ✅ Jawaban yang lebih PANJANG, RAMAH, dan MENYENANGKAN
    - ✅ Penjelasan yang detail dan edukatif
    - ✅ Bahasa yang natural dan conversational
    - ✅ Tips kesehatan dan saran follow-up
    - ✅ Automatic patient_id dari authenticated user (security enforced)
    - ✅ Enhanced context retrieval:
        - Medical records (diagnoses, prescriptions, lab results)
        - Patient allergies
        - Health calculations (BMI, BMR, TDEE, Body Fat, Heart Rate, dll)
        - Health metrics history (trends, statistics)
    - ✅ Better error handling dengan user-friendly messages
    
    **Requires authentication** - User harus login terlebih dahulu untuk mengakses endpoint ini.
    **Petugas (admin, dokter, staff) tidak dapat mengakses endpoint ini.**
    
    **Example queries:**
    - Medical Records:
      - "Apa saja alergi saya?"
      - "Kapan terakhir kali saya berobat?"
      - "Apa diagnosis terakhir saya?"
      - "Obat apa yang sedang saya konsumsi?"
      - "Bagaimana hasil lab saya?"
      - "Riwayat penyakit apa saja yang pernah saya alami?"
      - "Jelaskan tentang kondisi kesehatan saya"
    
    - Health Calculator Data:
      - "Berapa BMI saya saat ini?"
      - "Berapa kebutuhan kalori harian saya?"
      - "Bagaimana tren berat badan saya?"
      - "Berapa detak jantung maksimal saya?"
      - "Berapa kebutuhan air harian saya?"
      - "Bagaimana kondisi body fat saya?"
      - "Berapa kebutuhan protein harian saya?"
      - "Bagaimana tren kesehatan saya?"
    
    **Response:**
    - `answer`: Jawaban AI yang ramah, lengkap, dan engaging (minimal 200-300 kata)
    - `query`: Pertanyaan yang ditanyakan user
    - `success`: Status berhasil/gagal
    - `processing_time`: Waktu pemrosesan dalam detik
    - `suggestions`: Saran pertanyaan follow-up (optional)
    """
    start_time = time.time()
    
    try:
        # Validate query
        if not request.query or len(request.query.strip()) < 3:
            processing_time = time.time() - start_time
            return ChatResponse(
                answer="Halo! 😊 Pertanyaan Anda terlalu pendek. Silakan ajukan pertanyaan yang lebih spesifik (minimal 3 karakter). "
                      "Contoh: 'Apa saja alergi saya?' atau 'Bagaimana hasil lab terakhir saya?'",
                query=request.query,
                success=False,
                processing_time=processing_time,
                suggestions=[
                    "Apa saja alergi saya?",
                    "Kapan terakhir kali saya berobat?",
                    "Apa diagnosis terakhir saya?",
                    "Obat apa yang sedang saya konsumsi?"
                ]
            )
        
        # Gunakan patient_id dari user yang login (security enforced)
        patient_id = current_user.id
        
        # Query dengan RAG Mobile - otomatis filter berdasarkan patient_id user
        result = query_with_rag_mobile(
            query=request.query.strip(),
            patient_id=patient_id,  # Otomatis dari current_user.id
            max_documents=5,  # Default untuk mobile
            similarity_threshold=0.6,  # More lenient threshold for mobile
            db=db
        )
        
        processing_time = time.time() - start_time
        
        return ChatResponse(
            answer=result.get("answer", ""),
            query=request.query,
            success=result.get("success", True),
            processing_time=processing_time,
            suggestions=result.get("suggestions", [])
        )
    
    except ValueError as e:
        # Handle validation errors
        processing_time = time.time() - start_time
        return ChatResponse(
            answer=f"Maaf, terjadi kesalahan validasi: {str(e)}. Silakan coba lagi dengan pertanyaan yang berbeda. 😔",
            query=request.query,
            success=False,
            processing_time=processing_time,
            suggestions=[
                "Apa saja alergi saya?",
                "Kapan terakhir kali saya berobat?",
                "Apa diagnosis terakhir saya?"
            ]
        )
    except Exception as e:
        # Handle other errors with user-friendly messages
        processing_time = time.time() - start_time
        error_msg = str(e).lower()
        
        if "database" in error_msg or "connection" in error_msg:
            error_message = "Maaf, terjadi masalah dengan database. Silakan coba lagi beberapa saat lagi. 🙏"
        elif "timeout" in error_msg:
            error_message = "Maaf, waktu tunggu habis. Silakan coba lagi dengan pertanyaan yang lebih spesifik. ⏱️"
        elif "rate limit" in error_msg or "quota" in error_msg:
            error_message = "Maaf, layanan sedang sibuk. Silakan coba lagi beberapa saat lagi. 😊"
        else:
            error_message = "Maaf, terjadi kesalahan saat memproses pertanyaan Anda. Silakan coba lagi atau hubungi administrator. 😔"
        
        return ChatResponse(
            answer=error_message,
            query=request.query,
            success=False,
            processing_time=processing_time,
            suggestions=[
                "Apa saja alergi saya?",
                "Kapan terakhir kali saya berobat?",
                "Apa diagnosis terakhir saya?"
            ]
        )

@router.get("/health")
async def rag_health():
    """Health check for RAG Service Mobile"""
    return {
        "status": "healthy",
        "service": "RAG Service Mobile",
        "llm_model": "configured",
        "vector_store": "configured"
    }

