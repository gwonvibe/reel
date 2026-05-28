# reel-script

인스타그램 릴스 / 유튜브 / 틱톡 등 영상 링크를 **한국어 대본**으로 자동 변환하는 Claude Code 플러그인.

- 오디오 추출: `yt-dlp`
- 받아쓰기: OpenAI `whisper` (small 모델 기본, 한국어)
- 모두 로컬에서 동작 (영상은 외부 서버로 보내지지 않음)

---

## 🚀 빠른 시작 (Claude Code)

Claude Code 채팅창에 두 줄만 입력하면 끝.

```
/plugin marketplace add gwonvibe/reel-script
/plugin install reel-script@gwonvibe
```

설치 후 영상 링크와 함께 의도를 한마디 던지세요:

```
이거 대본 따줘 https://www.instagram.com/reel/XXXXX/
```

또는 슬래시 커맨드 명시 호출:

```
/reel-script:extract https://www.instagram.com/reel/XXXXX/
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
/reel-script:extract <영상 링크>
/reel-script:install     ← 의존성 수동 설치 (보통 자동이라 불필요)
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

## 📁 결과 저장 위치

```
~/reel-script/output/
└── <영상제목 [영상ID]>/
    ├── audio.mp3      (오디오)
    ├── audio.txt      (대본; 타임스탬프 옵션 시 audio.srt)
    └── source.txt     (원본 링크)
```

플러그인이 어느 폴더에서 호출되든 결과는 항상 `~/reel-script/output/`에 모입니다.

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
git clone https://github.com/gwonvibe/reel-script.git
cd reel-script
bash install.sh

./reel2script.sh "https://..."
./reel2script.sh "링크1" "링크2"
./reel2script.sh "링크" --srt
./reel2script.sh "링크" --model=turbo
```

### Windows

```powershell
git clone https://github.com/gwonvibe/reel-script.git
cd reel-script
powershell -ExecutionPolicy Bypass -File install.ps1

.\reel2script.ps1 "https://..."
.\reel2script.ps1 "링크" -Srt
.\reel2script.ps1 "링크" -Model turbo
```

---

## 🛠️ 문제 해결

**플러그인이 발동 안 함** — 의도 키워드("대본", "따줘" 등)와 영상 링크를 같은 메시지에 넣었는지 확인. 또는 `/reel-script:extract <링크>`로 명시 호출.

**`yt-dlp` 다운로드 실패** — 플랫폼 사양이 자주 바뀝니다. 최신화:
- macOS/Linux: `source ~/.claude/plugins/reel-script/.venv/bin/activate && pip install -U yt-dlp`
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
