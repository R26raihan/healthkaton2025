# Gunakan Python 3.10 slim
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install dependencies OS
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy semua source code
COPY . .

# Set PYTHONPATH supaya modul bisa diimport secara absolute
ENV PYTHONPATH=/app

# Expose port FastAPI
EXPOSE 8000

# Jalankan FastAPI dari app.py (absolute import dari root)
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]



