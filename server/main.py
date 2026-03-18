from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware 
from models.base import Base
from routes import auth, song
from database import engine

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"], 
)

app.include_router(auth.router, prefix="/auth")
app.include_router(song.router, prefix="/song")

Base.metadata.create_all(engine)