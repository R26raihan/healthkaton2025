# Dockerfile for RAG Service
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Set environment variable (optional, membantu import)
ENV PYTHONPATH=/app

# Install dotenv to read .env
RUN pip install python-dotenv

# Set PYTHONPATH ke /app agar absolute import berhasil
ENV PYTHONPATH=/app

# Expose FastAPI port
EXPOSE 8002

# Run Uvicorn server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002", "--reload"]

