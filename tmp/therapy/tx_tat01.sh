#!/bin/bash
FF=/tmp/ffmpeg-7.0.2-amd64-static/ffmpeg
SRC=/home/moltbot/clawd/tmp/therapy/sessions/tatyana_real_01.m4a
WORK=/home/moltbot/clawd/tmp/therapy/sessions/chunks_tat01
OUT=/home/moltbot/clawd/tmp/therapy/tx_tat01
LOG=/home/moltbot/clawd/tmp/therapy/tat01_progress.log
mkdir -p "$WORK" "$OUT"; : > "$LOG"
KEY=$(python3 -c "import json;print(json.load(open('/home/moltbot/.openclaw/openclaw.json'))['env']['ELEVENLABS_API_KEY'])")
# low-memory segmentation via stream copy (no re-encode) -> m4a chunks
"$FF" -y -hide_banner -loglevel error -i "$SRC" -f segment -segment_time 600 -c copy "$WORK/seg_%03d.m4a" 2>>"$LOG"
echo "segments: $(ls "$WORK"/seg_*.m4a 2>/dev/null | wc -l)" >>"$LOG"
for F in "$WORK"/seg_*.m4a; do
  b=$(basename "$F" .m4a)
  o="$OUT/${b}.txt"
  [ -s "$o" ] && continue
  R=$(curl -s --max-time 400 -X POST "https://api.elevenlabs.io/v1/speech-to-text" -H "xi-api-key: $KEY" -F "model_id=scribe_v1" -F "file=@$F;type=audio/mp4")
  echo "$R" | python3 -c "import sys,json;open('$o','w').write((json.load(sys.stdin).get('text','') or ''))" 2>>"$LOG" && echo "done $b $(wc -c <"$o")b" >>"$LOG" || echo "FAIL $b" >>"$LOG"
  sleep 1
done
echo "TAT01_DONE $(ls "$OUT"/*.txt 2>/dev/null|wc -l) parts" >>"$LOG"
