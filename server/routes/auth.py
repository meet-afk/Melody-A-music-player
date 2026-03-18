import uuid
import bcrypt
from fastapi import Depends, HTTPException, Header
from database import get_db
from middleware.auth_middleware import auth_middleware
from pydantic_schemas.user_login import UserLogin
from pydantic_schemas.usercreate import UserCreate
from fastapi import APIRouter
from sqlalchemy.orm import Session, joinedload
from models.userbase import User
import jwt
from dotenv import load_dotenv
import os

load_dotenv()

JWT_SECRET = os.getenv("JWT_SECRET")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

router = APIRouter()
@router.post("/signup", status_code=201 )

def Signup_user(user: UserCreate, db:Session =Depends(get_db)):
    
    hash_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())

    user_db = db.query(User).filter(User.email == user.email).first()
    if user_db:
        raise HTTPException(400,"User with this email already exists.")
    
    user_db = User(
        id=str(uuid.uuid4()),
        name=user.name,
        email=user.email,
        password=hash_pw
    )
    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db

@router.post("/login")
def Login_user(user: UserLogin, db:Session =Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()
    if not user_db:
        raise HTTPException(400,"Invalid Credentials")
    
    is_match= bcrypt.checkpw(user.password.encode(), user_db.password)

    if not is_match:
        raise HTTPException(400,"Incorrect Password")
    
    if not JWT_SECRET:
        raise HTTPException(500, "JWT_SECRET is not set")
    
    token = jwt.encode({"user_id": user_db.id}, JWT_SECRET, algorithm=JWT_ALGORITHM)
    
    return {"token": token, "user": user_db}

@router.get("/")
def current_user_data(db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict["user_id"]).options(
        joinedload(User.favourites)
    ).first()

    if not user:
        raise HTTPException(404, "User not found")
    return user