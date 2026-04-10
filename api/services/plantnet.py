import httpx
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("PLANTNET_API_KEY")

async def identify_plant(image_bytes):
    url = "https://my-api.plantnet.org/v2/identify/all"
    PROJECT = "all"; # You can choose a more specific flora, see: /docs/newfloras
    api_endpoint = f"https://my-api.plantnet.org/v2/identify/{PROJECT}?api-key={API_KEY}"

    print('api_endpoint:', api_endpoint)

    files = {
        "images": ("image.jpg", image_bytes, "image/jpeg")
    }

    params = {"api-key": API_KEY}

    async with httpx.AsyncClient() as client:
        response = await client.post(api_endpoint, files=files)

    return response.json()