---
name: extract
description: 인스타그램/유튜브/틱톡/쇼츠 영상 URL에서 한국어 대본(받아쓰기)을 추출한다. 사용자가 영상 URL과 함께 다음 의도 키워드 중 하나를 입력했을 때만 발동한다 — "대본", "받아쓰기", "스크립트", "트랜스크립트", "transcribe", "받아 적", "글로", "텍스트로", "따줘", "뽑아줘", "추출", "옮겨". 또는 명시적으로 "/reel:extract <링크>" 슬래시 커맨드로 호출된 경우. 사용자가 "이 영상 요약해줘", "어떤 내용이야", "분석해줘", "같이 보자" 같은 다른 의도를 명시했다면 이 skill을 호출하지 말고 Claude가 직접 적절히 응답한다.
---

# 영상 대본 추출

## 트리거 조건 (중요)

이 skill은 다음 조건을 **모두** 만족할 때만 발동한다:

1. **영상 URL이 메시지에 포함되어 있다.**
   - **YouTube**: youtube.com, youtu.be, youtube.com/shorts, m.youtube.com
   - **Instagram**: instagram.com, instagr.am (릴스/포스트/IGTV)
   - **TikTok**: tiktok.com, vt.tiktok.com, vm.tiktok.com
   - **X (Twitter)**: x.com, twitter.com, t.co (영상 포함 트윗)
   - **Threads**: threads.net, threads.com
   - **Facebook**: facebook.com, fb.watch
   - **Vimeo**: vimeo.com
   - **Twitch**: twitch.tv (클립/VOD)
   - **기타** yt-dlp가 지원하는 1,800+ 플랫폼

   ⚠️ 다음은 불가:
   - Netflix, Disney+, 웨이브, 티빙, 쿠팡플레이 등 DRM 보호 콘텐츠
   - 비공개 계정 / 로그인 필요 / 멤버십 영상 (쿠키 설정 시 일부 가능)

2. **다음 중 하나 이상의 조건이 충족된다:**
   - 의도 키워드 포함: "대본", "받아쓰기", "스크립트", "트랜스크립트", "transcribe", "받아 적", "글로", "텍스트로", "따줘", "뽑아줘", "추출", "옮겨"
   - 사용자가 슬래시 커맨드 `/reel:extract`로 명시 호출
   - 단독 URL이고 다른 의도 단어가 전혀 없음 (이 경우 진행 전 사용자에게 한 번 확인)

3. **다음 의도 키워드가 있다면 이 skill을 호출하지 않는다:**
   - "요약", "summary", "어떤 내용", "어떤 영상", "분석", "리뷰", "감상", "같이 보자", "공유"

## 의도가 모호할 때

URL만 단독으로 던져졌고 어떤 의도 키워드도 없는 경우:

```
[Claude 응답]
이 영상으로 무엇을 도와드릴까요?
1. 한국어 대본 추출 (받아쓰기)
2. 영상에 대한 질문/요약
3. 다른 작업
```

사용자가 1번 또는 "대본"이라고 답하면 이 skill로 진행.

## 실행 순서

### Step 1 — 의존성 확인

플러그인 디렉토리의 `.venv/`가 있는지 확인:
```bash
PLUGIN_DIR="$(dirname "$(dirname "$0")")"   # SKILL.md 기준 두 단계 위
[ -d "$PLUGIN_DIR/.venv" ] || /reel:install 호출
```

없으면 `install` skill을 먼저 호출해서 셋업 완료 후 진행.

### Step 2 — OS 감지 후 스크립트 실행

**macOS / Linux:**
```bash
bash "$PLUGIN_DIR/reel2script.sh" "<URL>"
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File "$PLUGIN_DIR\reel2script.ps1" "<URL>"
```

여러 URL이면 한 번에 전달:
```bash
bash "$PLUGIN_DIR/reel2script.sh" "<URL1>" "<URL2>" "<URL3>"
```

### Step 3 — 타임스탬프 자막 요청 감지

사용자 메시지에 "타임스탬프", "자막", "시간 표시", "srt", "vtt" 키워드 있으면 `--srt` (또는 PowerShell `-Srt`) 플래그 추가.

### Step 4 — 결과 출력

스크립트 실행 후 결과 폴더 경로: `~/reel-script/output/<영상제목 [영상ID]>/`

채팅에 다음 형식으로 출력:

```
✅ 대본 추출 완료

[대본 본문 — audio.txt 내용 직접 표시]

📁 저장 위치: ~/reel-script/output/<영상제목 [영상ID]>/
   ├── audio.mp3   (오디오)
   ├── audio.txt   (대본)
   └── source.txt  (원본 링크)
```

### Step 5 — 결과 폴더 자동 열기 (선택)

- macOS: `open ~/reel-script/output/<영상제목>`
- Windows: `explorer.exe %USERPROFILE%\reel-script\output\<영상제목>`
- Linux: `xdg-open ~/reel-script/output/<영상제목>` (DE 있을 때만)

사용자가 명시적으로 "폴더 열어줘"라고 하지 않았다면 자동 열기는 생략해도 됨. 대본 본문은 항상 채팅에 출력.

## 모델 옵션

기본 `small` 모델 사용. 사용자가 다음 표현을 쓰면 모델 변경:

- "정확하게", "정확도 우선", "best quality" → `--model=turbo`
- "빠르게", "대충", "tiny" → `--model=tiny`
- "더 나은 정확도" → `--model=medium`

PowerShell은 `-Model turbo` 형식.

## 에러 처리

- `yt-dlp` 다운로드 실패 (특히 인스타그램 로그인 필요 영상): 사용자에게 안내
  ```
  ❌ 다운로드 실패. 원인 가능성:
  - 비공개 계정 영상 (로그인 필요)
  - 플랫폼이 차단한 URL
  - yt-dlp 업데이트 필요
  
  yt-dlp 최신화: `bash "$PLUGIN_DIR/update-deps.sh"`
  ```

- whisper 실행 실패: 모델 다운로드 실패 가능성. 인터넷 연결 확인 안내.

## 결과 저장 위치 변경

기본은 플러그인의 `reel2script.sh`가 자체 `output/` 폴더에 저장한다. 사용자 친화적 위치(`~/reel-script/output/`)로 모이게 하려면 reel2script 실행 시 환경변수 `REEL_OUTPUT_DIR`를 전달:

```bash
REEL_OUTPUT_DIR="$HOME/reel-script/output" bash "$PLUGIN_DIR/reel2script.sh" "<URL>"
```

(reel2script.sh가 이 환경변수를 우선시하도록 별도 수정 필요)
