#Requires -Version 5.1
<#
.SYNOPSIS
  Probe Python 3.10+ and Pillow for ImageRead. cv2 is not required.
.OUTPUTS
  OK|python|<abs>|<version>
  OK|pillow|<ver>
  FAIL|python|<reason>
  FAIL|pillow|<reason>
  Exit 0 only if both OK.
#>
$ErrorActionPreference = 'Continue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolver = Join-Path $here 'resolve-python.ps1'

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

$pilOut = & $py -c "from PIL import Image; import PIL; print(PIL.__version__)" 2>&1 | Out-String
if ($LASTEXITCODE -ne 0 -or $pilOut -match '(?i)ModuleNotFoundError|No module named') {
    Write-Output 'FAIL|pillow|missing; attempting pip install Pillow once'
    & $py -m pip install Pillow 2>&1 | Out-Null
    $pilOut = & $py -c "from PIL import Image; import PIL; print(PIL.__version__)" 2>&1 | Out-String
}

$pilVer = ($pilOut -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1).Trim()
if ($LASTEXITCODE -ne 0 -or $pilVer -match '(?i)Error|Traceback') {
    Write-Output ("FAIL|pillow|{0}" -f ($pilOut.Trim() -replace '\r|\n', ' '))
    exit 1
}

Write-Output ("OK|pillow|{0}" -f $pilVer)
exit 0
