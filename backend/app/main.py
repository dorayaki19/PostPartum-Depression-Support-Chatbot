from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.entries import router as entries_router

app = FastAPI(title="PPD Diary API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(entries_router, prefix="/api/entries")


@app.get("/")
def root():
    return {"status": "running"}


@app.get("/health")
def health():
    return {"status": "ok"}
