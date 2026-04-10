# mcp/mcp-desserts/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Устанавливаем uv официальным установщиком
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
ENV PATH="/root/.local/bin:/root/.cargo/bin:${PATH}"

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