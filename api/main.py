# TODO: tiedosto on aika suuri, voisi luoda services/login.py jonne laittaa logiikkaa yms. 

from datetime import date, datetime, timedelta, timezone
from typing import Literal

import bcrypt
import jwt
from fastapi import Depends, FastAPI, File, HTTPException, Query, UploadFile
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field
from pymongo import ASCENDING, DESCENDING, MongoClient
from pymongo.collection import Collection
from pymongo.errors import DuplicateKeyError
from services.plantnet import identify_plant
from services.trefle import get_finland_plants
from dotenv import load_dotenv
import os

load_dotenv()

API_KEY = os.getenv("PLANTNET_API_KEY")
MONGODB_URI = os.getenv("MONGODB_URI")
MONGODB_DB_NAME = os.getenv("MONGODB_DB", "touch_grass")
JWT_SECRET = os.getenv("JWT_SECRET", "dev-only-change-this-secret")
JWT_ALGORITHM = "HS256"
JWT_EXPIRES_DAYS = 7

if not MONGODB_URI:
    raise RuntimeError("MONGODB_URI is required")

mongo_client = MongoClient(MONGODB_URI)
db = mongo_client[MONGODB_DB_NAME]
users_collection: Collection = db["users"]

security = HTTPBearer()


class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=32, pattern=r"^[a-zA-Z0-9_]+$")
    password: str = Field(min_length=8, max_length=32)


class LoginRequest(BaseModel):
    username: str
    password: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    username: str
    daily_streak: int
    total_recognitions: int


class RecognitionIncrementRequest(BaseModel):
    amount: int = Field(default=1, ge=1, le=100)


class RecognitionIncrementResponse(BaseModel):
    username: str
    daily_streak: int
    total_recognitions: int
    last_recognition_date: str


class StreakResetResponse(BaseModel):
    username: str
    daily_streak: int
    total_recognitions: int
    last_recognition_date: str | None


def normalize_username(username: str) -> str:
    return username.strip().lower()


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))


def create_access_token(username: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": username,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(days=JWT_EXPIRES_DAYS)).timestamp()),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def get_current_username(credentials: HTTPAuthorizationCredentials) -> str:
    token = credentials.credentials
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.InvalidTokenError as exc:
        raise HTTPException(status_code=401, detail="Invalid or expired token") from exc

    username = payload.get("sub")
    if not username or not isinstance(username, str):
        raise HTTPException(status_code=401, detail="Invalid token payload")

    return username

app = FastAPI()


@app.on_event("startup")
def startup() -> None:
    users_collection.create_index([("username", ASCENDING)], unique=True)

@app.get("/")
def root():
    return {"status": "ok"}

@app.post("/test-upload")
async def test_upload(file: UploadFile = File(...)):
    return {"filename": file.filename}

@app.post("/detect")
async def detect(image: UploadFile = File(...)):
    image_bytes = await image.read()
    result = await identify_plant(image_bytes)

    return result


@app.post("/register", response_model=AuthResponse)
def register(payload: RegisterRequest):
    username = normalize_username(payload.username)

    user_doc = {
        "username": username,
        "password_hash": hash_password(payload.password),
        "daily_streak": 0,
        "total_recognitions": 0,
        "last_recognition_date": None,
        "created_at": datetime.now(timezone.utc),
    }

    try:
        users_collection.insert_one(user_doc)
    except DuplicateKeyError as exc:
        raise HTTPException(status_code=409, detail="Username already exists") from exc

    token = create_access_token(username)

    return AuthResponse(
        access_token=token,
        username=username,
        daily_streak=0,
        total_recognitions=0,
    )


@app.post("/login", response_model=AuthResponse)
def login(payload: LoginRequest):
    username = normalize_username(payload.username)
    user = users_collection.find_one({"username": username})

    if not user:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    if not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    token = create_access_token(username)

    return AuthResponse(
        access_token=token,
        username=username,
        daily_streak=user.get("daily_streak", 0),
        total_recognitions=user.get("total_recognitions", 0),
    )


@app.post("/recognitions/increment", response_model=RecognitionIncrementResponse)
def increment_recognitions(
    payload: RecognitionIncrementRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    username = get_current_username(credentials)
    user = users_collection.find_one({"username": username})

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    today = date.today()
    last_date_raw = user.get("last_recognition_date")
    last_date = date.fromisoformat(last_date_raw) if isinstance(last_date_raw, str) else None

    current_streak = int(user.get("daily_streak", 0))
    if last_date is None:
        new_streak = 1
        new_last_date = today
    elif last_date == today:
        new_streak = current_streak
        new_last_date = last_date
    elif last_date == (today - timedelta(days=1)):
        new_streak = current_streak + 1
        new_last_date = today
    else:
        new_streak = 1
        new_last_date = today

    new_total = int(user.get("total_recognitions", 0)) + payload.amount

    users_collection.update_one(
        {"username": username},
        {
            "$set": {
                "daily_streak": new_streak,
                "total_recognitions": new_total,
                "last_recognition_date": new_last_date.isoformat(),
            }
        },
    )

    return RecognitionIncrementResponse(
        username=username,
        daily_streak=new_streak,
        total_recognitions=new_total,
        last_recognition_date=new_last_date.isoformat(),
    )


@app.post("/streak/reset", response_model=StreakResetResponse)
def reset_streak(credentials: HTTPAuthorizationCredentials = Depends(security)):
    username = get_current_username(credentials)
    user = users_collection.find_one({"username": username})

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    users_collection.update_one(
        {"username": username},
        {"$set": {"daily_streak": 0}},
    )

    return StreakResetResponse(
        username=username,
        daily_streak=0,
        total_recognitions=int(user.get("total_recognitions", 0)),
        last_recognition_date=user.get("last_recognition_date"),
    )


@app.get("/leaderboard")
def leaderboard(
    limit: int = Query(default=50, ge=1, le=100),
    sort_by: Literal["total_recognitions", "daily_streak"] = "total_recognitions",
):
    cursor = (
        users_collection.find(
            {},
            {
                "_id": 0,
                "username": 1,
                "daily_streak": 1,
                "total_recognitions": 1,
                "last_recognition_date": 1,
            },
        )
        .sort(sort_by, DESCENDING)
        .limit(limit)
    )

    return {"items": list(cursor)}

@app.get("/plants")
async def plants(page: int = Query(default=1, ge=1)):
    return await get_finland_plants(page)