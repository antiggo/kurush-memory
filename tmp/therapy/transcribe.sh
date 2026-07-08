#!/bin/bash
DIR=/home/moltbot/.openclaw/media/inbound
OUT=/home/moltbot/clawd/tmp/therapy/tx
KEY=$(python3 -c "import json;print(json.load(open('/home/moltbot/.openclaw/openclaw.json'))['env']['ELEVENLABS_API_KEY'])")
LOG=/home/moltbot/clawd/tmp/therapy/progress.log
: > "$LOG"
one() {
  local F="$1" base num out
  base=$(basename "$F")
  num=$(echo "$base" | grep -oE 'file_[0-9]+' )
  out="$OUT/${num}.txt"
  [ -s "$out" ] && { echo "skip $num" >>"$LOG"; return; }
  local R
  R=$(curl -s --max-time 300 -X POST "https://api.elevenlabs.io/v1/speech-to-text" \
      -H "xi-api-key: $KEY" -F "model_id=scribe_v1" -F "file=@$F;type=audio/ogg")
  echo "$R" | python3 -c "import sys,json;d=json.load(sys.stdin);open('$out','w').write(d.get('text','') or '')" 2>>"$LOG" \
     && echo "done $num $(wc -c <"$out")b" >>"$LOG" || echo "FAIL $num" >>"$LOG"
}
export -f one; export OUT KEY LOG
ls "$DIR"/file_*---*.ogg | sort > /home/moltbot/clawd/tmp/therapy/filelist.txt
cat /home/moltbot/clawd/tmp/therapy/filelist.txt | xargs -P4 -I{} bash -c 'one "$@"' _ {}
echo "ALL_DONE $(ls "$OUT"/*.txt 2>/dev/null | wc -l) files" >>"$LOG"
