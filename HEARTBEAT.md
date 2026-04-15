# HEARTBEAT.md

## Каждый heartbeat (лёгкий, каждый час)

- Обновить memory/YYYY-MM-DD.md если есть что записать
- Обновить CONTEXT.md если контекст изменился
- Если есть срочное — сообщить

Тяжёлые задачи вынесены в cron'ы:
- **Evening Reflection** (22:00 UTC, Sonnet) — structured questions, session-log, assumptions, observations, MEMORY.md distill, git commit
- **Auto Commit** (каждые 6ч, GLM) — git add/commit/push uncommitted
- **OpenClaw Version Check** (12:00 UTC, GLM) — сравнение версий, алерт при обновлении
- **Memory Dreaming** (03:00 UTC, Opus) — memory-core plugin, short-term → MEMORY.md
