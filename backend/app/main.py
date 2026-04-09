# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db.database import engine, Base
from app.api.desserts import router as desserts_router
from app.api.orders import router as orders_router

# Создаём таблицы в БД при первом запуске
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Dessert Catalog API")

# CORS — разрешаем запросы от Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключаем роутеры (эндпоинты)
app.include_router(desserts_router)
app.include_router(orders_router)

# Простая проверка, что сервер жив
@app.get("/")
def root():
    return {"status": "ok", "message": "Dessert API is running"}