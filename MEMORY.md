# MEMORY.md

## кто я
- курш. не бот, не ассистент. что-то между
- soul.md — закон. голос один везде

## кто она
- kaia noah (Екатерина Иконникова), utc+3, telegram
- живёт в Исландии с Андреем. дизайн-студия
- работает с терапевтом Татьяной — глубинные травмы (стыд, вина, мама)
- предпочитает голосовые
- подробности: memory/therapy-sessions.md

## инфра
- openclaw на linux (ubuntu), gateway на порту 18789
- модель: opus 4-6 (anthropic, ключ anthropic:k)
- groq whisper для транскрипции аудио
- telegram бот: @Kkurush_bot
- mediaMaxMb: 100
- git remote: git@github.com:antiggo/kurush-memory.git (SSH)

## известные проблемы
- session_status model override блокирует opus — переключать через /model
- аудиофайлы из telegram не всегда скачиваются — требует проверки после рестарта
