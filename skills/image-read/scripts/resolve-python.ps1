#Requires -Version 5.1
<#
.SYNOPSIS
  Resolve a real Python 3 interpreter on Windows (skip WindowsApps stubs).

.OUTPUTS
  OK|<abs-path>|<version>
  FAIL|<reason>
#>
$ErrorActionPreference = 'Continue'

function Test-RealPython {
    param([Parameter(Mandatory = $true)][string]$Exe)
    if ([string]::IsNullOrWhiteSpace($Exe)) { return $false }
    if (-not (Test-Path -LiteralPath $Exe)) { return $false }
    $full = [System.IO.Path]::GetFullPath($Exe)
    if ($full -match '(?i)\\WindowsApps\\') { return $false }

    try {
        $verOut = & $full --version 2>&1 | Out-String
        if ($verOut -notmatch 'Python\s+3\.(\d+)') { return $false }
        $minor = [int]$Matches[1]
        if ($minor -lt 10) { return $false }

        $exeOut = & $full -c "import sys; print(sys.executable)" 2>&1 | Out-String
        $exeOut = $exeOut.Trim()
        if ([string]::IsNullOrWhiteSpace($exeOut)) { return $false }
        if ($exeOut -match '(?i)\\WindowsApps\\') { return $false }
        return $true
    } catch {
        return $false
    }
}

function Get-PythonVersionString {
    param([string]$Exe)
    $verOut = & $Exe --version 2>&1 | Out-String
    if ($verOut -match 'Python\s+3\.\d+\.\d+') { return $Matches[0].Trim() }
    if ($verOut -match 'Python\s+3\.\d+') { return $Matches[0].Trim() }
    return ($verOut.Trim() -replace '\r|\n', ' ')
}

function Emit-Ok {
    param([string]$Exe)
    $full = [System.IO.Path]::GetFullPath($Exe)
    $ver = Get-PythonVersionString -Exe $full
    Write-Output ("OK|{0}|{1}" -f $full, $ver)
    exit 0
}

function Emit-Fail {
    param([string]$Reason)
    Write-Output ("FAIL|{0}" -f $Reason)
    exit 1
}

# 1) Explicit env
foreach ($envName in @('PYTHON_EXE', 'PYTHON')) {
    $v = [Environment]::GetEnvironmentVariable($envName, 'Process')
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($envName, 'User') }
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($envName, 'Machine') }
    if ($v -and (Test-Path -LiteralPath $v) -and (Test-RealPython $v)) {
        Emit-Ok $v
    }
}

$pythonHome = [Environment]::GetEnvironmentVariable('PYTHONHOME', 'Process')
if (-not $pythonHome) { $pythonHome = [Environment]::GetEnvironmentVariable('PYTHONHOME', 'User') }
if ($pythonHome) {
    $candidate = Join-Path $pythonHome 'python.exe'
    if (Test-RealPython $candidate) { Emit-Ok $candidate }
}

# 2) py launcher
$pyCmds = @('py')
foreach ($pyCmd in $pyCmds) {
    $py = Get-Command $pyCmd -ErrorAction SilentlyContinue |
        Where-Object { $_.Source -and ($_.Source -notmatch '(?i)\\WindowsApps\\') } |
        Select-Object -First 1
    if (-not $py) { continue }
    foreach ($arg in @('-3.12', '-3.13', '-3.11', '-3.10', '-3')) {
        try {
            $exeOut = & $py.Source $arg -c "import sys; print(sys.executable)" 2>&1 | Out-String
            $exeOut = ($exeOut -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1).Trim()
            if ($exeOut -and (Test-RealPython $exeOut)) {
                Emit-Ok $exeOut
            }
        } catch { }
    }
}

# 3) Well-known install roots
$roots = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\Python'),
    ${env:ProgramFiles},
    (Join-Path $env:USERPROFILE 'anaconda3'),
    (Join-Path $env:USERPROFILE 'miniconda3'),
    (Join-Path $env:LOCALAPPDATA 'anaconda3'),
    (Join-Path $env:LOCALAPPDATA 'miniconda3')
)

$found = @()
foreach ($root in $roots) {
    if (-not $root -or -not (Test-Path -LiteralPath $root)) { continue }
    # Python3xx\python.exe under Local\Programs\Python
    Get-ChildItem -LiteralPath $root -Filter 'python.exe' -Recurse -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -match '(?i)\\Python3\d+\\python\.exe$' -or
            $_.FullName -match '(?i)\\(anaconda|miniconda)3\\python\.exe$'
        } |
        ForEach-Object { $found += $_.FullName }
}

# Prefer highest Python3xx version
$ranked = $found | Sort-Object -Unique | Sort-Object {
    if ($_ -match 'Python3(\d+)') { [int]$Matches[1] } else { 0 }
} -Descending

foreach ($exe in $ranked) {
    if (Test-RealPython $exe) { Emit-Ok $exe }
}

# 4) PATH commands — skip WindowsApps
$cmds = Get-Command python, python3, python3.12, python3.11, python3.10 -ErrorAction SilentlyContinue
foreach ($c in $cmds) {
    $src = $c.Source
    if (-not $src) { continue }
    if ($src -match '(?i)\\WindowsApps\\') { continue }
    if (Test-RealPython $src) { Emit-Ok $src }
}

Emit-Fail 'No real Python 3.10+ found (WindowsApps stubs ignored). Set PYTHON_EXE to full path of python.exe, or install Python 3.12+.'
