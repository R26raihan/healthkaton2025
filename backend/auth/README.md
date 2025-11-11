# Authentication Service

Struktur folder yang terorganisir untuk Authentication Service menggunakan FastAPI.

## Struktur Folder

```
auth/
├── __init__.py              # Package initialization
├── main.py                   # Main FastAPI application
├── app.py                    # Backward compatibility entry point
│
├── api/                      # API Layer
│   ├── __init__.py
│   └── routes/               # API Routes
│       ├── __init__.py
│       ├── auth.py           # Authentication endpoints (register, login, /me)
│       └── health.py         # Health check endpoints
│
├── core/                     # Core Configuration & Dependencies
│   ├── __init__.py
│   ├── config.py             # Environment configuration (.env)
│   ├── database.py           # Database connection & session
│   └── dependencies.py      # FastAPI dependencies (auth)
│
├── models/                   # Database Models (SQLAlchemy)
│   ├── __init__.py
│   └── user.py              # User model
│
├── schemas/                  # Pydantic Schemas
│   ├── __init__.py
│   └── user.py              # User request/response schemas
│
└── services/                 # Business Logic Services
    ├── __init__.py
    ├── security.py           # Password hashing & JWT utilities
    └── crud.py               # Database CRUD operations
```

## Keterangan Folder

- **api/**: Berisi semua API routes/endpoints
- **core/**: Konfigurasi utama, database setup, dan dependencies
- **models/**: SQLAlchemy database models
- **schemas/**: Pydantic schemas untuk validation
- **services/**: Business logic dan utility functions

## Cara Menjalankan

```bash
# Menggunakan main.py
uvicorn auth.main:app --reload

# Atau menggunakan running.py dari root folder
python running.py
```

## Endpoints

- `POST /register` - Register user baru
- `POST /login` - Login dan dapatkan JWT token
- `GET /me` - Get current user (requires authentication)
- `GET /health/` - Health check
- `GET /health/db` - Database connection check

