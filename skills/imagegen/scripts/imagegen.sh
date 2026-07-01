#!/bin/bash
# imagegen.sh "<prompt>" [WxH] -> печатает путь PNG (gpt-image-2 via codex $imagegen)
PROMPT="$1"; SIZE="${2:-1024x1024}"
[ -z "$PROMPT" ] && { echo "usage: imagegen.sh \"prompt\" [WxH]" >&2; exit 2; }
CODEX=$(find /home/moltbot/.openclaw -path '*codex-linux-x64*bin/codex' -type f 2>/dev/null | head -1)
[ -z "$CODEX" ] && { echo "ERROR: codex бинарь не найден" >&2; exit 3; }
export CODEX_HOME=/home/moltbot/.openclaw/agents/main/agent/codex-home
WORK=/home/moltbot/clawd/tmp/imagegen; mkdir -p "$WORK"; cd "$WORK"
BEFORE=$(date +%s)
timeout 280 "$CODEX" exec --sandbox workspace-write --skip-git-repo-check \
  "\$imagegen $PROMPT. Size ${SIZE}." < /dev/null > "$WORK/last-run.log" 2>&1 || true
IMG=$(find "$CODEX_HOME/generated_images" -type f \( -iname '*.png' -o -iname '*.webp' -o -iname '*.jpg' \) -newermt "@$BEFORE" 2>/dev/null | head -1)
if [ -z "$IMG" ]; then echo "ERROR: картинка не сгенерилась. Лог: $WORK/last-run.log" >&2; tail -6 "$WORK/last-run.log" >&2; exit 1; fi
echo "$IMG"
