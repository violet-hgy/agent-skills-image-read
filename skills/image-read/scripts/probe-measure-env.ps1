#Requires -Version 5.1
<#
.SYNOPSIS
  Probe measure env: Python 3.10+, then cv2 (auto-repair), then Pillow fallback.
.OUTPUTS
  OK|python|<abs>|<version>
  OK|cv2|<ver>           # preferred measure backend
  OK|pillow|<ver>        # required fallback if cv2 unusable
  FAIL|python|<reason>
  FAIL|cv2|<reason>
  FAIL|pillow|<reason>
  Exit 0 if python OK AND (cv2 OK or pillow OK).
#>
$ErrorActionPreference = 'Continue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolver = Join-Path $here 'resolve-python.ps1'

function Invoke-Py {
    param([string]$Py, [string]$Code)
    $out = & $Py -c $Code 2>&1 | Out-String
    return @{
        Code = $LASTEXITCODE
        Text = $out
        Last = (($out -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1).Trim())
    }
}

function Test-Import {
    param([string]$Py, [string]$Code)
    $r = Invoke-Py -Py $Py -Code $Code
    if ($r.Code -ne 0) { return $null }
    if ($r.Last -match '(?i)Error|Traceback|ModuleNotFound') { return $null }
    return $r.Last
}

$pyLine = & powershell -NoProfile -File $resolver 2>&1 | Out-String
$pyLine = ($pyLine -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1).Trim()

if ($pyLine -notmatch '^OK\|') {
    Write-Output 'FAIL|python|No real Python 3.10+ (WindowsApps stubs ignored). Set PYTHON_EXE.'
    if ($pyLine) { Write-Output ("FAIL|python|{0}" -f $pyLine) }
    exit 1
}

$parts = $pyLine.Split('|')
$py = $parts[1]
$ver = if ($parts.Length -ge 3) { $parts[2] } else { '' }
Write-Output ("OK|python|{0}|{1}" -f $py, $ver)

$cv2Code = "import cv2; print(cv2.__version__)"
$cv2Ver = Test-Import -Py $py -Code $cv2Code
if (-not $cv2Ver) {
    Write-Output 'FAIL|cv2|missing or broken; pip install opencv-python once'
    & $py -m pip install opencv-python 2>&1 | Out-Null
    $cv2Ver = Test-Import -Py $py -Code $cv2Code
}
if (-not $cv2Ver) {
    Write-Output 'FAIL|cv2|still broken; pip install opencv-python-headless once'
    & $py -m pip install opencv-python-headless 2>&1 | Out-Null
    $cv2Ver = Test-Import -Py $py -Code $cv2Code
}

$pilCode = "from PIL import Image; import PIL; print(PIL.__version__)"
$pilVer = Test-Import -Py $py -Code $pilCode
if (-not $pilVer) {
    Write-Output 'FAIL|pillow|missing; pip install Pillow once'
    & $py -m pip install Pillow 2>&1 | Out-Null
    $pilVer = Test-Import -Py $py -Code $pilCode
}

if ($cv2Ver) {
    Write-Output ("OK|cv2|{0}" -f $cv2Ver)
}
else {
    Write-Output 'FAIL|cv2|unusable after auto-repair; fallback pillow'
}

if ($pilVer) {
    Write-Output ("OK|pillow|{0}" -f $pilVer)
}
else {
    Write-Output 'FAIL|pillow|unusable after pip install once'
}

if ($cv2Ver -or $pilVer) { exit 0 }
Write-Output 'FAIL|measure|cv2 and pillow both unusable; do not estimate pixels'
exit 1
