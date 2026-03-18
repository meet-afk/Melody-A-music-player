from fastapi import HTTPException, Header
from dotenv import load_dotenv
import os
import jwt

load_dotenv()

JWT_SECRET = os.getenv("JWT_SECRET")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")


def auth_middleware(x_auth_token = Header()):
    try:
        if not x_auth_token:
            raise HTTPException(401, "Token is missing")
        
        verified_token = jwt.decode(x_auth_token, JWT_SECRET, algorithms=[JWT_ALGORITHM])

        if not verified_token:
            raise HTTPException(401, "Invalid token")
            
        uid = verified_token.get("user_id")
        return {"user_id": uid, "token": x_auth_token}

    except jwt.PyJWTError:
            raise HTTPException(401, "Invalid token")