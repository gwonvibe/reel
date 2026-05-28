# reel

인스타그램 릴스 / 유튜브 / 틱톡 등 영상 링크를 **한국어 대본**으로 자동 변환하는 Claude Code 플러그인.

- 오디오 추출: `yt-dlp`
- 받아쓰기: OpenAI `whisper` (small 모델 기본, 한국어)
- 모두 로컬에서 동작 (영상은 외부 서버로 보내지지 않음)

---

## 🚀 빠른 시작

### 0단계 — Claude Code CLI 설치 (처음이면 한 번만)

> **💡 VS Code 익스텐션에서는 `/plugin` 슬래시 커맨드가 작동하지 않습니다.** 반드시 **터미널에서 CLI**로 실행하세요.

**macOS / Linux:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://claude.ai/install.ps1 | iex
```

> Windows에서 `'irm' is not recognized...` 에러가 뜨면 CMD에서 실행한 거예요. PowerShell을 열어서 다시 실행하세요. 프롬프트가 `PS C:\`로 시작하면 PowerShell, `C:\`만 있으면 CMD입니다.

설치 후 터미널에서:

```bash
claude --version
```

버전이 출력되면 설치 성공.

### 1단계 — Claude Code 실행

작업하고 싶은 폴더에서 터미널을 열고:

```bash
claude
```

처음 실행 시 브라우저로 로그인 안내가 나옵니다. (Claude Pro/Max/Team/Enterprise 또는 Console 계정 필요)

### 2단계 — reel 플러그인 설치

Claude Code 채팅창에 두 줄만 입력하면 끝.

```
/plugin marketplace add https://github.com/gwonvibe/reel
/plugin install reel@gwonvibe
```

> **💡 `https://` URL을 그대로 사용하세요.** `gwonvibe/reel` 같은 짧은 형식은 SSH 키 인증을 시도해서 대부분 실패합니다.

설치 후 영상 링크와 함께 의도를 한마디 던지세요:

```
이거 대본 따줘 https://www.instagram.com/reel/XXXXX/
```

또는 슬래시 커맨드 명시 호출:

```
/reel:extract https://www.instagram.com/reel/XXXXX/
```

처음 호출 시 의존성(Python, ffmpeg, yt-dlp, whisper)을 자동 설치합니다. 그 이후엔 어느 폴더에서 Claude Code를 켜든 바로 동작합니다.

---

## 🎯 사용 예시

### 의도 키워드 + 링크 (자동 발동)

다음 키워드 중 하나가 링크와 함께 있으면 플러그인이 자동 동작:

> 대본, 받아쓰기, 스크립트, 트랜스크립트, transcribe, 받아 적, 글로, 텍스트로, 따줘, 뽑아줘, 추출, 옮겨

예시:

```
이거 대본 따줘 https://www.instagram.com/reel/XXXXX/
받아쓰기 해줘: https://youtu.be/XXXXX
이 영상 텍스트로 옮겨줘 https://www.tiktok.com/@user/video/XXXXX
```

### 슬래시 커맨드 (명시 호출)

```
/reel:extract <영상 링크>
/reel:install     ← 의존성 수동 설치 (보통 자동이라 불필요)
```

### 여러 링크 한 번에

```
이거 다 대본 따줘:
https://...릴스1
https://...릴스2
https://...유튜브1
```

### 타임스탬프 자막

```
타임스탬프로 대본 따줘 https://...
```

→ `audio.srt` 형식으로 저장.

### 정확도 우선 (`turbo` 모델)

```
이거 정확하게 대본 따줘 https://...
```

→ `turbo` 모델 사용 (기본 `small` 대신).

---

## 🌐 지원 플랫폼

yt-dlp 기반으로 1,800+ 영상 플랫폼 지원. 주요 플랫폼:

| 플랫폼 | 작동 | 비고 |
|---|---|---|
| YouTube / Shorts | ✅ | 가장 안정적 |
| Instagram (릴스/포스트) | ✅ | 비공개·스토리는 쿠키 필요 |
| TikTok | ✅ | 워터마크 없는 버전 |
| X (Twitter) | ⚠️ | 영상 트윗 가능, 최근 로그인 요구 증가 |
| Threads | ✅ | 최근 yt-dlp 버전부터 |
| Facebook | ✅ | 비공개는 쿠키 필요 |
| Vimeo / Twitch | ✅ | 공개 영상 |
| Netflix / Disney+ / 웨이브 / 티빙 | ❌ | DRM 보호 — 법적으로도 우회 금지 |

