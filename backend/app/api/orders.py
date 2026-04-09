# backend/app/api/orders.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from app.db.database import SessionLocal
from app.models.order import Order

router = APIRouter(prefix="/orders", tags=["Orders"])


class OrderItemCreate(BaseModel):
    dessert_id: int
    name: str
    quantity: int = 1
    price: float


class OrderCreate(BaseModel):
    customer_name: str
    phone: str
    address: Optional[str] = None
    comment: Optional[str] = None
    items: List[OrderItemCreate]


class OrderItemOut(BaseModel):
    dessert_id: int
    name: str
    quantity: int
    price: float


class OrderOut(BaseModel):
    id: int
    customer_name: str
    phone: str
    comment: Optional[str] = None
    total_price: float
    status: str
    items: List[OrderItemOut]
    created_at: str

    class Config:
        from_attributes = True


@router.post("/", status_code=201)
def create_order(order: OrderCreate):
    db = SessionLocal()
    try:
        items_data = [
            {
                "dessert_id": item.dessert_id,
                "name": item.name,
                "quantity": item.quantity,
                "price": item.price,
            }
            for item in order.items
        ]
        total = sum(item.quantity * item.price for item in order.items)

        db_order = Order(
            customer_name=order.customer_name,
            phone=order.phone,
            address=order.address,
            comment=order.comment,
            total_price=total,
            items=items_data,
            status="pending",
        )
        db.add(db_order)
        db.commit()
        db.refresh(db_order)

        return {
            "id": db_order.id,
            "customer_name": db_order.customer_name,
            "phone": db_order.phone,
            "address": db_order.address,
            "comment": db_order.comment,
            "total_price": db_order.total_price,
            "status": db_order.status,
            "items": db_order.items,
            "created_at": str(db_order.created_at),
        }
    finally:
        db.close()


@router.get("/")
def list_orders():
    db = SessionLocal()
    try:
        orders = db.query(Order).order_by(Order.created_at.desc()).all()
        result = []
        for o in orders:
            result.append({
                "id": o.id,
                "customer_name": o.customer_name,
                "phone": o.phone,
                "address": o.address,
                "comment": o.comment,
                "total_price": o.total_price,
                "status": o.status,
                "items": o.items,
                "created_at": str(o.created_at),
            })
        return result
    finally:
        db.close()


@router.get("/{order_id}")
def get_order(order_id: int):
    db = SessionLocal()
    try:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        return {
            "id": order.id,
            "customer_name": order.customer_name,
            "phone": order.phone,
            "address": order.address,
            "comment": order.comment,
            "total_price": order.total_price,
            "status": order.status,
            "items": order.items,
            "created_at": str(order.created_at),
        }
    finally:
        db.close()
