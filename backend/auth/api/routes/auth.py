"""
Authentication routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta
from core.database import get_db
from models.user import User
from schemas.user import UserCreate, UserResponse, Token
from core.dependencies import get_current_active_user
from services.crud import authenticate_user, create_user, check_user_exists
from services.security import create_access_token
from core.config import ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(prefix="", tags=["Authentication"])

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    # Check if user already exists
    exists, message = check_user_exists(db, user.email, user.ktpNumber)
    if exists:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    # Create new user
    user_data = {
        "name": user.name,
        "email": user.email,
        "password": user.password,
        "phoneNumber": user.phoneNumber,
        "ktpNumber": user.ktpNumber,
        "kkNumber": user.kkNumber
    }
    db_user = create_user(db, user_data)
    return db_user

@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """Login and get JWT token"""
    # form_data.username is used for email in this case (OAuth2 standard)
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserResponse, summary="Get current user", description="Get current authenticated user information. **Requires authentication token.**")
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    """
    Get current user information
    
    **Note**: This endpoint requires authentication.
    - Click the "Authorize" button at the top of Swagger UI
    - Enter the token you got from /login endpoint
    - Format: `Bearer YOUR_TOKEN_HERE` (or just paste the token)
    """
    return current_user

