"""
Configuration settings for RAG Service Mobile
"""
import os
import sys
from dotenv import load_dotenv

# Load .env file from root directory
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
env_path = os.path.join(root_dir, '.env')
load_dotenv(dotenv_path=env_path)

# Service specific config
SERVICE_NAME = "RAG Service Mobile"
SERVICE_VERSION = "1.0.0"

# LLM Model Configuration - OpenRouter
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "openrouter")  # openrouter, openai, anthropic, local
# Using the same model as admin service for consistency
# Can be overridden via LLM_MODEL_MOBILE environment variable
LLM_MODEL_NAME = os.getenv("LLM_MODEL_MOBILE", "deepseek/deepseek-r1-0528-qwen3-8b:free")  # Same as admin service
LLM_API_KEY = os.getenv("LLM_API_KEY", "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")
LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://openrouter.ai/api/v1")
LLM_SITE_URL = os.getenv("LLM_SITE_URL", "https://github.com/healthkon")
LLM_SITE_NAME = os.getenv("LLM_SITE_NAME", "Healthkon BPJS RAG Service Mobile")

# Embedding Model Configuration
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "text-embedding-ada-002")
EMBEDDING_DIMENSION = int(os.getenv("EMBEDDING_DIMENSION", "1536"))

# Vector Store Configuration
USE_VECTOR_STORE = os.getenv("USE_VECTOR_STORE", "false").lower() == "true"
VECTOR_STORE_TYPE = os.getenv("VECTOR_STORE_TYPE", "pinecone")

# RAG Configuration - Optimized for user-friendly responses
MAX_CONTEXT_DOCUMENTS = int(os.getenv("MAX_CONTEXT_DOCUMENTS_MOBILE", "5"))
SIMILARITY_THRESHOLD = float(os.getenv("SIMILARITY_THRESHOLD_MOBILE", "0.6"))  # Lower threshold for more lenient matching

# Response Configuration
# Adjusted for free tier limits - consider total tokens (input + output)
# Free tier typically allows ~2666 total tokens, so we reserve tokens for input context
MAX_RESPONSE_TOKENS = int(os.getenv("MAX_RESPONSE_TOKENS_MOBILE", "2000"))  # Adjusted for credit limits (2000 output + context input)
TEMPERATURE = float(os.getenv("TEMPERATURE_MOBILE", "0.8"))  # Higher temperature for more natural, friendly responses

