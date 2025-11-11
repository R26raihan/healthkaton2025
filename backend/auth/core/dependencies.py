"""
FastAPI dependencies for authentication
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .database import get_db
from ..models.user import User
from ..services.security import verify_token

# OAuth2 scheme
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    token_data = verify_token(token)
    user = db.query(User).filter(User.email == token_data.email).first()
    
    if user is None:
        raise credentials_exception
    
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    """Get current active user"""
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# Petugas authentication dependencies
async def get_current_petugas(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    """Get current authenticated petugas from JWT token"""
    from ..models.petugas import Petugas
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        token_data = verify_token(token)
        # Check if token is for petugas (has type field)
        # For now, we'll check if user exists in petugas table
        petugas = db.query(Petugas).filter(Petugas.email == token_data.email).first()
        
        if petugas is None:
            raise credentials_exception
        
        return petugas
    except Exception:
        raise credentials_exception

async def get_current_active_petugas(
    current_petugas = Depends(get_current_petugas)
):
    """Get current active petugas"""
    if not current_petugas.is_active:
        raise HTTPException(status_code=400, detail="Inactive petugas")
    return current_petugas

# Universal dependency that works for both User and Petugas
async def get_current_active_user_or_petugas(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    """Get current active user or petugas - tries user first, then petugas"""
    from ..models.petugas import Petugas
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        token_data = verify_token(token)
        email = token_data.email
        
        # Try user first
        user = db.query(User).filter(User.email == email).first()
        if user:
            if not user.is_active:
                raise HTTPException(status_code=400, detail="Inactive user")
            return user
        
        # Try petugas
        petugas = db.query(Petugas).filter(Petugas.email == email).first()
        if petugas:
            if not petugas.is_active:
                raise HTTPException(status_code=400, detail="Inactive petugas")
            return petugas
        
        raise credentials_exception
    except HTTPException:
        raise
    except Exception:
        raise credentials_exception

