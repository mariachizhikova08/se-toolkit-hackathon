# mcp/mcp-desserts/src/mcp_desserts/server.py
"""
MCP Server for Dessert Catalog — connects to real backend API.
Provides tools for AI agent to search, filter, and order desserts.
"""
import asyncio
import os
import httpx
from typing import Optional, List
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("PastelHeaven-Desserts")

# Backend API URL — from env or default
BACKEND_URL = os.getenv("BACKEND_URL", "http://backend:8000")
DESSERTS_API = f"{BACKEND_URL}/desserts"
ORDERS_API = f"{BACKEND_URL}/orders"

# In-memory cart storage (keyed by session/user — simplified for demo)
_carts: dict[str, list[dict]] = {}


def _get_cart(user: str = "default") -> list[dict]:
    return _carts.setdefault(user, [])


def _clear_cart(user: str = "default"):
    _carts.pop(user, None)


async def _fetch_desserts() -> list[dict]:
    """Fetch real dessert data from backend API."""
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            resp = await client.get(DESSERTS_API)
            if resp.status_code == 200:
                return resp.json()
        except Exception:
            pass
    # Fallback: empty list
    return []


# ─────────────────────────────────────────────
# TOOL: list_desserts
# ─────────────────────────────────────────────
@mcp.tool()
async def list_desserts() -> list[dict]:
    """Получить полный каталог всех десертов с ценами, описанием, составом и аллергенами.
    Используй, когда пользователь спрашивает "что есть?", "покажи меню", "какие десерты?".
    """
    desserts = await _fetch_desserts()
    result = []
    for d in desserts:
        result.append({
            "id": d.get("id"),
            "name": d.get("name", ""),
            "price": d.get("price", 0),
            "category": d.get("category", ""),
            "description": d.get("description", ""),
            "ingredients": d.get("ingredients", []),
            "allergens": d.get("allergens", []),
            "available": d.get("available", True),
        })
    return result


# ─────────────────────────────────────────────
# TOOL: search_desserts
# ─────────────────────────────────────────────
@mcp.tool()
async def search_desserts(query: str) -> list[dict]:
    """Поиск десертов по названию, ингредиенту или описанию.

    Args:
        query: поисковый запрос (например, "шоколад", "клубника", "тирамису")
    """
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            resp = await client.get(f"{DESSERTS_API}/search", params={"q": query})
            if resp.status_code == 200:
                data = resp.json()
                return [{"id": d.get("id"), "name": d.get("name", ""), "price": d.get("price", 0),
                         "description": d.get("description", ""), "category": d.get("category", ""),
                         "ingredients": d.get("ingredients", []), "allergens": d.get("allergens", [])}
                        for d in data]
        except Exception:
            pass

    # Fallback: client-side search
    all_desserts = await _fetch_desserts()
    q = query.lower()
    return [{"id": d.get("id"), "name": d.get("name", ""), "price": d.get("price", 0),
             "description": d.get("description", ""), "category": d.get("category", ""),
             "ingredients": d.get("ingredients", []), "allergens": d.get("allergens", [])}
            for d in all_desserts
            if q in d.get("name", "").lower()
            or q in d.get("description", "").lower()
            or any(q in ing.lower() for ing in d.get("ingredients", []))]


# ─────────────────────────────────────────────
# TOOL: filter_by_ingredient
# ─────────────────────────────────────────────
@mcp.tool()
async def filter_by_ingredient(
    include: Optional[List[str]] = None,
    exclude: Optional[List[str]] = None,
) -> list[dict]:
    """Фильтрация десертов по ингредиентам и аллергенам.

    Args:
        include: ингредиенты, которые должны быть (например, ["шоколад"])
        exclude: ингредиенты/аллергены, которых НЕ должно быть (например, ["орехи", "глютен"])
    """
    all_desserts = await _fetch_desserts()
    filtered = []
    for d in all_desserts:
        desc = (d.get("description", "") or "").lower()
        ingredients = [i.lower() for i in (d.get("ingredients") or [])]
        allergens = [a.lower() for a in (d.get("allergens") or [])]
        combined = desc + " " + " ".join(ingredients) + " " + " ".join(allergens)

        if include:
            if not any(inc.lower() in combined for inc in include):
                continue
        if exclude:
            if any(exc.lower() in combined for exc in exclude):
                continue
        filtered.append({
            "id": d.get("id"), "name": d.get("name", ""), "price": d.get("price", 0),
            "description": d.get("description", ""), "category": d.get("category", ""),
            "ingredients": d.get("ingredients", []), "allergens": d.get("allergens", []),
        })
    return filtered


# ─────────────────────────────────────────────
# TOOL: get_dessert_info
# ─────────────────────────────────────────────
@mcp.tool()
async def get_dessert_info(dessert_id: int) -> dict:
    """Получить подробную информацию о десерте по ID: состав, аллергены, цена, описание."""
    desserts = await _fetch_desserts()
    for d in desserts:
        if d.get("id") == dessert_id:
            return {
                "id": d.get("id"), "name": d.get("name", ""), "price": d.get("price", 0),
                "category": d.get("category", ""), "description": d.get("description", ""),
                "ingredients": d.get("ingredients", []), "allergens": d.get("allergens", []),
                "available": d.get("available", True),
            }
    return {"error": f"Dessert with id={dessert_id} not found"}


