from fastapi import FastAPI
from stores.canon import canon

app = FastAPI()

@app.get("/")   
def read_root():
    return "Pulse Root"

@app.get("/canon")
def read_item(url: str):
    return canon(url)
    