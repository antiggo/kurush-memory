#!/usr/bin/env python3
# gen-progress.py <chat_id> "<prompt>" [WxH]
# gpt-image-2 с прогресс-баром (▰▱ + % + спиннер). Один вызов: бар → генерация → фото.
import sys, re, json, time, subprocess, os, urllib.request, urllib.parse, mimetypes, uuid
CHAT = sys.argv[1]; PROMPT = sys.argv[2]; SIZE = sys.argv[3] if len(sys.argv) > 3 else "1024x1024"
TOK = re.search(r"[0-9]{8,10}:[A-Za-z0-9_-]{30,}", open("/home/moltbot/.openclaw/openclaw.json").read()).group(0)
API = "https://api.telegram.org/bot" + TOK + "/"
SPIN = "◐◓◑◒"
def call(m, p):
    try: return json.load(urllib.request.urlopen(API+m, urllib.parse.urlencode(p).encode(), timeout=25))
    except Exception as e: return {"ok": False, "error": str(e)}
def send_photo(chat, path, caption):
    b = "----prog" + uuid.uuid4().hex
    def fld(n, v): return ("--"+b+"\r\nContent-Disposition: form-data; name=\""+n+"\"\r\n\r\n"+v+"\r\n").encode()
    fn = path.split("/")[-1]; ct = mimetypes.guess_type(path)[0] or "image/png"
    fh = ("--"+b+"\r\nContent-Disposition: form-data; name=\"photo\"; filename=\""+fn+"\"\r\nContent-Type: "+ct+"\r\n\r\n").encode()
    body = fld("chat_id", chat) + fld("caption", caption) + fh + open(path, "rb").read() + b"\r\n" + ("--"+b+"--\r\n").encode()
    req = urllib.request.Request(API+"sendPhoto", data=body, headers={"Content-Type": "multipart/form-data; boundary="+b})
    try: return json.load(urllib.request.urlopen(req, timeout=120))
    except Exception as e: return {"ok": False, "error": str(e)}
def bar(el, expected=120, cells=12):
    pct = min(0.95, el/float(expected)); f = int(round(pct*cells))
    return "▰"*f + "▱"*(cells-f), int(pct*100)
def frame(tick, el):
    b, pct = bar(el)
    return SPIN[tick % 4] + " gpt-image-2 рисует…\n" + b + "  " + str(pct) + "%  ·  " + str(el) + "с"
msg = call("sendMessage", {"chat_id": CHAT, "text": frame(0, 0)})
mid = msg.get("result", {}).get("message_id")
proc = subprocess.Popen(["/home/moltbot/clawd/skills/imagegen/scripts/imagegen.sh", PROMPT, SIZE],
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
start = time.time(); tick = 0
while proc.poll() is None:
    tick += 1; el = int(time.time()-start)
    if mid: call("editMessageText", {"chat_id": CHAT, "message_id": mid, "text": frame(tick, el)})
    call("sendChatAction", {"chat_id": CHAT, "action": "upload_photo"})
    time.sleep(2)
out = (proc.stdout.read() or "").strip(); path = out.splitlines()[-1].strip() if out else ""
el = int(time.time()-start)
if path and os.path.isfile(path):
    if mid: call("deleteMessage", {"chat_id": CHAT, "message_id": mid})
    r = send_photo(CHAT, path, "✅ за " + str(el) + "с · gpt-image-2")
    print("SENT" if r.get("ok") else "SEND_FAIL " + json.dumps(r)[:200]); print(path)
else:
    if mid: call("editMessageText", {"chat_id": CHAT, "message_id": mid, "text": "⚠️ не получилось (" + str(el) + "с)"})
    print("GEN_FAIL"); print(out[-300:])
