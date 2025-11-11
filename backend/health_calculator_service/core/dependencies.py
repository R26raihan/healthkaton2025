"""
Authentication dependencies for Health Calculator Service
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
    from auth.models.user import User

# HTTPBearer untuk Swagger UI - bisa langsung paste token
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
        DB_NAME = os.getenv("DB_NAME", "healthkon_bpjs")
        
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

async def get_current_user_from_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get current user from Bearer token - untuk mobile app user (bukan petugas)"""
    from auth.models.user import User
    from auth.models.petugas import Petugas
    from auth.services.security import verify_token
    import traceback
    
    db = None
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials. This service is only accessible by regular users (not petugas).",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    # Check if credentials are provided
    if not credentials:
        raise credentials_exception
    
    try:
        # Extract token dari credentials
        token = credentials.credentials
        if not token:
            raise credentials_exception
        
        # Verify token
        try:
            token_data = verify_token(token)
        except Exception as token_error:
            raise credentials_exception
        
        # Get database session
        db = _get_auth_db_session()
        
        try:
            # Check if email belongs to petugas first - reject if petugas
            petugas = db.query(Petugas).filter(Petugas.email == token_data.email).first()
            if petugas:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied. This service is only accessible by regular users. Please login as user (not petugas)."
                )
            
            # Query user by email - Health Calculator hanya untuk user biasa
            user = db.query(User).filter(User.email == token_data.email).first()
            
            if user is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="User not found",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            
            return user
        finally:
            db.close()
        
    except HTTPException:
        raise
    except Exception as e:
        raise credentials_exception

async def get_current_active_user_for_calculator(
    current_user = Depends(get_current_user_from_token)
):
    """Get current active user for health calculator - hanya user yang bisa akses (bukan petugas)"""
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

