# backend/app/models/order.py
from sqlalchemy import Column, Integer, String, Float, DateTime, Text, JSON
from sqlalchemy.sql import func
from app.db.database import Base


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    customer_name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    address = Column(Text, nullable=True)
    comment = Column(Text, nullable=True)
    total_price = Column(Float, nullable=False, default=0.0)
    status = Column(String, default="pending")  # pending, confirmed, preparing, delivered
    items = Column(JSON, default=[])  # [{"dessert_id": 1, "name": "...", "quantity": 2, "price": 350}]
    created_at = Column(DateTime(timezone=True), server_default=func.now())
