# nanobot/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Устанавливаем uv (прямая загрузка бинарника — зеркала нестабильны)
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://astral.sh/uv/install.sh | sh \
    && cp /root/.local/bin/uv /usr/local/bin/uv \
    && cp /root/.local/bin/uvx /usr/local/bin/uvx \
    && rm -rf /root/.local

# Копируем зависимости и устанавливаем пакет nanobot-desserts
COPY pyproject.toml ./
ENV UV_HTTP_TIMEOUT=300
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/
RUN uv pip install --system -e .

# Устанавливаем nanobot CLI framework с PyPI (предоставляет команду `nanobot gateway`)
RUN uv pip install --system nanobot-ai

# Копируем наш код ВНУТРЬ установленного пакета nanobot
# ВАЖНО: НЕ перезаписываем __init__.py (там __logo__ и __version__ от nanobot-ai)
COPY config_loader.py /usr/local/lib/python3.11/site-packages/nanobot/
COPY entrypoint.py /usr/local/lib/python3.11/site-packages/nanobot/
COPY dessert_schema.py /usr/local/lib/python3.11/site-packages/nanobot/
COPY workspace/ /app/workspace/

# Запускаем агента
CMD ["python", "-m", "nanobot.entrypoint"]
