from fastapi import FastAPI, UploadFile, File, Query
from services.plantnet import identify_plant
from services.trefle import get_finland_plants
from dotenv import load_dotenv
import os

load_dotenv()

API_KEY = os.getenv("PLANTNET_API_KEY")

app = FastAPI()

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

@app.get("/plants")
async def plants(page: int = Query(default=1, ge=1)):
    return await get_finland_plants(page)