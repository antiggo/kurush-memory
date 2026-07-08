#!/bin/bash
FF=/tmp/ffmpeg-7.0.2-amd64-static/ffmpeg
SRC=/home/moltbot/clawd/tmp/therapy/sessions/session_20260514.m4a
WORK=/home/moltbot/clawd/tmp/therapy/sessions/chunks_20260514
OUT=/home/moltbot/clawd/tmp/therapy/tx_sessions
LOG=/home/moltbot/clawd/tmp/therapy/session_progress.log
mkdir -p "$WORK" "$OUT"; : > "$LOG"
KEY=$(python3 -c "import json;print(json.load(open('/home/moltbot/.openclaw/openclaw.json'))['env']['ELEVENLABS_API_KEY'])")
# split into 600s ogg chunks
"$FF" -hide_banner -loglevel error -i "$SRC" -f segment -segment_time 600 -c:a libopus -b:a 32k "$WORK/part_%03d.ogg" 2>>"$LOG"
echo "chunks: $(ls "$WORK"/part_*.ogg | wc -l)" >>"$LOG"
for F in "$WORK"/part_*.ogg; do
  b=$(basename "$F" .ogg)
  o="$OUT/session20260514_${b}.txt"
  [ -s "$o" ] && continue
  R=$(curl -s --max-time 300 -X POST "https://api.elevenlabs.io/v1/speech-to-text" -H "xi-api-key: $KEY" -F "model_id=scribe_v1" -F "file=@$F;type=audio/ogg")
  echo "$R" | python3 -c "import sys,json;open('$o','w').write((json.load(sys.stdin).get('text','') or ''))" 2>>"$LOG" && echo "done $b $(wc -c <"$o")b" >>"$LOG" || echo "FAIL $b" >>"$LOG"
done
echo "SESSION_DONE" >>"$LOG"
