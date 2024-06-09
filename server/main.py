from fastapi import FastAPI, HTTPException
from stores.canon import canon
from pydantic import BaseModel
from typing import List

app = FastAPI()

@app.get("/")   
def read_root():
    return "Pulse Root"

@app.get("/canon")
def read_item(url: str):
    try:
        return canon(url)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
class Urls(BaseModel):
    urls: List[str]

@app.post("/canon/multiple")
def read_items(item: Urls):
    try:
        return [canon(url) for url in item.urls]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))