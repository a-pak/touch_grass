import httpx
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("TREFLE_API_KEY")

async def get_finland_plants(page: int = 1):
    api_endpoint = f"https://trefle.io/api/v1/distributions/fin/plants?page={page}&token={API_KEY}"

    async with httpx.AsyncClient() as client:
        response = await client.get(api_endpoint)

    return response.json()
