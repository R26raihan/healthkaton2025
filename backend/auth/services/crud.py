"""
Database CRUD operations
"""
from sqlalchemy.orm import Session
from typing import Optional, Tuple, List
from ..models.user import User
from ..models.petugas import Petugas
from ..services.security import verify_password, get_password_hash

def get_user_by_email(db: Session, email: str) -> Optional[User]:
    """Get user by email"""
    return db.query(User).filter(User.email == email).first()

def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
    """Authenticate user with email and password"""
    user = get_user_by_email(db, email)
    if not user:
        return None
    if not verify_password(password, user.password):
        return None
    return user

def create_user(db: Session, user_data: dict) -> User:
    """Create a new user"""
    hashed_password = get_password_hash(user_data["password"])
    db_user = User(
        name=user_data["name"],
        email=user_data["email"],
        password=hashed_password,
        phoneNumber=user_data.get("phoneNumber"),
        ktpNumber=user_data.get("ktpNumber"),
        kkNumber=user_data.get("kkNumber")
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def check_user_exists(db: Session, email: str, ktp_number: Optional[str] = None) -> Tuple[bool, str]:
    """Check if user exists by email or ktpNumber"""
    user = db.query(User).filter(
        (User.email == email) | (User.ktpNumber == ktp_number)
    ).first()
    
    if user:
        if user.email == email:
            return True, "Email already registered"
        else:
            return True, "KTP Number already registered"
    return False, ""

# Petugas CRUD Operations
def get_petugas_by_email(db: Session, email: str) -> Optional[Petugas]:
    """Get petugas by email - menggunakan raw SQL untuk handle enum"""
    from sqlalchemy import text
    from ..models.petugas import PetugasRole
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT id, name, email, password, phoneNumber, nip, role, 
               specialization, is_active, created_at, updated_at
        FROM petugas
        WHERE email = :email
    """)
    
    result = db.execute(query, {"email": email}).first()
    
    if not result:
        return None
    
    # Convert role string to enum
    role_str = result.role
    role_enum = None
    if role_str:
        for r in PetugasRole:
            if r.value == role_str:
                role_enum = r
                break
    
    if not role_enum:
        role_enum = PetugasRole.STAFF
    
    return Petugas(
        id=result.id,
        name=result.name,
        email=result.email,
        password=result.password,
        phoneNumber=result.phoneNumber,
        nip=result.nip,
        role=role_enum,
        specialization=result.specialization,
        is_active=bool(result.is_active),
        created_at=result.created_at,
        updated_at=result.updated_at
    )

def authenticate_petugas(db: Session, email: str, password: str) -> Optional[Petugas]:
    """Authenticate petugas with email and password"""
    petugas = get_petugas_by_email(db, email)
    if not petugas:
        return None
    if not verify_password(password, petugas.password):
        return None
    return petugas

def create_petugas(db: Session, petugas_data: dict) -> Petugas:
    """Create a new petugas - menggunakan raw SQL untuk handle enum UPPERCASE"""
    from sqlalchemy import text
    
    hashed_password = get_password_hash(petugas_data["password"])
    
    # Handle role enum - convert to UPPERCASE string untuk database
    role_value = petugas_data.get("role")
    if role_value:
        # Convert to UPPERCASE string
        if isinstance(role_value, str):
            role_str_upper = role_value.upper()
        else:
            # If it's an enum, get the value and convert to UPPERCASE
            role_str_upper = str(role_value).upper()
            # Remove enum prefix if present (e.g., "PetugasRole.STAFF" -> "STAFF")
            if "." in role_str_upper:
                role_str_upper = role_str_upper.split(".")[-1]
    else:
        role_str_upper = "STAFF"
    
    # Validate role value
    valid_roles = ["ADMIN", "DOKTER", "PERAWAT", "ADMINISTRATOR", "STAFF"]
    if role_str_upper not in valid_roles:
        role_str_upper = "STAFF"  # Default to STAFF if invalid
    
    # Use raw SQL to insert with proper enum value (UPPERCASE for MySQL enum)
    query = text("""
        INSERT INTO petugas 
        (name, email, password, phoneNumber, nip, role, specialization, is_active)
        VALUES 
        (:name, :email, :password, :phoneNumber, :nip, :role, :specialization, :is_active)
    """)
    
    db.execute(query, {
        "name": petugas_data["name"],
        "email": petugas_data["email"],
        "password": hashed_password,
        "phoneNumber": petugas_data.get("phoneNumber"),
        "nip": petugas_data.get("nip"),
        "role": role_str_upper,  # UPPERCASE for MySQL enum
        "specialization": petugas_data.get("specialization"),
        "is_active": petugas_data.get("is_active", True)
    })
    db.commit()
    
    # Get the created petugas by email
    return get_petugas_by_email(db, petugas_data["email"])

def get_petugas_by_id(db: Session, petugas_id: int) -> Optional[Petugas]:
    """Get petugas by ID - menggunakan raw SQL untuk handle enum"""
    from sqlalchemy import text
    from ..models.petugas import PetugasRole
    
    # Query with raw SQL to handle enum properly
    query = text("""
        SELECT id, name, email, password, phoneNumber, nip, role, 
               specialization, is_active, created_at, updated_at
        FROM petugas
        WHERE id = :petugas_id
    """)
    
    result = db.execute(query, {"petugas_id": petugas_id}).first()
    
    if not result:
        return None
    
    # Convert role string to enum
    # Database stores UPPERCASE (ADMIN, STAFF, etc.)
    role_str = result.role
    role_enum = None
    if role_str:
        # Database already returns UPPERCASE, match with enum values
        for r in PetugasRole:
            if r.value == role_str:
                role_enum = r
                break
    
    if not role_enum:
        role_enum = PetugasRole.STAFF  # default
    
    return Petugas(
        id=result.id,
        name=result.name,
        email=result.email,
        password=result.password,
        phoneNumber=result.phoneNumber,
        nip=result.nip,
        role=role_enum,
        specialization=result.specialization,
        is_active=bool(result.is_active),
        created_at=result.created_at,
        updated_at=result.updated_at
    )

def get_all_petugas(db: Session, skip: int = 0, limit: int = 100) -> List[Petugas]:
    """Get all petugas - menggunakan raw SQL untuk handle enum"""
    from sqlalchemy import text
    from ..models.petugas import PetugasRole
    
    query = text("""
        SELECT id, name, email, password, phoneNumber, nip, role, 
               specialization, is_active, created_at, updated_at
        FROM petugas
        ORDER BY created_at DESC
        LIMIT :limit OFFSET :skip
    """)
    
    result = db.execute(query, {"limit": limit, "skip": skip})
    petugas_list = []
    
    for row in result:
        # Convert role string to enum
        role_str = row.role
        role_enum = None
        if role_str:
            for r in PetugasRole:
                if r.value == role_str:
                    role_enum = r
                    break
        
        if not role_enum:
            role_enum = PetugasRole.STAFF
        
        petugas = Petugas(
            id=row.id,
            name=row.name,
            email=row.email,
            password=row.password,
            phoneNumber=row.phoneNumber,
            nip=row.nip,
            role=role_enum,
            specialization=row.specialization,
            is_active=bool(row.is_active),
            created_at=row.created_at,
            updated_at=row.updated_at
        )
        petugas_list.append(petugas)
    
    return petugas_list

def update_petugas(db: Session, petugas_id: int, petugas_data: dict) -> Optional[Petugas]:
    """Update petugas - menggunakan raw SQL untuk handle enum UPPERCASE"""
    from sqlalchemy import text
    
    petugas = get_petugas_by_id(db, petugas_id)
    if not petugas:
        return None
    
    # Build update query dynamically
    update_fields = []
    update_values = {"petugas_id": petugas_id}
    
    if "name" in petugas_data:
        update_fields.append("name = :name")
        update_values["name"] = petugas_data["name"]
    if "email" in petugas_data:
        update_fields.append("email = :email")
        update_values["email"] = petugas_data["email"]
    if "password" in petugas_data:
        update_fields.append("password = :password")
        update_values["password"] = get_password_hash(petugas_data["password"])
    if "phoneNumber" in petugas_data:
        update_fields.append("phoneNumber = :phoneNumber")
        update_values["phoneNumber"] = petugas_data["phoneNumber"]
    if "nip" in petugas_data:
        update_fields.append("nip = :nip")
        update_values["nip"] = petugas_data["nip"]
    if "role" in petugas_data:
        # Convert role to UPPERCASE string
        role_value = petugas_data["role"]
        if isinstance(role_value, str):
            role_str_upper = role_value.upper()
        else:
            role_str_upper = str(role_value).upper()
            if "." in role_str_upper:
                role_str_upper = role_str_upper.split(".")[-1]
        
        # Validate
        valid_roles = ["ADMIN", "DOKTER", "PERAWAT", "ADMINISTRATOR", "STAFF"]
        if role_str_upper in valid_roles:
            update_fields.append("role = :role")
            update_values["role"] = role_str_upper
    if "specialization" in petugas_data:
        update_fields.append("specialization = :specialization")
        update_values["specialization"] = petugas_data["specialization"]
    if "is_active" in petugas_data:
        update_fields.append("is_active = :is_active")
        update_values["is_active"] = petugas_data["is_active"]
    
    if not update_fields:
        return petugas  # No fields to update
    
    # Use raw SQL to update with proper enum value
    query = text(f"UPDATE petugas SET {', '.join(update_fields)} WHERE id = :petugas_id")
    db.execute(query, update_values)
    db.commit()
    
    # Get updated petugas
    return get_petugas_by_id(db, petugas_id)

def delete_petugas(db: Session, petugas_id: int) -> bool:
    """Delete petugas"""
    petugas = get_petugas_by_id(db, petugas_id)
    if not petugas:
        return False
    db.delete(petugas)
    db.commit()
    return True

def check_petugas_exists(db: Session, email: str, nip: Optional[str] = None) -> Tuple[bool, str]:
    """Check if petugas exists by email or nip - menggunakan raw SQL"""
    from sqlalchemy import text
    
    if nip:
        query = text("""
            SELECT email, nip FROM petugas 
            WHERE email = :email OR nip = :nip 
            LIMIT 1
        """)
        result = db.execute(query, {"email": email, "nip": nip}).first()
    else:
        query = text("""
            SELECT email, nip FROM petugas 
            WHERE email = :email 
            LIMIT 1
        """)
        result = db.execute(query, {"email": email}).first()
    
    if result:
        if result.email == email:
            return True, "Email already registered"
        elif nip and result.nip == nip:
            return True, "NIP already registered"
    return False, ""

