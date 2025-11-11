"""
Database connection for Health Calculator Service
Reuses database connection from auth service for consistency
"""
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# Reuse database from auth service
try:
    from auth.core.database import engine, Base, get_db
except ImportError:
    # Fallback: create own database connection
    from sqlalchemy import create_engine
    from sqlalchemy.ext.declarative import declarative_base
    from sqlalchemy.orm import sessionmaker
    from .config import DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME
    
    # Create database URL
    DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    
    # Create engine
    engine = create_engine(
        DATABASE_URL,
        pool_pre_ping=True,
        pool_recycle=3600,
        echo=False
    )
    
    # Create session factory
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    # Base class for models
    Base = declarative_base()
    
    def get_db():
        """Dependency for getting database session"""
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

