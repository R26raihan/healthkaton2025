"""
Configuration settings for RAG Service
"""
import os
import sys
from dotenv import load_dotenv

# Load .env file from root directory
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
env_path = os.path.join(root_dir, '.env')
load_dotenv(dotenv_path=env_path)

# Service specific config
SERVICE_NAME = "RAG Service"
SERVICE_VERSION = "1.0.0"

# LLM Model Configuration - OpenRouter
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "openrouter")  # openrouter, openai, anthropic, local
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME", "deepseek/deepseek-r1-0528-qwen3-8b:free")  # OpenRouter model format
LLM_API_KEY = os.getenv("LLM_API_KEY", "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")
LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://openrouter.ai/api/v1")  # OpenRouter API URL
LLM_SITE_URL = os.getenv("LLM_SITE_URL", "https://github.com/healthkon")  # For OpenRouter rankings
LLM_SITE_NAME = os.getenv("LLM_SITE_NAME", "Healthkon BPJS RAG Service")  # For OpenRouter rankings

# Embedding Model Configuration
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "text-embedding-ada-002")
EMBEDDING_DIMENSION = int(os.getenv("EMBEDDING_DIMENSION", "1536"))

# Vector Store Configuration
USE_VECTOR_STORE = os.getenv("USE_VECTOR_STORE", "false").lower() == "true"
VECTOR_STORE_TYPE = os.getenv("VECTOR_STORE_TYPE", "pinecone")  # pinecone, qdrant, faiss, etc.

# RAG Configuration
MAX_CONTEXT_DOCUMENTS = int(os.getenv("MAX_CONTEXT_DOCUMENTS", "5"))
SIMILARITY_THRESHOLD = float(os.getenv("SIMILARITY_THRESHOLD", "0.7"))

