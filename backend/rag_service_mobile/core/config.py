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

# LLM Model Configuration - Gemini
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "gemini")  # gemini, openrouter, openai, anthropic, local
# Using Gemini model for mobile service
# Can be overridden via LLM_MODEL_MOBILE environment variable
LLM_MODEL_NAME = os.getenv("LLM_MODEL_MOBILE", "gemini-2.0-flash")  # Gemini model - using gemini-2.0-flash (stable)
LLM_API_KEY = os.getenv("LLM_API_KEY", "AIzaSyCYn1wsNyiEjIwDShmBznGlGbJAwpAaISc")  # Gemini API Key
LLM_BASE_URL = os.getenv("LLM_BASE_URL", None)  # Not needed for Gemini
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

