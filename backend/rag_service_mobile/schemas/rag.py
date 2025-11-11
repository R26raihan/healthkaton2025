"""
RAG Schemas for Mobile Service
"""
from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    """Schema for mobile chat request - simple Q&A for users"""
    query: str  # User's question about their medical records

class ChatResponse(BaseModel):
    """Schema for mobile chat response - friendly and engaging"""
    answer: str  # AI-generated answer (longer, friendlier, more engaging)
    query: str  # Echo back the question
    success: bool
    processing_time: Optional[float] = None
    suggestions: Optional[list] = None  # Optional follow-up question suggestions

