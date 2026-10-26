#Requires -Version 5.1
<#
.SYNOPSIS
  On-demand Python 3.10+ / pixel backend probe. No installation by default.
.PARAMETER Repair
  If no backend is usable, attempt Pillow installation once.
#>
param([switch]$Repair)

$ErrorActionPreference = 'Continue'
$probeRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolver = Join-Path $probeRoot 'resolve-python.ps1'
$probeScript = Join-Path $probeRoot 'probe-measure-env.py'
$resolveOutput = & powershell -NoProfile -File $resolver 2>&1 | Out-String
$resolveLines = @($resolveOutput -split "`n" | Where-Object { $_.Trim() -ne '' })
$resolveLine = if ($resolveLines.Count) { $resolveLines[-1].Trim() } else { '' }

if ($resolveLine -notmatch '^OK\|') {
    Write-Output 'FAIL|python|No real Python 3.10+; set PYTHON_EXE.'
    Write-Output 'FAIL|measure|exact pixel fields remain incomplete; UI analysis may continue'
    exit 1
}

$probePython = $resolveLine.Split('|')[1]
$probeArgs = @($probeScript)
if ($Repair) { $probeArgs += '--repair' }
& $probePython @probeArgs
exit $LASTEXITCODE
