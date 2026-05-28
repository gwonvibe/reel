# reel-script

인스타그램 릴스 / 유튜브 / 틱톡 등 영상 링크를 **한국어 대본**으로 자동 변환하는 로컬 도구.

- 오디오 추출: `yt-dlp`
- 받아쓰기: OpenAI `whisper` (small 모델 기본, 한국어)
- 모두 로컬에서 동작 (영상은 외부 서버로 보내지지 않음)

---

## 🚀 Claude Code 사용자 — 한 줄 프롬프트 (권장)

자기 컴퓨터에 Claude Code가 설치돼 있다면, 아무것도 직접 설치할 필요 없습니다. 아래 프롬프트를 그대로 복사해서 Claude Code에 붙여넣으세요:

```
아래 repo를 내 홈 폴더에 클론하고 설치까지 해줘.

repo: https://github.com/gwonvibe/reel-script

진행 순서:
1. git이 설치돼 있는지 확인. 없으면 내 OS에 맞게 설치 (macOS는 `xcode-select --install` 또는 `brew install git`, Windows는 `winget install --id Git.Git`, Linux는 apt/dnf).
2. 홈 폴더로 이동해서 위 repo를 클론.
3. macOS/Linux면 `bash install.sh`, Windows면 `powershell -ExecutionPolicy Bypass -File install.ps1` 실행.
4. 설치 완료되면 사용 예시 한 줄 알려줘.
```

Claude Code가 OS를 감지하고, git이 없으면 알아서 설치한 뒤 클론 + 설치까지 진행합니다.

설치가 끝난 후에는 영상 링크만 던져주면 됩니다:

```
이거 대본 따줘: https://www.instagram.com/reel/XXXXX/
```

---

## 수동 설치

Claude Code 없이 직접 설치할 경우 아래 절차를 따릅니다. **git이 먼저 설치돼 있어야 합니다.**

- macOS: `xcode-select --install` (또는 [git 공식 사이트](https://git-scm.com/download/mac))
- Windows: `winget install --id Git.Git` (또는 [git 공식 사이트](https://git-scm.com/download/win))
- Linux: `sudo apt install git` 등

### macOS / Linux — 설치

```bash
git clone https://github.com/gwonvibe/reel-script.git
cd reel-script
bash install.sh
```

`install.sh`가 Python3, ffmpeg, yt-dlp, whisper를 자동 설치합니다.
(macOS는 Homebrew 필요, Linux는 apt 기반 배포판 대응)

### macOS / Linux — 사용

```bash
./reel2script.sh "https://www.instagram.com/reel/XXXXX/"
./reel2script.sh "링크1" "링크2" "링크3"        # 여러 개
./reel2script.sh "링크" --srt                    # 타임스탬프 자막
./reel2script.sh "링크" --model=turbo            # 최고 정확도 (느림)
```

### Windows — 설치

PowerShell을 **관리자 권한**으로 열고:

```powershell
git clone https://github.com/gwonvibe/reel-script.git
cd reel-script
powershell -ExecutionPolicy Bypass -File install.ps1
```

`install.ps1`이 winget으로 git/Python/ffmpeg를 설치한 뒤 venv에 yt-dlp + whisper를 설치합니다. 같은 세션에서 PATH를 갱신하므로 보통 1회 실행으로 완료됩니다.

> 드물게 PATH 갱신이 실패하면 스크립트가 안내합니다. 그땐 PowerShell을 닫고 다시 열어 같은 명령을 한 번 더 실행하세요.

### Windows — 사용

```powershell
.\reel2script.ps1 "https://www.instagram.com/reel/XXXXX/"
.\reel2script.ps1 "링크1" "링크2"
.\reel2script.ps1 "링크" -Srt
.\reel2script.ps1 "링크" -Model turbo
```

---

## 결과 구조

```
output/
└── <영상제목 [영상ID]>/
    ├── audio.mp3      ← 오디오
    ├── audio.txt      ← 대본 (--srt 옵션 시 audio.srt)
    └── source.txt     ← 원본 링크
```

---

## 모델 선택 가이드

| 모델 | 크기 | 1분 영상 (CPU) | 한국어 정확도 |
|---|---|---|---|
| `tiny` | ~75MB | ~5초 | 70% |
| `base` | ~150MB | ~10초 | 85% |
| **`small`** | **~500MB** | **~30초** | **92% (기본값)** |
| `medium` | ~1.5GB | ~1분 | 95% |
| `turbo` | ~1.5GB | ~30~60초 | 97% |

기본값 `small`은 인스타 릴스/숏폼 한국어 받아쓰기에 가성비가 가장 좋습니다. 전문 용어가 많거나 정확도가 절대적으로 중요하면 `--model=turbo`를 쓰세요.

CPU만 있는 환경에서 5분 이상 긴 영상은 시간이 걸립니다.

---

## 문제 해결

**`yt-dlp` 다운로드 실패** — 플랫폼이 자주 바뀝니다. 최신화하세요:
- macOS/Linux: `source .venv/bin/activate && pip install -U yt-dlp`
- Windows: `.\.venv\Scripts\Activate.ps1; pip install -U yt-dlp`

**Whisper가 너무 느림** — `--model=tiny` 또는 `--model=base`로 시도.

**PowerShell이 스크립트 실행을 막음** — `powershell -ExecutionPolicy Bypass -File ...`로 실행.

---

## 라이선스

MIT.

본 도구는 **학습·연구·본인 콘텐츠 받아쓰기** 목적으로 제공됩니다. 각 플랫폼의 이용약관과 저작권법을 준수하여 사용하세요.
