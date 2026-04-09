# backend/app/api/desserts.py
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import String
from app.db.database import get_db
from app.models.dessert import Dessert

router = APIRouter(prefix="/desserts", tags=["desserts"])

@router.get("/")
def list_desserts(
    available_only: bool = True,
    db: Session = Depends(get_db)
):
    """Вернуть список десертов"""
    query = db.query(Dessert)
    if available_only:
        query = query.filter(Dessert.available == True)
    return query.all()

@router.get("/search")
def search_desserts(
    q: str = Query(..., min_length=1),
    db: Session = Depends(get_db)
):
    """Поиск по названию или ингредиенту"""
    pattern = f"%{q}%"
    all_desserts = db.query(Dessert).all()
    results = []
    for d in all_desserts:
        name_match = q.lower() in (d.name or "").lower()
        desc_match = q.lower() in (d.description or "").lower()
        ing_match = any(q.lower() in (ing or "").lower() for ing in (d.ingredients or []))
        if name_match or desc_match or ing_match:
            results.append(d)
    return results