# backend/app/models/dessert.py
from sqlalchemy import Column, Integer, String, Float, Boolean, JSON
from app.db.database import Base

class Dessert(Base):
    __tablename__ = "desserts"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    description = Column(String, default="")
    price = Column(Float, nullable=False)
    category = Column(String, default="other")               # cake, cheesecake, bakery, portion, dessert
    ingredients = Column(JSON, default=[])
    allergens = Column(JSON, default=[])
    available = Column(Boolean, default=True)
    image_url = Column(String, nullable=True)