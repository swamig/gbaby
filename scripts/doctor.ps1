#Requires -Version 5.1
<#
.SYNOPSIS
    GBaby health check for Windows.
.DESCRIPTION
    Verifies all GBaby components are installed and working correctly.
#>

Set-StrictMode -Version Latest

$Issues = 0

function Write-Check($label, $pass, $fix) {
    if ($pass) {
        Write-Host "  ✓ " -ForegroundColor Green -NoNewline
        Write-Host $label
    } else {
        Write-Host "  ✗ " -ForegroundColor Red -NoNewline
        Write-Host $label
        Write-Host "    Fix: $fix" -ForegroundColor Gray
        $script:Issues++
    }
}

function Write-Info($label) {
    Write-Host "  ○ " -ForegroundColor Yellow -NoNewline
    Write-Host $label
}

Write-Host "GBaby Doctor" -ForegroundColor White
Write-Host ""

# ── System ──────────────────────────────────────────────────────

Write-Host "System" -ForegroundColor White

Write-Check "Rust toolchain" `
    ([bool](Get-Command cargo -ErrorAction SilentlyContinue)) `
    "winget install Rustlang.Rustup"

Write-Check "Node.js" `
    ([bool](Get-Command node -ErrorAction SilentlyContinue)) `
    "winget install OpenJS.NodeJS.LTS"

Write-Check "npm" `
    ([bool](Get-Command npm -ErrorAction SilentlyContinue)) `
    "Installed with Node.js"

$claudeExists = [bool](Get-Command claude -ErrorAction SilentlyContinue)
Write-Check "Claude Code" $claudeExists "npm install -g @anthropic-ai/claude-code"

# ── GPU / Acceleration ──────────────────────────────────────────

Write-Host ""
Write-Host "GPU / Acceleration" -ForegroundColor White

$hasGpu = $false
try {
    $nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
    if ($nvidiaSmi) {
        $gpuName = & nvidia-smi --query-gpu=name --format=csv,noheader 2>$null | Select-Object -First 1
        if ($gpuName) {
            Write-Host "  ✓ " -ForegroundColor Green -NoNewline
            Write-Host "NVIDIA GPU: $gpuName"
            $hasGpu = $true
        }
    }
} catch {}

if (-not $hasGpu) {
    Write-Info "No GPU detected — CPU mode (still fast)"
}

# Check CPU
try {
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name.Trim()
    Write-Host "  ✓ " -ForegroundColor Green -NoNewline
    Write-Host "CPU: $cpu"
} catch {}

# ── GBaby Components ────────────────────────────────────────────

Write-Host ""
Write-Host "GBaby Components" -ForegroundColor White

$projectRoot = Split-Path $PSScriptRoot -Parent

$rlibPath = Join-Path $projectRoot "target\release\gbaby_quant.dll"
$checkPath = Join-Path $projectRoot "target\release\libgbaby_quant.rlib"
$quantBuilt = (Test-Path $rlibPath) -or (Test-Path $checkPath)
if (-not $quantBuilt) {
    # Try cargo check as fallback
    Push-Location $projectRoot
    try {
        & cargo check -p gbaby-quant 2>$null
        $quantBuilt = ($LASTEXITCODE -eq 0)
    } catch {} finally { Pop-Location }
}
Write-Check "gbaby-quant (Rust crate)" $quantBuilt ".\scripts\setup.ps1"

$graphifyInstalled = Test-Path (Join-Path $projectRoot "node_modules\graphify")
Write-Check "Graphify (npm)" $graphifyInstalled "npm install"

$configExists = Test-Path (Join-Path $projectRoot "gbaby.toml")
Write-Check "gbaby.toml config" $configExists "Copy gbaby.toml.example to gbaby.toml"

$brainExists = Test-Path (Join-Path $projectRoot "brain\people")
Write-Check "Brain directory" $brainExists ".\scripts\setup.ps1"

# ── Knowledge Graph ─────────────────────────────────────────────

Write-Host ""
Write-Host "Knowledge Graph" -ForegroundColor White

$graphReport = Join-Path $projectRoot "graph\GRAPH_REPORT.md"
if (Test-Path $graphReport) {
    Write-Host "  ✓ " -ForegroundColor Green -NoNewline
    Write-Host "Graph exists"
    $nodeCount = (Select-String -Path $graphReport -Pattern "^-" | Measure-Object).Count
    Write-Host "    $nodeCount nodes indexed" -ForegroundColor Gray
} else {
    Write-Info "No graph yet — run: npm run graph:init"
}

# ── Summary ─────────────────────────────────────────────────────

Write-Host ""
if ($Issues -eq 0) {
    Write-Host "All healthy. The monster is alive." -ForegroundColor Green
} else {
    Write-Host "$Issues issue(s) found. Fix them and run doctor again." -ForegroundColor Red
}