# ─────────────────────────────────────────────
# TOOL: get_price_info
# ─────────────────────────────────────────────
@mcp.tool()
async def get_price_info(dessert_name: str) -> dict:
    """Узнать цену десерта по названию (частичное совпадение)."""
    desserts = await _fetch_desserts()
    for d in desserts:
        if dessert_name.lower() in d.get("name", "").lower():
            return {"name": d.get("name"), "price": d.get("price"), "category": d.get("category")}
    return {"error": f"Dessert '{dessert_name}' not found"}


# ─────────────────────────────────────────────
# TOOL: get_budget_desserts
# ─────────────────────────────────────────────
@mcp.tool()
async def get_budget_desserts(max_price: float) -> list[dict]:
    """Получить десерты не дороже указанной суммы.

    Args:
        max_price: максимальная цена в рублях
    """
    desserts = await _fetch_desserts()
    return [{"id": d.get("id"), "name": d.get("name", ""), "price": d.get("price", 0),
             "description": d.get("description", ""), "category": d.get("category", "")}
            for d in desserts if d.get("price", 9999) <= max_price]


# ─────────────────────────────────────────────
# TOOL: add_to_cart
# ─────────────────────────────────────────────
@mcp.tool()
async def add_to_cart(dessert_id: int, quantity: int = 1, user: str = "default") -> dict:
    """Добавить десерт в корзину пользователя.

    Args:
        dessert_id: ID десерта из каталога
        quantity: количество (по умолчанию 1)
        user: идентификатор пользователя (для демонстрации — "default")
    """
    desserts = await _fetch_desserts()
    dessert = next((d for d in desserts if d.get("id") == dessert_id), None)
    if not dessert:
        return {"error": f"Dessert id={dessert_id} not found"}

    cart = _get_cart(user)
    # Check if already in cart
    existing = next((item for item in cart if item["dessert_id"] == dessert_id), None)
    if existing:
        existing["quantity"] += quantity
    else:
        cart.append({
            "dessert_id": dessert_id,
            "name": dessert.get("name", ""),
            "quantity": quantity,
            "price": dessert.get("price", 0),
        })

    total = sum(item["quantity"] * item["price"] for item in cart)
    return {
        "success": True,
        "message": f"Добавлено: {dessert.get('name')} × {quantity}",
        "dessert_name": dessert.get("name"),
        "quantity": quantity,
        "unit_price": dessert.get("price"),
        "cart_total": total,
        "cart_items": len(cart),
    }


# ─────────────────────────────────────────────
# TOOL: view_cart
# ─────────────────────────────────────────────
@mcp.tool()
async def view_cart(user: str = "default") -> dict:
    """Показать содержимое корзины пользователя."""
    cart = _get_cart(user)
    if not cart:
        return {"empty": True, "message": "Корзина пуста"}
    total = sum(item["quantity"] * item["price"] for item in cart)
    return {
        "empty": False,
        "items": cart,
        "total": total,
        "item_count": sum(item["quantity"] for item in cart),
    }


# ─────────────────────────────────────────────
# TOOL: clear_cart
# ─────────────────────────────────────────────
@mcp.tool()
async def clear_cart(user: str = "default") -> dict:
    """Очистить корзину пользователя."""
    _clear_cart(user)
    return {"success": True, "message": "Корзина очищена"}


# ─────────────────────────────────────────────
# TOOL: create_order
# ─────────────────────────────────────────────
@mcp.tool()
async def create_order(
    customer_name: str,
    phone: str,
    address: str,
    comment: Optional[str] = None,
    user: str = "default",
) -> dict:
    """Оформить заказ из текущей корзины пользователя.

    Args:
        customer_name: имя клиента
        phone: телефон
        address: адрес доставки
        comment: комментарий к заказу
        user: идентификатор пользователя
    """
    cart = _get_cart(user)
    if not cart:
        return {"error": "Корзина пуста. Добавьте десерты перед оформлением."}

    items = [{"dessert_id": i["dessert_id"], "name": i["name"],
              "quantity": i["quantity"], "price": i["price"]} for i in cart]

    order_data = {
        "customer_name": customer_name,
        "phone": phone,
        "address": address,
        "items": items,
    }
    if comment:
        order_data["comment"] = comment

    async with httpx.AsyncClient(timeout=15.0) as client:
        try:
            resp = await client.post(ORDERS_API, json=order_data)
            if resp.status_code in (200, 201):
                order = resp.json()
                _clear_cart(user)
                return {
                    "success": True,
                    "order_id": order.get("id"),
                    "total_price": order.get("total_price"),
                    "status": order.get("status"),
                    "message": f"✅ Заказ №{order.get('id')} принят! Сумма: {order.get('total_price')}₽",
                }
            else:
                return {"error": f"Ошибка создания заказа: {resp.text}"}
        except Exception as e:
            return {"error": f"Не удалось создать заказ: {str(e)}"}


# ─────────────────────────────────────────────
# TOOL: get_order_status
# ─────────────────────────────────────────────
@mcp.tool()
async def get_order_status(order_id: int) -> dict:
    """Получить статус заказа по номеру."""
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            resp = await client.get(f"{ORDERS_API}/{order_id}")
            if resp.status_code == 200:
                order = resp.json()
                return {
                    "order_id": order.get("id"),
                    "status": order.get("status"),
                    "total_price": order.get("total_price"),
                    "items": order.get("items", []),
                    "created_at": order.get("created_at"),
                    "address": order.get("address"),
                    "comment": order.get("comment"),
                }
            return {"error": f"Заказ №{order_id} не найден"}
        except Exception as e:
            return {"error": f"Ошибка: {str(e)}"}


def main():
    mcp.run()


if __name__ == "__main__":
    main()
