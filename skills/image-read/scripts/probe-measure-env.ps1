#Requires -Version 5.1
<#
.SYNOPSIS
  Probe measure env: real Python 3.10+, then any usable image backend.
  Does NOT require cv2. Pillow is the default ensured backend; cv2 is optional.
.OUTPUTS
  OK|python|<abs>|<version>
  OK|pillow|<ver> and/or OK|cv2|<ver>
  FAIL|...
  Exit 0 if python OK AND at least one measure backend OK.
#>
$ErrorActionPreference = 'Continue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolver = Join-Path $here 'resolve-python.ps1'

function Test-Import {
    param([string]$Py, [string]$Code)
    $out = & $Py -c $Code 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { return $null }
    $last = (($out -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1).Trim())
    if ($last -match '(?i)Error|Traceback|ModuleNotFound') { return $null }
    return $last
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

# Default backend: Pillow (sufficient for most pixel measure)
$pilVer = Test-Import -Py $py -Code "from PIL import Image; import PIL; print(PIL.__version__)"
if (-not $pilVer) {
    Write-Output 'FAIL|pillow|missing; pip install Pillow once'
    & $py -m pip install Pillow 2>&1 | Out-Null
    $pilVer = Test-Import -Py $py -Code "from PIL import Image; import PIL; print(PIL.__version__)"
}
if ($pilVer) { Write-Output ("OK|pillow|{0}" -f $pilVer) }
else { Write-Output 'FAIL|pillow|unusable after pip install once' }

# Optional backend: cv2 (report if usable; repair once if broken — not required to pass)
$cv2Ver = Test-Import -Py $py -Code "import cv2; print(cv2.__version__)"
if (-not $cv2Ver) {
    Write-Output 'FAIL|cv2|not available; optional pip install opencv-python once'
    & $py -m pip install opencv-python 2>&1 | Out-Null
    $cv2Ver = Test-Import -Py $py -Code "import cv2; print(cv2.__version__)"
}
if (-not $cv2Ver) {
    & $py -m pip install opencv-python-headless 2>&1 | Out-Null
    $cv2Ver = Test-Import -Py $py -Code "import cv2; print(cv2.__version__)"
}
if ($cv2Ver) { Write-Output ("OK|cv2|{0}" -f $cv2Ver) }
else { Write-Output 'FAIL|cv2|optional; not required if pillow OK' }

if ($pilVer -or $cv2Ver) {
    Write-Output 'OK|measure|use any OK backend; prefer whichever is accurate for the task'
    exit 0
}
Write-Output 'FAIL|measure|no usable pixel backend; do not estimate'
exit 1