**로그인 필요한 영상 (쿠키 설정)**:

브라우저 쿠키를 yt-dlp에 전달하면 비공개/멤버십 영상도 다운로드 가능합니다. 단, 본 도구는 기본 설정에서 쿠키를 사용하지 않습니다. 필요 시 yt-dlp `--cookies-from-browser` 옵션을 직접 추가하는 변형 사용 안내는 트러블슈팅 섹션 참고.

---

## 📁 결과 저장 위치

```
~/reel/output/
└── <영상제목 [영상ID]>/
    ├── audio.mp3      (오디오)
    ├── audio.txt      (대본; 타임스탬프 옵션 시 audio.srt)
    └── source.txt     (원본 링크)
```

플러그인이 어느 폴더에서 호출되든 결과는 항상 `~/reel/output/`에 모입니다.

---

## 🤖 모델 선택 가이드

| 모델 | 크기 | 1분 영상 (CPU) | 한국어 정확도 |
|---|---|---|---|
| `tiny` | ~75MB | ~5초 | 70% |
| `base` | ~150MB | ~10초 | 85% |
| **`small`** | **~500MB** | **~30초** | **92% (기본값)** |
| `medium` | ~1.5GB | ~1분 | 95% |
| `turbo` | ~1.5GB | ~30~60초 | 97% |

기본값 `small`은 인스타 릴스/숏폼 한국어 받아쓰기에 가성비가 가장 좋습니다. 정확도가 절대적으로 중요하면 "정확하게"를 메시지에 포함하세요.

---

## ⚙️ 플러그인 없이 직접 사용 (수동 설치)

플러그인을 쓸 수 없는 환경에서는 스크립트를 직접 실행할 수 있습니다.

### macOS / Linux

```bash
git clone https://github.com/gwonvibe/reel.git
cd reel
bash install.sh

./reel2script.sh "https://..."
./reel2script.sh "링크1" "링크2"
./reel2script.sh "링크" --srt
./reel2script.sh "링크" --model=turbo
```

### Windows

```powershell
git clone https://github.com/gwonvibe/reel.git
cd reel
powershell -ExecutionPolicy Bypass -File install.ps1

.\reel2script.ps1 "https://..."
.\reel2script.ps1 "링크" -Srt
.\reel2script.ps1 "링크" -Model turbo
```

---

## 🛠️ 문제 해결

**플러그인이 발동 안 함** — 의도 키워드("대본", "따줘" 등)와 영상 링크를 같은 메시지에 넣었는지 확인. 또는 `/reel:extract <링크>`로 명시 호출.

**로그인 필요한 영상 (비공개 계정, 멤버십 등)** — 브라우저 쿠키 사용:
```bash
# reel2script.sh 안의 yt-dlp 호출에 다음 옵션 추가
yt-dlp --cookies-from-browser chrome ...   # 또는 firefox, safari, edge, brave
```
브라우저에서 해당 플랫폼에 로그인된 상태여야 합니다. 보안상 권장하지 않으며 본인 콘텐츠에 한해서만 사용하세요.

**`yt-dlp` 다운로드 실패** — 플랫폼 사양이 자주 바뀝니다. 최신화:
- macOS/Linux: `source ~/.claude/plugins/reel/.venv/bin/activate && pip install -U yt-dlp`
- Windows: 동일 경로의 `Activate.ps1` 사용

**Whisper가 너무 느림** — `tiny` 또는 `base` 모델 안내 (메시지에 "빠르게"). CPU만 있는 환경에서 5분 이상 긴 영상은 시간이 걸립니다.

**Mac에서 Homebrew 자동 설치 실패** — sudo 비밀번호 입력 필요. 또는 수동 설치 후 재실행:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Windows에서 PowerShell 실행 정책 막힘** — `powershell -ExecutionPolicy Bypass -File ...`로 실행.

---

## 📄 라이선스

MIT.

본 도구는 **학습·연구·본인 콘텐츠 받아쓰기** 목적으로 제공됩니다. 각 플랫폼의 이용약관과 저작권법을 준수하여 사용하세요.
