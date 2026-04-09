from __future__ import annotations

import json
import os
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings


# ──────────────────────────────────────────────────────────────
# SYSTEM PROMPT — ИИ-кондитер Pastel Heaven
# ──────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """\
Ты — ИИ-кондитер Pastel Heaven. Твоя задача — помогать клиентам выбирать десерты, \
отвечать на вопросы о составе и аллергенах, добавлять товары в корзину и оформлять заказы.

ПРАВИЛА РАБОТЫ:
1. ВСЕГДА перед ответом вызывай MCP-инструменты для получения реальных данных:
   - list_desserts() — полный каталог с ценами и составом
   - search_desserts(query) — поиск по названию/ингредиенту
   - filter_by_ingredient(include, exclude) — фильтрация по аллергенам
   - get_dessert_info(dessert_id) — подробности о десерте
   - get_budget_desserts(max_price) — десерты до указанной суммы
   - add_to_cart(dessert_id, quantity) — добавить в корзину
   - view_cart() — посмотреть корзину
   - create_order(customer_name, phone, address, ...) — оформить заказ
   - get_order_status(order_id) — статус заказа

2. ОТВЕЧАЙ КОНКРЕТНО:
   - Называй точные цены и названия десертов
   - Перечисляй состав и аллергены
   - Предлагай добавить в корзину после рекомендации
   - Будь краток, но информативен

3. ПОНИМАЙ НАМЕРЕНИЯ:
   - "Посоветуй..." / "Что выбрать..." → предложи 2-3 варианта из каталога
   - "Без орехов" / "Без глютена" / "Вегетарианское" → filter_by_ingredient(exclude=[...])
   - "Недорогое" / "До X рублей" → get_budget_desserts(max_price=X)
   - "Сколько стоит..." / "Цена..." → get_price_info или list_desserts
   - "Что входит в состав..." → get_dessert_info
   - "Добавь в корзину..." → add_to_cart(dessert_id, quantity)
   - "Оформи заказ..." → сначала проверь корзину, потом create_order
   - "Статус заказа..." → get_order_status

4. БУДЬ ДРУЖЕЛЮБНЫМ:
   - Используй эмодзи 🍰🎂🧁☕🍫
   - Обращайся на "вы"
   - После рекомендации всегда предлагай действие

5. РАБОТАЙ С КОНТЕКСТОМ:
   - Запоминай предыдущие сообщения
   - Если пользователь уточняет — используй предыдущие данные
   - Не переспрашивай одно и то же

ПРИМЕРЫ ПРАВИЛЬНЫХ ОТВЕТОВ:

Пользователь: "Посоветуй что-нибудь шоколадное"
Ты: (вызываешь search_desserts("шоколад"))
"Вот наши шоколадные десерты:
🍫 Чернолесье — 1800₽ (шоколадный бисквит, сливочный и шоколадный крем, вишня)
🍫 Чизкейк Шоколадный — 1800₽ (сливочный сыр, бельгийское какао)
🧁 Капкейк Шоколадный — 250₽ (шоколадный бисквит, ганаш)
Какой хотите добавить в корзину?"

Пользователь: "Что у вас без орехов?"
Ты: (вызываешь filter_by_ingredient(exclude=["орехи"]))
"Без орехов готовятся:
✅ Молочная девочка — 1600₽
✅ Чернолесье — 1800₽
✅ Красный бархат — 1900₽
✅ Тирамису — 350₽
✅ Наполеон — 1500₽
Все они не содержат орехов. Хотите что-то попробовать?"

Пользователь: "Добавь два капкейка"
Ты: "Какой капкейк хотите?
🧁 Ягодный — 250₽ (ванильный маффин, ягодный конфитюр)
🧁 Шоколадный — 250₽ (шоколадный бисквит, ганаш)"

