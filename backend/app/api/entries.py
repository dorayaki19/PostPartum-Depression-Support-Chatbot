from fastapi import APIRouter
from pydantic import BaseModel
from app.models import store
from app.nlp.predictor import predict

router = APIRouter()


class Entry(BaseModel):
    date: str
    text: str


@router.post("/")
def create_entry(entry: Entry):

    analysis = predict(entry.text)

    saved = store.save_entry(entry.date, entry.text, analysis)

    return saved


@router.get("/")
def list_entries():
    return store.get_all()
