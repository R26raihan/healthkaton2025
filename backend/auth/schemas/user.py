"""
Pydantic schemas for request/response validation
"""
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

# User Schemas
class UserCreate(BaseModel):
    """Schema for user registration"""
    name: str
    email: EmailStr
    password: str
    phoneNumber: Optional[str] = None
    ktpNumber: Optional[str] = None
    kkNumber: Optional[str] = None

class UserResponse(BaseModel):
    """Schema for user response"""
    id: int
    name: str
    email: str
    phoneNumber: Optional[str] = None
    ktpNumber: Optional[str] = None
    kkNumber: Optional[str] = None
    is_active: bool
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# Token Schemas
class Token(BaseModel):
    """Schema for JWT token response"""
    access_token: str
    token_type: str

class TokenData(BaseModel):
    """Schema for token data"""
    email: Optional[str] = None

