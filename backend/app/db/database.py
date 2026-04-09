# backend/app/db/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# Читаем адрес БД из переменных окружения
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://user:pass@postgres:5432/desserts_db"
)

# Создаём движок и сессию
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Функция для получения сессии БД в эндпоинтах
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()