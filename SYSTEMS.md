# SYSTEMS.md

## Openclaw billing-backoff quirk [2026-05-08, fixed]

Если получаю «out of extra usage» / billing error от Anthropic — **это НЕ значит что у Андрея кончилась Max-подписка**. Real API rejections — редкость, типично на heavy opus calls с long context (anti-abuse classifier на стороне Anthropic, не quota wall).

Openclaw классифицирует это как `reason=billing` и ставит провайдера в **disabled** state. Раньше дефолт был 5 часов hard-kill после одного rejection — все следующие cron'ы и user-сообщения возвращали «provider has billing issue» из кеша auth-state.json. Куруш попадал в эту яму один раз (4 мая 2026) — после Кая-разговора followup agents triggered wall, openclaw cached "billing issue" на 5h пока Max реально recovered.

**Fix применён 2026-05-08** во всех 3 ботах: `auth.cooldowns.billingBackoffHours: 0.0833` (5 min), `billingMaxHours: 0.25` (15 min cap) в `~/.openclaw/openclaw.json`. Теперь transient rejection → 5 минут retry window → авто-восстановление.

**Если Андрей опять пишет «бот не отвечает / billing error»:**
1. `journalctl --user -u openclaw-gateway.service --since "today" | grep "rawError=400.*out of extra"` — посчитать **реальные** API rejections (не «billing» строки — те cached cooldown decisions)
2. Если real count < 5/day — это openclaw overcooking, не quota. Подтвердить Андрею что Max-квота ОК.
3. `cat ~/.openclaw/agents/main/agent/auth-state.json` — если есть `disabledUntil` в будущем, вычистить через `~/bin/openclaw-cooldown-cleanup.sh` (запускается также автоматически каждые 30 min)
4. Restart `systemctl --user restart openclaw-gateway.service` если нужно немедленно

Backups конфига: `~/.openclaw/openclaw.json.bak-*-pre-cooldown`.
