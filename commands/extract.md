---
description: 영상 URL에서 한국어 대본을 추출한다 (인스타/유튜브/틱톡/X/Threads 등)
argument-hint: <영상 URL> [추가 URL...]
---

# 영상 대본 추출

명령 인자로 받은 영상 URL의 한국어 대본을 추출한다.

## 사용 예시

```
/reel:extract https://www.instagram.com/reel/XXXXX/
/reel:extract https://youtu.be/XXXXX https://www.tiktok.com/...
```

## 실행 순서

### Step 1 — 의존성 확인

플러그인 디렉토리의 `.venv/`가 있는지 확인. 없으면 `/reel:install`을 먼저 실행하라고 안내하거나 자동 호출.

```bash
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-~/.claude/plugins/...}"
[ -d "$PLUGIN_DIR/.venv" ] || (echo "먼저 /reel:install 실행")
```

### Step 2 — OS 감지 후 스크립트 실행

결과를 사용자 친화적 위치에 모으기 위해 환경변수 `REEL_OUTPUT_DIR`를 전달:

**macOS / Linux:**
```bash
REEL_OUTPUT_DIR="$HOME/reel/output" bash "$PLUGIN_DIR/reel2script.sh" "<URL>" ["<URL2>" ...]
```

**Windows:**
```powershell
$env:REEL_OUTPUT_DIR = "$HOME\reel\output"
powershell -ExecutionPolicy Bypass -File "$PLUGIN_DIR\reel2script.ps1" "<URL>"
```

### Step 3 — 옵션 처리

사용자 메시지/인자에 다음이 포함되면 옵션 적용:
- "타임스탬프", "자막", "srt" → `--srt` / `-Srt`
- "정확하게", "정확도 우선" → `--model=turbo` / `-Model turbo`
- "빠르게" → `--model=tiny`

### Step 4 — 결과 출력

채팅창에 다음 형식:

```
✅ 대본 추출 완료

[대본 본문 — audio.txt 내용]

📁 저장 위치: ~/reel/output/<영상제목 [영상ID]>/
```

### Step 5 — (선택) 결과 폴더 자동 열기

- macOS: `open ~/reel/output/<영상제목>`
- Windows: `explorer.exe %USERPROFILE%\reel\output\<영상제목>`

## 지원 플랫폼

YouTube / Instagram / TikTok / X(Twitter) / Threads / Facebook / Vimeo / Twitch 등 yt-dlp 지원 1,800+ 플랫폼.

❌ Netflix, Disney+, 웨이브, 티빙 등 DRM 보호 콘텐츠는 불가.

## 에러 처리

- `yt-dlp` 다운로드 실패 (비공개 영상 등):
  ```
  ❌ 다운로드 실패. 가능 원인:
  - 비공개 계정 영상 (로그인 필요)
  - 플랫폼 정책 변화 → yt-dlp 업데이트 필요
  ```

- 의존성 미설치 감지: `/reel:install` 안내
