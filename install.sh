#!/bin/bash
# reel-script 설치 스크립트 (macOS / Linux)
# - Python3, ffmpeg, yt-dlp, openai-whisper 자동 설치
# - 가상환경: ./.venv

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="$DIR/.venv"

echo "=========================================="
echo "  reel-script 설치 (macOS / Linux)"
echo "=========================================="
echo ""

# OS 감지
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="mac" ;;
  Linux)  PLATFORM="linux" ;;
  *)      echo "지원하지 않는 OS: $OS"; exit 1 ;;
esac
echo "[1/5] OS: $PLATFORM"

# Homebrew (macOS만) — 없으면 자동 설치
if [ "$PLATFORM" = "mac" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "  Homebrew 미설치. 자동 설치를 시작합니다."
    echo "  (sudo 비밀번호를 한 번 입력해야 할 수 있습니다)"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # PATH 추가 — Apple Silicon은 /opt/homebrew, Intel은 /usr/local
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
      echo "  ! Homebrew 자동 설치 실패. 수동 설치 후 재실행하세요:"
      echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    echo "  → Homebrew 설치 완료"
  else
    echo "  → Homebrew 확인됨"
  fi
fi

# git (안전망 — 보통 클론 시점에 이미 있지만 일부 환경 대비)
echo "[1.5/5] git 확인..."
if ! command -v git >/dev/null 2>&1; then
  echo "  git 설치 중..."
  if [ "$PLATFORM" = "mac" ]; then
    brew install git
  else
    sudo apt-get update && sudo apt-get install -y git
  fi
else
  echo "  → $(git --version)"
fi

# Python3
echo "[2/5] Python3 확인..."
if ! command -v python3 >/dev/null 2>&1; then
  echo "  Python3 설치 중..."
  if [ "$PLATFORM" = "mac" ]; then
    brew install python
  else
    sudo apt-get update && sudo apt-get install -y python3 python3-venv python3-pip
  fi
else
  echo "  → $(python3 --version)"
fi

# ffmpeg
echo "[3/5] ffmpeg 확인..."
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "  ffmpeg 설치 중..."
  if [ "$PLATFORM" = "mac" ]; then
    brew install ffmpeg
  else
    sudo apt-get update && sudo apt-get install -y ffmpeg
  fi
else
  echo "  → 설치 확인됨"
fi

# venv
echo "[4/5] Python 가상환경 생성..."
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
  echo "  → $VENV"
else
  echo "  → 기존 venv 사용"
fi

# shellcheck source=/dev/null
source "$VENV/bin/activate"
pip install --upgrade pip >/dev/null

# yt-dlp + openai-whisper
echo "[5/5] yt-dlp + openai-whisper 설치 (PyTorch 포함, 수 분 소요)..."
pip install --upgrade yt-dlp openai-whisper

echo ""
echo "=========================================="
echo "  설치 완료"
echo "=========================================="
echo ""
echo "사용 예시:"
echo "  ./reel2script.sh \"https://www.instagram.com/reel/...\""
echo ""
echo "처음 실행 시 whisper small 모델(~500MB)이 자동 다운로드됩니다."
