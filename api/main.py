from fastapi import FastAPI, UploadFile, File
from services.plantnet import identify_plant
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