# reel-script — 영상 링크 → 대본 추출 도구

이 파일은 Claude Code(또는 유사 AI 에이전트)에게 본 도구의 사용법을 알려주는 지시서다. 본 repo 루트에 위치해야 한다.

## 기본 동작 (필수)

사용자가 **인스타그램/유튜브/틱톡 등 영상 링크**를 주면, 영상 내용을 추측하거나 외부 분석 도구(vidIQ 등)로 요약하지 말고 **반드시 본 repo의 스크립트를 실행**한다.

실행 위치는 **이 `CLAUDE.md`가 있는 디렉토리(= repo 루트)** 기준이다. 사용자의 OS에 따라 분기한다.

### macOS / Linux

```bash
./reel2script.sh "<링크>"
```

여러 링크:

```bash
./reel2script.sh "<링크1>" "<링크2>" "<링크3>"
```

타임스탬프 자막: `--srt` 플래그 추가
모델 변경: 기본 `small`, 정확도 우선 시 `--model=turbo`

### Windows (PowerShell)

```powershell
.\reel2script.ps1 "<링크>"
```

타임스탬프 자막: `-Srt`
모델 변경: 기본 `small`, 정확도 우선 시 `-Model turbo`

## 설치 확인

`./.venv/` 디렉토리가 없으면 설치가 안 된 상태다. 사용자에게 안내:

- macOS/Linux: `bash install.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File install.ps1`

설치 스크립트가 Python, ffmpeg, yt-dlp, openai-whisper를 자동 설치한다.

## 결과 위치

`output/<영상제목 [영상ID]>/` 폴더에 다음 파일이 저장된다:

- `audio.mp3` — 오디오
- `audio.txt` (또는 `audio.srt`) — 대본
- `source.txt` — 원본 링크

## 하지 말 것

- 영상 내용을 추측해서 분석/요약 결과만 먼저 내놓기 (사용자는 실제 받아쓰기 대본을 원함)
- 외부 MCP/API로 영상 내용을 대신 분석하기
- "대본을 원하세요, 분석을 원하세요?" 되묻기 — 영상 링크 = 대본 추출이 기본
- 사용자가 명시 요청하지 않은 한 OS를 임의로 가정하지 말기 (불명확하면 한 번 확인)

## 의존성 (설치 스크립트가 자동 처리)

- `yt-dlp` (오디오 추출)
- `openai-whisper` (받아쓰기, 기본 모델 `small`, 한국어)
- `ffmpeg` (오디오 변환)
- Python 3.9+

받아쓰기는 GPU가 없으면 CPU로 동작하며 긴 영상은 시간이 걸린다. 빠른 테스트가 필요하면 `tiny`/`base` 모델을 안내한다.
