---
description: reel-script 의존성을 설치한다 (Python, ffmpeg, yt-dlp, whisper)
---

# reel-script 설치

reel-script가 영상 받아쓰기에 필요한 의존성을 사용자 시스템에 설치한다. 한 번만 실행하면 된다.

## 동작

1. **사용자 OS 감지** (macOS / Linux / Windows)

2. **결과 저장 폴더 생성**:
   ```bash
   mkdir -p ~/reel-script/output
   ```

3. **플러그인 설치 스크립트 실행**:
   - 플러그인 경로 찾기: `${CLAUDE_PLUGIN_ROOT}` 또는 `~/.claude/plugins/...` 하위의 `reel-script` 폴더
   - macOS/Linux: `bash <플러그인경로>/install.sh`
   - Windows: `powershell -ExecutionPolicy Bypass -File <플러그인경로>\install.ps1`

   이 스크립트가 자동으로:
   - Homebrew(Mac) / winget(Win) 설치 확인
   - Python 3, ffmpeg, git 설치
   - `<플러그인경로>/.venv/` 생성
   - yt-dlp + openai-whisper 설치

4. **완료 안내**:
   ```
   ✅ reel-script 설치 완료
   📁 결과 저장 위치: ~/reel-script/output/
   💡 사용 방법: 영상 링크와 "대본 따줘" 키워드를 함께 입력
                또는 /reel-script:extract <링크>
   ```

## 주의

- macOS에서 Homebrew 신규 설치 시 sudo 비밀번호 1회 필요.
- Windows에서 winget 신규 패키지 설치 후 PATH 갱신 필요 시 PowerShell 재시작 안내 출력됨.
- 첫 영상 받아쓰기 시 whisper `small` 모델(~500MB) 자동 다운로드.
