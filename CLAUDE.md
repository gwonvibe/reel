# reel — 영상 링크 → 대본 추출 도구

이 파일은 본 repo를 **플러그인이 아닌 일반 git clone 형태로 직접 사용할 때** Claude Code에게 동작을 알려주는 폴백 지시서다. 플러그인으로 설치한 경우 `skills/extract/SKILL.md`가 우선 적용된다.

## 기본 동작

사용자가 **영상 URL + 의도 키워드**("대본", "받아쓰기", "따줘", "스크립트", "추출" 등)를 함께 입력하면, 본 repo의 스크립트를 실행한다.

- 단독 URL이면 한 번 의도를 묻고 진행한다 ("대본 추출? 영상 요약? 다른 작업?")
- "요약해줘", "어떤 내용이야", "분석" 같은 다른 의도가 명시되면 이 스크립트를 호출하지 말고 Claude가 직접 응답한다.

## 실행

**macOS / Linux:**
```bash
./reel2script.sh "<URL>" ["<URL2>" ...]
```

**Windows:**
```powershell
.\reel2script.ps1 "<URL>"
```

옵션:
- 타임스탬프 자막: `--srt` / `-Srt`
- 모델 변경: `--model=turbo` / `-Model turbo` (기본 `small`)

## 설치 확인

`./.venv/` 디렉토리가 없으면 다음으로 안내:
- macOS/Linux: `bash install.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File install.ps1`

## 결과 위치

기본: `./output/<영상제목 [영상ID]>/audio.{mp3,txt}`
환경변수 `REEL_OUTPUT_DIR`로 변경 가능.

## 의존성

- Python 3.9+, ffmpeg, yt-dlp, openai-whisper
- 설치 스크립트가 자동 처리
