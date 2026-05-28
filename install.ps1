# reel-script 설치 스크립트 (Windows)
# - Python3, ffmpeg, yt-dlp, openai-whisper 자동 설치
# - 가상환경: .\.venv
#
# 실행:
#   powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

$Dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Venv = Join-Path $Dir ".venv"

Write-Host "=========================================="
Write-Host "  reel-script 설치 (Windows)"
Write-Host "=========================================="
Write-Host ""

function Test-Command($name) {
    $null = Get-Command $name -ErrorAction SilentlyContinue
    return $?
}

# winget으로 패키지 설치 후 같은 세션에서 PATH를 다시 읽어와
# PowerShell 재시작 없이 새 명령을 즉시 사용 가능하게 만든다.
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# winget 확인
if (-not (Test-Command "winget")) {
    Write-Host "  ! winget 미설치. Windows 10 1809+ / Windows 11에서 사용 가능합니다."
    Write-Host "    Microsoft Store에서 'App Installer'를 설치한 뒤 다시 실행하세요."
    exit 1
}

# git (안전망)
Write-Host "[0/4] git 확인..."
if (-not (Test-Command "git")) {
    Write-Host "  git 설치 중..."
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
    Refresh-Path
    if (-not (Test-Command "git")) {
        Write-Host "  ! git 설치 후에도 PATH에서 찾을 수 없습니다. PowerShell을 닫고 다시 열어 재실행하세요."
        exit 1
    }
    Write-Host "  → $(git --version)"
} else {
    Write-Host "  → $(git --version)"
}

# Python3
Write-Host "[1/4] Python3 확인..."
if (-not (Test-Command "python")) {
    Write-Host "  Python 설치 중..."
    winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
    Refresh-Path
    if (-not (Test-Command "python")) {
        Write-Host "  ! Python 설치 후에도 PATH에서 찾을 수 없습니다. PowerShell을 닫고 다시 열어 재실행하세요."
        exit 1
    }
    Write-Host "  → $(python --version)"
} else {
    $pyVer = python --version
    Write-Host "  → $pyVer"
}

# ffmpeg
Write-Host "[2/4] ffmpeg 확인..."
if (-not (Test-Command "ffmpeg")) {
    Write-Host "  ffmpeg 설치 중..."
    winget install -e --id Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
    Refresh-Path
    if (-not (Test-Command "ffmpeg")) {
        Write-Host "  ! ffmpeg 설치 후에도 PATH에서 찾을 수 없습니다. PowerShell을 닫고 다시 열어 재실행하세요."
        exit 1
    }
    Write-Host "  → 설치 확인됨"
} else {
    Write-Host "  → 설치 확인됨"
}

# venv
Write-Host "[3/4] Python 가상환경 생성..."
if (-not (Test-Path $Venv)) {
    python -m venv $Venv
    Write-Host "  → $Venv"
} else {
    Write-Host "  → 기존 venv 사용"
}

$Activate = Join-Path $Venv "Scripts\Activate.ps1"
. $Activate
python -m pip install --upgrade pip | Out-Null

# yt-dlp + openai-whisper
Write-Host "[4/4] yt-dlp + openai-whisper 설치 (PyTorch 포함, 수 분 소요)..."
pip install --upgrade yt-dlp openai-whisper

Write-Host ""
Write-Host "=========================================="
Write-Host "  설치 완료"
Write-Host "=========================================="
Write-Host ""
Write-Host "사용 예시:"
Write-Host "  .\reel2script.ps1 `"https://www.instagram.com/reel/...`""
Write-Host ""
Write-Host "처음 실행 시 whisper small 모델(~500MB)이 자동 다운로드됩니다."
Write-Host ""
Write-Host "주의: PowerShell 실행 정책 때문에 막히면 다음 명령으로 실행하세요:"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\reel2script.ps1 `"링크`""
