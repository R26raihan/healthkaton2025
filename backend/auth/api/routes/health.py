"""
Health check and database connection status endpoints
"""
import asyncio
from fastapi import APIRouter, HTTPException, status
from sqlalchemy import text
from ...core.database import engine

router = APIRouter(prefix="/health", tags=["Health Check"])

def test_db_connection():
    """Synchronous database connection test"""
    try:
        # Test connection first
        conn = engine.connect()
        
        # Test with simple query
        result = conn.execute(text("SELECT 1 as test"))
        test_value = result.scalar()
        
        # Get database version (MySQL)
        version_result = conn.execute(text("SELECT VERSION()"))
        db_version = version_result.scalar()
        
        # Check if users table exists
        table_check = conn.execute(text("SHOW TABLES LIKE 'users'"))
        table_exists = table_check.fetchone() is not None
        
        conn.close()
        
        return {
            "status": "connected",
            "database": {
                "connected": True,
                "version": db_version,
                "test_query": "success",
                "users_table_exists": table_exists
            },
            "message": "Database connection successful"
        }
    except Exception as e:
        # Return error details for debugging
        error_msg = str(e)
        error_type = type(e).__name__
        raise Exception(f"{error_type}: {error_msg}")

@router.get("/")
async def health_check():
    """Basic health check endpoint"""
    return {
        "status": "healthy",
        "service": "Authentication Service",
        "version": "1.0.0"
    }

@router.get("/db")
async def check_database_connection():
    """
    Check database connection status with timeout
    
    Returns database connection information and status
    """
    try:
        # Run blocking database operation in thread pool with timeout
        loop = asyncio.get_event_loop()
        result = await asyncio.wait_for(
            loop.run_in_executor(None, test_db_connection),
            timeout=5.0
        )
        return result
        
    except asyncio.TimeoutError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "status": "timeout",
                "database": {
                    "connected": False,
                    "error": "Database connection timeout (5 seconds)",
                    "error_type": "TimeoutError"
                },
                "message": "Database connection timed out. Please check your database configuration."
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "status": "disconnected",
                "database": {
                    "connected": False,
                    "error": str(e),
                    "error_type": type(e).__name__
                },
                "message": "Database connection failed"
            }
        )

