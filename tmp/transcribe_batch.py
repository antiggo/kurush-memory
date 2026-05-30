import json, os, subprocess, sys, urllib.request, urllib.error
from pathlib import Path
files=[Path(p) for p in sys.argv[2:]]
out=Path(sys.argv[1])
key=os.environ.get('ELEVENLABS_API_KEY')
if not key: raise SystemExit('NO ELEVENLABS_API_KEY')

def duration(p):
    try:
        return subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nw=1:nk=1',str(p)], text=True).strip()
    except Exception: return ''

def transcribe(p):
    boundary='----kurushboundary'
    parts=[]
    def field(name, val):
        parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{val}\r\n'.encode())
    field('model_id','scribe_v1')
    field('language_code','ru')
    data=p.read_bytes()
    parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{p.name}"\r\nContent-Type: audio/ogg\r\n\r\n'.encode()+data+b'\r\n')
    parts.append(f'--{boundary}--\r\n'.encode())
    body=b''.join(parts)
    req=urllib.request.Request('https://api.elevenlabs.io/v1/speech-to-text', data=body, headers={'xi-api-key':key,'Content-Type':f'multipart/form-data; boundary={boundary}'})
    with urllib.request.urlopen(req, timeout=180) as r:
        return json.loads(r.read().decode()).get('text','')

with out.open('a', encoding='utf-8') as w:
    for p in files:
        w.write(f'===== {p.name} =====\nDURATION: {duration(p)}\n')
        w.flush()
        try:
            txt=transcribe(p)
        except Exception as e:
            txt=f'[ERROR {type(e).__name__}: {e}]'
        w.write(txt+'\n\n')
        w.flush()
