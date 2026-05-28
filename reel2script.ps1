# 릴스/영상 링크 → 영상별 폴더에 [오디오 + 대본] 저장 (Windows PowerShell)
# 사용법: .\reel2script.ps1 "링크1" "링크2" ...    (여러 개 가능)
#         .\reel2script.ps1 "링크" -Srt             (타임스탬프 자막)
#         .\reel2script.ps1 "링크" -Model turbo     (모델 변경, 기본 small)
#
# 결과 구조:
#   output\<영상제목 [영상ID]>\
#     ├── audio.mp3      (오디오)
#     ├── audio.txt      (대본; -Srt면 audio.srt)
#     └── source.txt     (원본 링크)

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Links,
    [switch]$Srt,
    [switch]$Vtt,
    [string]$Model = $env:WHISPER_MODEL
)

$ErrorActionPreference = "Stop"

$Dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Out  = Join-Path $Dir "output"
$Venv = Join-Path $Dir ".venv"
New-Item -ItemType Directory -Force -Path $Out | Out-Null

if (-not $Model) { $Model = "small" }

$Format = "txt"
if ($Srt) { $Format = "srt" }
elseif ($Vtt) { $Format = "vtt" }

if (-not (Test-Path $Venv)) {
    Write-Host "환경이 설치되어 있지 않습니다. 먼저 설치 스크립트를 실행하세요:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File install.ps1"
    exit 1
}

if (-not $Links -or $Links.Count -eq 0) {
    $L = Read-Host "링크를 붙여넣으세요"
    if ($L) { $Links = @($L) }
}
if (-not $Links -or $Links.Count -eq 0) {
    Write-Host "링크가 없습니다."
    exit 1
}

# venv 활성화
$Activate = Join-Path $Venv "Scripts\Activate.ps1"
. $Activate

$Total = $Links.Count
$N = 0
foreach ($Link in $Links) {
    $N++
    Write-Host ""
    Write-Host "========== [$N/$Total] =========="

    Write-Host "  오디오 추출 중..."
    $OutTemplate = Join-Path $Out "%(title).40s [%(id)s]\audio.%(ext)s"
    $Audio = & yt-dlp -x --audio-format mp3 --audio-quality 0 `
        -o $OutTemplate --print "after_move:filepath" $Link 2>$null

    if (-not $Audio -or -not (Test-Path $Audio)) {
        Write-Host "  ! 다운로드 실패: $Link"
        continue
    }
    $Folder = Split-Path -Parent $Audio
    Set-Content -Path (Join-Path $Folder "source.txt") -Value $Link
    Write-Host "  → 폴더: $($Folder.Substring($Out.Length + 1))"

    Write-Host "  대본 받아쓰기 중 (model=$Model)..."
    & whisper $Audio --model $Model --language ko `
        --output_format $Format --output_dir $Folder *>$null

    Write-Host "  완료. 대본:"
    Write-Host "  ----------------------------------------"
    Get-Content (Join-Path $Folder "audio.$Format") | ForEach-Object { "  $_" }
    Write-Host "  ----------------------------------------"
}

Write-Host ""
Write-Host "전체 완료. 결과 위치: $Out"
