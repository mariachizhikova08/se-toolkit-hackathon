# mcp/mcp-desserts/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Устанавливаем uv с официального PyPI (зеркало ломает хеш)
RUN pip install --no-cache-dir --index-url https://pypi.org/simple/ uv

# Копируем зависимости
COPY pyproject.toml ./
ENV UV_HTTP_TIMEOUT=300
RUN uv pip install --system -e .

# Копируем код
COPY src/ ./src/

# Reinstall after copying src/ so the editable install includes the package
RUN uv pip install --system -e .

# Запускаем MCP-сервер
CMD ["python", "-m", "mcp_desserts.server"]