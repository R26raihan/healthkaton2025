"""
RAG Schemas
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class QueryRequest(BaseModel):
    """Schema for RAG query request"""
    query: str
    patient_id: Optional[int] = None  # Filter by patient if provided
    max_documents: Optional[int] = 5
    similarity_threshold: Optional[float] = 0.7

class DocumentChunk(BaseModel):
    """Schema for document chunk in search results"""
    doc_id: str
    patient_id: int
    record_id: Optional[str]
    chunk_text: str
    similarity_score: float
    metadata: Optional[dict] = None

class QueryResponse(BaseModel):
    """Schema for RAG query response"""
    query: str
    answer: str
    relevant_documents: List[DocumentChunk]
    sources: List[str]  # Document IDs or URLs
    model_used: str
    processing_time: Optional[float] = None
    warning: Optional[str] = None  # Optional warning message (e.g., "No relevant documents found")

class SearchRequest(BaseModel):
    """Schema for document search request"""
    query: str
    patient_id: Optional[int] = None
    limit: Optional[int] = 10
    threshold: Optional[float] = 0.7

class SearchResponse(BaseModel):
    """Schema for document search response"""
    query: str
    results: List[DocumentChunk]
    total_found: int

class EmbedDocumentRequest(BaseModel):
    """Schema for embedding document request"""
    doc_id: str  # Medical document ID
    force_reembed: Optional[bool] = False

class EmbedDocumentResponse(BaseModel):
    """Schema for embedding document response"""
    doc_id: str
    status: str  # success, error, skipped
    message: str
    embedding_dimension: Optional[int] = None

class ChatRequest(BaseModel):
    """Schema for mobile chat request - simple Q&A for users"""
    query: str  # User's question about their medical records

class ChatResponse(BaseModel):
    """Schema for mobile chat response"""
    answer: str  # AI-generated answer
    query: str  # Echo back the question
    success: bool
    processing_time: Optional[float] = None

