---
name: install
description: reel-script 플러그인의 첫 사용에 필요한 의존성(Python venv, yt-dlp, whisper, ffmpeg)을 자동 설치한다. extract skill이 .venv 부재를 감지하면 먼저 이 skill을 호출한다. 사용자가 명시적으로 "/reel-script:install" 또는 "reel-script 설치"라고 하면 직접 실행한다.
---

# reel-script 설치

이 skill은 reel-script가 영상 받아쓰기에 사용하는 의존성을 사용자의 시스템에 설치한다. 한 번만 실행하면 된다.

## 동작 순서

1. **사용자 OS 감지**
   - macOS: `uname` → `Darwin`
   - Linux: `uname` → `Linux`
   - Windows: PowerShell 환경

2. **결과 저장 폴더 생성**
   ```bash
   mkdir -p ~/reel-script/output
   ```
   첫 설치 시 안내 파일도 생성:
   ```
   ~/reel-script/README.txt
   ```
   내용 예시:
   ```
   여기는 reel-script 결과물 폴더입니다.
   영상 대본은 output/ 하위에 자동 저장됩니다.
   ```

3. **플러그인 디렉토리 위치 확인**
   플러그인이 설치된 경로를 찾는다 (보통 `~/.claude/plugins/reel-script/`). 그 안의 `install.sh` (Mac/Linux) 또는 `install.ps1` (Windows)를 실행.

4. **설치 스크립트 실행**
   - macOS/Linux: `bash <플러그인경로>/install.sh`
   - Windows: `powershell -ExecutionPolicy Bypass -File <플러그인경로>\install.ps1`

   이 스크립트가 자동으로:
   - Homebrew(Mac) / winget(Win) 확인 후 없으면 설치
   - Python 3, ffmpeg, git 설치
   - `<플러그인경로>/.venv/` 생성
   - yt-dlp + openai-whisper 설치

5. **설치 완료 확인 후 사용자에게 안내**
   ```
   ✅ 설치 완료
   - 결과 저장 위치: ~/reel-script/output/
   - 사용 방법: 영상 링크를 던지고 "대본 따줘" 같은 키워드를 함께 입력
   - 또는 슬래시 커맨드: /reel-script:extract <링크>
   ```

## 주의

- macOS에서 Homebrew 신규 설치 시 sudo 비밀번호 1회 요구된다. 사용자에게 알리고 진행한다.
- Windows에서 winget으로 패키지 신규 설치 시 PATH 갱신이 필요할 수 있다. 스크립트가 자동 처리하지만, 실패 시 PowerShell 재시작 안내가 출력된다.
- 처음 영상 받아쓰기 시 whisper `small` 모델(~500MB)이 추가로 자동 다운로드된다. 인터넷 연결이 필요하다.

## 사용자가 직접 호출하는 경우

```
/reel-script:install
```

## 자동 호출되는 경우

`extract` skill이 실행 시점에 `.venv/` 디렉토리가 없음을 감지하면 자동으로 이 skill을 먼저 호출한다.
