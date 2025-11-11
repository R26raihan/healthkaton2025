"""
Dependencies for RM Service - Petugas (Staff) token-based authentication only
"""
import sys
import os
from typing import TYPE_CHECKING
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

# Add parent directory to import auth dependencies
_parent_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(_parent_dir)

# Type checking only - avoid circular import
if TYPE_CHECKING:
    from auth.models.petugas import Petugas
    from sqlalchemy.orm import Session

# HTTPBearer untuk Swagger UI - bisa langsung paste token
# auto_error=False allows us to handle errors manually
security = HTTPBearer(auto_error=False)

# Lazy-initialized database engine and session (singleton pattern)
_auth_engine = None
_auth_session_local = None

def _get_auth_db_session():
    """Get auth database session - lazy initialization to avoid circular import"""
    global _auth_engine, _auth_session_local
    
    if _auth_engine is None:
        # Lazy import config - import directly from config module
        import os
        from dotenv import load_dotenv
        load_dotenv()
        
        # Get DB config from environment or use defaults
        DB_USER = os.getenv("DB_USER", "root")
        DB_PASSWORD = os.getenv("DB_PASSWORD", "")
        DB_HOST = os.getenv("DB_HOST", "localhost")
        DB_PORT = int(os.getenv("DB_PORT", "3306"))
        DB_NAME = os.getenv("DB_NAME", "healthkon")
        
        from sqlalchemy import create_engine
        from sqlalchemy.orm import sessionmaker
        from sqlalchemy.pool import QueuePool
        
        # Create database connection
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
    """Get current petugas from Bearer token - RM Service hanya bisa diakses oleh petugas"""
    # Lazy import inside function to avoid circular import
    from auth.models.petugas import Petugas
    from auth.services.security import verify_token
    import traceback
    
    db = None
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials. Only petugas (staff) can access this service.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    # Check if credentials are provided
    if not credentials:
        print("[RM Service] No credentials provided")
        raise credentials_exception
    
    try:
        # Extract token dari credentials
        token = credentials.credentials
        if not token:
            print("[RM Service] Token is empty")
            raise credentials_exception
        
        print(f"[RM Service] Token received: {token[:20]}...")  # Log first 20 chars
        
        # Verify token
        try:
            token_data = verify_token(token)
        except Exception as token_error:
            # Token invalid or expired
            print(f"[RM Service] Token verification failed: {str(token_error)}")
            raise credentials_exception
        
        # Get database session
        db = _get_auth_db_session()
        
        # Query petugas by email - RM Service hanya untuk petugas
        petugas = db.query(Petugas).filter(Petugas.email == token_data.email).first()
        
        if petugas is None:
            print(f"[RM Service] Petugas not found for email: {token_data.email}")
            print(f"[RM Service] This service is only accessible by petugas (staff), not regular users")
            if db:
                db.close()
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. This service is only accessible by petugas (staff). Please login as petugas."
            )
        
        # Return petugas (db will be closed after request)
        return petugas
        
    except HTTPException:
        # Re-raise HTTP exceptions (401, 403, etc)
        if db:
            try:
                db.close()
            except:
                pass
        raise
    except Exception as e:
        # Other exceptions - log and return 401
        print(f"[RM Service] Unexpected error: {str(e)}")
        print(f"[RM Service] Traceback: {traceback.format_exc()}")
        if db:
            try:
                db.close()
            except:
                pass
        raise credentials_exception

async def get_current_active_petugas_for_rm(
    current_petugas = Depends(get_current_petugas_from_token)
):
    """Get current active petugas for RM service - hanya petugas yang bisa akses"""
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

