# hackathon-desserts — Отчёт о проекте

## 🎯 Цель проекта
Интерактивный каталог десертов с ИИ-кондитером на базе LLM (Mistral API). Пользователь может просматривать каталог, фильтровать по категориям, общаться с ИИ-агентом для подбора десертов и оформлять заказы.

## 🏗 Архитектура

```
┌─────────────┐     ┌──────────┐     ┌──────────────┐
│ Flutter Web │────▶│ Backend  │────▶│  PostgreSQL  │
│  :42002     │     │  :8000   │     │    :5432     │
└──────┬──────┘     └──────────┘     └──────────────┘
       │
       ▼
┌─────────────┐     ┌──────────┐
│   Nanobot   │────▶│ MCP Srv  │
│  (Mistral)  │     │ desserts │
└─────────────┘     └──────────┘
```

### Сервисы (Docker Compose)

| Сервис | Технология | Порт | Назначение |
|--------|-----------|------|------------|
| **postgres** | PostgreSQL 15 | 5432 | База данных (десерты, заказы) |
| **backend** | FastAPI (Python) | 8000 | REST API: /desserts/, /desserts/search, /orders/ |
| **mcp-desserts** | MCP Server (Python) | — | MCP-инструменты для ИИ-агента (12 инструментов) |
| **nanobot** | nanobot-ai + Mistral | 18790 | ИИ-кондитер с контекстными ответами |
| **flutter-web** | Flutter Web + Nginx | 42002 | Клиентское приложение (каталог, корзина, чат) |
| **qwen-code-api** | FastAPI прокси | 42005 | Прокси к LLM API (резерв) |

## ✅ Реализованный функционал

### V1 — MVP Core
- ✅ Модель Dessert (id, name, description, price, category, ingredients, allergens, available)
- ✅ Модель Order (id, customer_name, phone, address, comment, total_price, status, items, created_at)
- ✅ API endpoint GET /desserts/ — список всех десертов
- ✅ API endpoint GET /desserts/search?q=... — поиск по названию/ингредиентам
- ✅ API endpoint POST /orders/ — создание заказа
- ✅ API endpoint GET /orders/ — список заказов
- ✅ API endpoint GET /orders/{id} — статус заказа
- ✅ MCP-сервер: list_desserts, search_desserts, filter_by_ingredient, get_dessert_info, get_budget_desserts, add_to_cart, view_cart, clear_cart, create_order, get_order_status, get_price_info
- ✅ ИИ-агент: распознавание намерений, ответы с реальными данными из каталога
- ✅ Docker Compose: все 6 сервисов запускаются одной командой
- ✅ Seed-скрипт: 13 десертов с категориями

### V2 — Polish
- ✅ Rich UI: карточки с реальными фото (13 изображений)
- ✅ Фильтрация по категориям (Торты, Чизкейки, Выпечка, Порции, Десерты)
- ✅ Поиск по названию и ингредиентам
- ✅ Корзина с подсчётом суммы
- ✅ Форма заказа с адресом доставки
- ✅ Экран "Мои заказы" со статусами
- ✅ Чат с ИИ-кондитером (интеллектуальные ответы)
- ✅ Адаптивный дизайн (desktop 4 колонки → mobile 2)
- ✅ Анимации (flutter_animate)
- ✅ Бренд "Katrin's Cakes"

## 🎨 Дизайн

- **Цветовая палитра:** #FFF5F5 (кремовый), #FFB6C1 (розовый), #8B4513 (шоколадный)
- **Шрифты:** Playfair Display (заголовки), Poppins (текст), GreatVibes (логотип)
- **Hero-баннер:** "Katrin's Cakes" с градиентом
- **Карточки:** фото + название + описание + категория + цена + кнопка "В корзину"
- **FAB:** кнопка ИИ-кондитера (72×72)

## 🧪 Тестирование

### API
```bash
# Получить все десерты
curl http://localhost:8000/desserts/

# Поиск
curl "http://localhost:8000/desserts/search?q=шоколад"

# Создать заказ
curl -X POST http://localhost:8000/orders/ \
  -H "Content-Type: application/json" \
  -d '{"customer_name":"Test","phone":"+79990001122","address":"ул. Тестовая, 1","items":[{"dessert_id":1,"quantity":2}]}'
```

### UI
- Откройте http://localhost:42002
- Проверьте каталог, поиск, корзину, чат, оформление заказа

## 🚀 Запуск

```bash
docker compose --env-file .env.docker.secret up --build -d
```

## 📁 Структура

```
hackathon-desserts/
├── docker-compose.yml
├── .env.docker.secret
├── seed_desserts.sql
├── backend/app/          # FastAPI backend
│   ├── models/           # SQLAlchemy модели
│   └── api/              # Роутеры
├── client/               # Flutter Web клиент
│   ├── lib/
│   │   ├── screens/      # Экраны (home, chat, cart, orders)
│   │   ├── widgets/      # Виджеты (cards, hero, search)
│   │   ├── services/     # Сервисы (API, chat, cart)
│   │   ├── models/       # Модели данных
│   │   └── config/       # Константы, маппинг изображений
│   └── assets/images/    # 13 фото десертов
├── mcp/mcp-desserts/     # MCP-сервер
├── nanobot/              # ИИ-агент
└── qwen-code-api/        # LLM прокси
```

## 🔒 Безопасность
- .env.docker.secret не коммитится в git (.gitignore)
- CORS настроен для разработки
- API ключи хранятся только в .env.docker.secret