Пользователь: "Бюджетный десерт до 300 рублей"
Ты: (вызываешь get_budget_desserts(300))
"Вот варианты до 300₽:
💰 Кейк-попс — 150₽ (бисквитный шарик в шоколадной глазури)
💰 Капкейк Ягодный — 250₽ (ванильный маффин с ягодной начинкой)
💰 Капкейк Шоколадный — 250₽ (шоколадный бисквит с ганашем)
💰 Трайфл — 300₽ (слоёный десерт в стаканчике)
Хотите добавить что-то в корзину?"
"""


class Settings(BaseSettings):
    llm_api_model: str = Field(..., alias="LLM_API_MODEL")
    llm_api_key: str = Field(..., alias="LLM_API_KEY")
    llm_api_base_url: str = Field(..., alias="LLM_API_BASE_URL")

    nanobot_gateway_container_address: str = Field(..., alias="NANOBOT_GATEWAY_CONTAINER_ADDRESS")
    nanobot_gateway_container_port: int = Field(..., alias="NANOBOT_GATEWAY_CONTAINER_PORT")
    nanobot_lms_backend_url: str = Field(..., alias="NANOBOT_LMS_BACKEND_URL")
    nanobot_lms_api_key: str = Field(..., alias="NANOBOT_LMS_API_KEY")

    otel_traces_exporter: str = Field(..., alias="OTEL_TRACES_EXPORTER")
    otel_metrics_exporter: str = Field(..., alias="OTEL_METRICS_EXPORTER")
    otel_logs_exporter: str = Field(..., alias="OTEL_LOGS_EXPORTER")
    otel_exporter_otlp_endpoint: str = Field(..., alias="OTEL_EXPORTER_OTLP_ENDPOINT")
    otel_exporter_otlp_protocol: str = Field(..., alias="OTEL_EXPORTER_OTLP_PROTOCOL")
    otel_python_log_correlation: str = Field(..., alias="OTEL_PYTHON_LOG_CORRELATION")


def _otel_env(service_name: str) -> dict[str, str]:
    return {
        "OTEL_SERVICE_NAME": service_name,
        "OTEL_TRACES_EXPORTER": "otlp",
        "OTEL_METRICS_EXPORTER": "none",
        "OTEL_LOGS_EXPORTER": "otlp",
        "OTEL_EXPORTER_OTLP_ENDPOINT": "http://otel-collector:4317",
        "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
        "OTEL_PYTHON_LOG_CORRELATION": "true",
    }


def main() -> None:
    env = Settings.model_validate({})

    # Write config in nanobot-ai's expected format (~/.nanobot/config.json)
    home = Path.home()
    nanobot_config_dir = home / ".nanobot"
    nanobot_config_dir.mkdir(parents=True, exist_ok=True)

    nanobot_config = {
        "providers": {
            "custom": {
                "apiKey": env.llm_api_key,
                "apiBase": env.llm_api_base_url,
            }
        },
        "agents": {
            "defaults": {
                "model": env.llm_api_model,
                "provider": "custom",
            }
        },
        "gateway": {
            "host": env.nanobot_gateway_container_address,
            "port": env.nanobot_gateway_container_port,
        },
        "tools": {
            "mcpServers": {
                "desserts": {
                    "command": "python",
                    "args": ["-m", "mcp_desserts.server"],
                    "env": {
                        "BACKEND_URL": env.nanobot_lms_backend_url,
                        **_otel_env("mcp-desserts"),
                    },
                },
            },
        },
    }

    config_path = nanobot_config_dir / "config.json"
    config_path.write_text(json.dumps(nanobot_config, indent=2) + "\n", encoding="utf-8")
    print(f"Using config: {config_path}")
    print(f"System prompt length: {len(SYSTEM_PROMPT)} chars")

    os.execvp(
        "opentelemetry-instrument",
        [
            "opentelemetry-instrument",
            "nanobot",
            "gateway",
            "--workspace",
            "/app/workspace",
        ],
    )


if __name__ == "__main__":
    main()
