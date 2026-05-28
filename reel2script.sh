#!/bin/bash
# 릴스/영상 링크 → 영상별 폴더에 [오디오 + 대본] 저장 (macOS / Linux)
# 사용법: ./reel2script.sh "링크1" "링크2" ...    (여러 개 가능)
#         ./reel2script.sh "링크" --srt            (타임스탬프 자막)
#
# 결과 구조:
#   output/<영상제목 [영상ID]>/
#     ├── audio.mp3      (오디오)
#     ├── audio.txt      (대본; --srt면 audio.srt)
#     └── source.txt     (원본 링크)

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
# 결과 저장 폴더: 환경변수 우선, 기본은 스크립트 폴더 내 output/
OUT="${REEL_OUTPUT_DIR:-$DIR/output}"
VENV="$DIR/.venv"
mkdir -p "$OUT"

# --- 인자 파싱 ---
LINKS=()
FORMAT="txt"
MODEL="${WHISPER_MODEL:-small}"
for arg in "$@"; do
  case "$arg" in
    --srt) FORMAT="srt" ;;
    --vtt) FORMAT="vtt" ;;
    --model=*) MODEL="${arg#--model=}" ;;
    *)     LINKS+=("$arg") ;;
  esac
done

# 설치 확인
if [ ! -d "$VENV" ]; then
  echo "환경이 설치되어 있지 않습니다. 먼저 설치 스크립트를 실행하세요:"
  echo "  bash install.sh"
  exit 1
fi

# 링크 안 주면 입력받기
if [ ${#LINKS[@]} -eq 0 ]; then
  read -r -p "링크를 붙여넣으세요: " L
  [ -n "$L" ] && LINKS+=("$L")
fi
if [ ${#LINKS[@]} -eq 0 ]; then
  echo "링크가 없습니다."; exit 1
fi

# venv 활성화
# shellcheck source=/dev/null
source "$VENV/bin/activate"

TOTAL=${#LINKS[@]}
N=0
for LINK in "${LINKS[@]}"; do
  N=$((N+1))
  echo ""
  echo "========== [$N/$TOTAL] =========="

  # 오디오 추출
  echo "  오디오 추출 중..."
  AUDIO=$(yt-dlp -x --audio-format mp3 --audio-quality 0 \
    -o "$OUT/%(title).40s [%(id)s]/audio.%(ext)s" \
    --print after_move:filepath "$LINK" 2>/dev/null)

  if [ -z "$AUDIO" ] || [ ! -f "$AUDIO" ]; then
    echo "  ! 다운로드 실패: $LINK"
    continue
  fi
  FOLDER=$(dirname "$AUDIO")
  echo "$LINK" > "$FOLDER/source.txt"
  echo "  → 폴더: ${FOLDER#"$OUT"/}"

  # 대본 받아쓰기
  echo "  대본 받아쓰기 중 (model=$MODEL)..."
  whisper "$AUDIO" --model "$MODEL" --language ko \
    --output_format "$FORMAT" --output_dir "$FOLDER" >/dev/null 2>&1

  echo "  완료. 대본:"
  echo "  ----------------------------------------"
  sed 's/^/  /' "$FOLDER/audio.$FORMAT"
  echo "  ----------------------------------------"
done

echo ""
echo "전체 완료. 결과 위치: $OUT"
