# backend/Dockerfile
FROM python:3.11-slim

RUN pip config set global.timeout 100 && \
    pip config set global.retries 5

WORKDIR /app

# Копируем зависимости и устанавливаем их
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код
COPY . .

# Запускаем сервер
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]