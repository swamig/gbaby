#Requires -Version 5.1
<#
.SYNOPSIS
    GBaby setup script for Windows.
.DESCRIPTION
    Detects GPU capabilities, builds the Rust crate with the right features,
    installs Node dependencies, and initializes the knowledge graph + brain.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Status($icon, $msg) {
    switch ($icon) {
        "ok"   { Write-Host "  ✓ " -ForegroundColor Green -NoNewline; Write-Host $msg }
        "warn" { Write-Host "  ○ " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
        "fail" { Write-Host "  ✗ " -ForegroundColor Red -NoNewline; Write-Host $msg }
        "info" { Write-Host "  → " -ForegroundColor Cyan -NoNewline; Write-Host $msg }
    }
}

Write-Host ""
Write-Host "   ██████  ██████   █████  ██████  ██    ██ " -ForegroundColor Cyan
Write-Host "  ██       ██   ██ ██   ██ ██   ██  ██  ██  " -ForegroundColor Cyan
Write-Host "  ██   ███ ██████  ███████ ██████    ████   " -ForegroundColor Cyan
Write-Host "  ██    ██ ██   ██ ██   ██ ██   ██    ██    " -ForegroundColor Cyan
Write-Host "   ██████  ██████  ██   ██ ██████     ██    " -ForegroundColor Cyan
Write-Host ""
Write-Host "  The Frankenstein of AI Coding" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Detect system capabilities ──────────────────────────

Write-Host "[1/5] Detecting system capabilities..." -ForegroundColor White

$QuantFeatures = "cpu"
$BackendMsg = "CPU (SIMD)"

# Check for NVIDIA CUDA
try {
    $nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
    if ($nvidiaSmi) {
        $gpuName = & nvidia-smi --query-gpu=name --format=csv,noheader 2>$null | Select-Object -First 1
        if ($gpuName) {
            Write-Status "ok" "NVIDIA GPU detected: $gpuName"
            $QuantFeatures = "cuda,cpu"
            $BackendMsg = "CUDA + CPU"
        }
    }
} catch {
    # nvidia-smi not available
}

if ($QuantFeatures -eq "cpu") {
    Write-Status "warn" "No NVIDIA GPU detected — using CPU with SIMD"
}

# Check for AVX2 support
try {
    $cpuInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
    # AVX2 is present on Intel Haswell+ (2013) and AMD Excavator+ (2015)
    Write-Status "ok" "CPU: $($cpuInfo.Name.Trim())"
} catch {
    Write-Status "warn" "Could not detect CPU info"
}

Write-Status "info" "Compression backend: $BackendMsg"

# ── Step 2: Install Rust crate ──────────────────────────────────

Write-Host ""
Write-Host "[2/5] Building gbaby-quant (Rust)..." -ForegroundColor White

$cargoCmd = Get-Command cargo -ErrorAction SilentlyContinue
if ($cargoCmd) {
    $rustVersion = & rustc --version 2>$null
    Write-Status "ok" "Rust toolchain found: $rustVersion"

    Push-Location (Split-Path $PSScriptRoot -Parent)
    try {
        & cargo build --release -p gbaby-quant --features $QuantFeatures 2>&1 | Select-Object -Last 3
        Write-Status "ok" "gbaby-quant built with features: $QuantFeatures"
    } catch {
        Write-Status "fail" "Cargo build failed: $_"
        exit 1
    } finally {
        Pop-Location
    }
} else {
    Write-Status "fail" "Rust not found. Install from https://rustup.rs"
    Write-Host "    Run: winget install Rustlang.Rustup" -ForegroundColor Gray
    exit 1
}

# ── Step 3: Install Node dependencies (Graphify) ───────────────

Write-Host ""
Write-Host "[3/5] Installing Graphify..." -ForegroundColor White

$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if ($npmCmd) {
    Push-Location (Split-Path $PSScriptRoot -Parent)
    try {
        & npm install --silent 2>&1 | Select-Object -Last 1
        Write-Status "ok" "Graphify installed"
    } finally {
        Pop-Location
    }
} else {
    Write-Status "fail" "Node.js not found. Install from https://nodejs.org"
    Write-Host "    Run: winget install OpenJS.NodeJS.LTS" -ForegroundColor Gray
    exit 1
}

# ── Step 4: Initialize knowledge graph ────���─────────────────────

Write-Host ""
Write-Host "[4/5] Initializing knowledge graph..." -ForegroundColor White

$projectRoot = Split-Path $PSScriptRoot -Parent
$graphReport = Join-Path $projectRoot "graph\GRAPH_REPORT.md"

if (Test-Path $graphReport) {
    Write-Status "warn" "Graph already exists — run 'npm run graph:sync' to update"
} else {
    Push-Location $projectRoot
    try {
        & npx graphify init 2>&1 | Select-Object -Last 3
        Write-Status "ok" "Knowledge graph initialized"
    } catch {
        Write-Status "warn" "Graphify init skipped (run manually: npm run graph:init)"
    } finally {
        Pop-Location
    }
}

# ── Step 5: Set up brain directory ──────────────────────────────

Write-Host ""
Write-Host "[5/5] Setting up GBrain..." -ForegroundColor White

$brainDir = Join-Path $projectRoot "brain"
$brainDirs = @("people", "decisions", "ideas", "meetings")
foreach ($dir in $brainDirs) {
    $path = Join-Path $brainDir $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}
Write-Status "ok" "Brain directories created"

# ── Done ─────────────���──────────────────────────────────────────

Write-Host ""
Write-Host "GBaby is alive." -ForegroundColor Green
Write-Host ""
Write-Host "  Backend:  $BackendMsg"
Write-Host "  Brain:    brain\"
Write-Host "  Graph:    npm run graph:sync"
Write-Host "  Config:   gbaby.toml"
Write-Host ""
Write-Host "  Next: Run " -NoNewline
Write-Host ".\scripts\doctor.ps1" -ForegroundColor White -NoNewline
Write-Host " to verify everything works."
Write-Host ""
