# Project Plan: se-hackathon-desserts

## Goal
Deliver a working dessert catalog with LLM-powered ordering assistant in 2 days.

---

## Version 1 (MVP Core) — Day 1
Estimated total time: 6-8 hours

- Setup repository, clone, configure environment variables (30 min)
- Backend: create Dessert model and basic endpoints /desserts, /search (2-3 hours)
- MCP server: implement list_desserts and create_order tools (1.5-2 hours)
- Agent skill: write SKILL.md and test basic chat flow (30-45 min)
- Docker: compose backend + postgres, test local launch (1 hour)
- Prepare V1 demo: screenshots, quick test script (30 min)

V1 is done when: agent can show dessert list and accept a simple order via chat.

---

## Version 2 (Polish + Deploy) — Day 2
Estimated total time: 5-7 hours

- Add rich UI cards with images and buttons using mcp_webchat_ui_message (1.5-2 hours)
- Implement allergen filter and suggestion chips (1 hour)
- Add order confirmation with ID and simple status endpoint (1 hour)
- Fill REPORT.md with descriptions and screenshots (1 hour)
- Deploy to university VM, test public link (1-2 hours)
- Final checks: README polish, submit form (30-45 min)

V2 is done when: project is deployed, accessible via link, and report is submitted.

---

## Pre-submission Checklist
- [ ] docker compose up --build runs without errors
- [ ] Agent responds to "what's available?" and "I want to order"
- [ ] Chat displays cards with images and buttons (V2)
- [ ] REPORT.md is filled, includes screenshots
- [ ] Demo link works in incognito mode
- [ ] Repository is public, no secrets committed

---

## Notes / Troubleshooting
- If MCP tools not visible: check nanobot/config.json and run uv sync in mcp-desserts/
- If backend can't connect to DB: verify DATABASE_URL in .env.docker.secret
- If Flutter client shows blank page: check Caddy logs and WebSocket connection
