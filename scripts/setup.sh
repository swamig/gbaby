#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}"
echo "   ██████  ██████   █████  ██████  ██    ██ "
echo "  ██       ██   ██ ██   ██ ██   ██  ██  ██  "
echo "  ██   ███ ██████  ███████ ██████    ████   "
echo "  ██    ██ ██   ██ ██   ██ ██   ██    ██    "
echo "   ██████  ██████  ██   ██ ██████     ██    "
echo ""
echo "  The Frankenstein of AI Coding"
echo -e "${NC}"

# ── Step 1: Detect system capabilities ──────────────────────────

echo -e "${BOLD}[1/5] Detecting system capabilities...${NC}"

QUANT_FEATURES="cpu"
BACKEND_MSG="CPU (SIMD)"

# Check for NVIDIA CUDA
if command -v nvidia-smi &>/dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    echo -e "  ${GREEN}✓${NC} NVIDIA GPU detected: ${GPU_NAME}"
    QUANT_FEATURES="all"
    BACKEND_MSG="CUDA + Metal fallback + CPU"
elif command -v nvcc &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} CUDA toolkit detected"
    QUANT_FEATURES="cuda,cpu"
    BACKEND_MSG="CUDA + CPU"
else
    echo -e "  ${YELLOW}○${NC} No NVIDIA GPU detected"
fi

# Check for Apple Metal
if [[ "$(uname)" == "Darwin" ]]; then
    if system_profiler SPDisplaysDataType 2>/dev/null | grep -q "Apple M"; then
        echo -e "  ${GREEN}✓${NC} Apple Silicon detected (Metal available)"
        if [[ "$QUANT_FEATURES" == "cpu" ]]; then
            QUANT_FEATURES="metal,cpu"
            BACKEND_MSG="Metal + CPU"
        fi
    else
        echo -e "  ${YELLOW}○${NC} Intel Mac — using CPU with AVX2 SIMD"
    fi
fi

echo -e "  ${CYAN}→${NC} Compression backend: ${BOLD}${BACKEND_MSG}${NC}"

# ── Step 2: Install Rust crate ──────────────────────────────────

echo ""
echo -e "${BOLD}[2/5] Building gbaby-quant (Rust)...${NC}"

if command -v cargo &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Rust toolchain found: $(rustc --version)"
    (cd "$(dirname "$0")/.." && cargo build --release -p gbaby-quant --features "$QUANT_FEATURES" 2>&1 | tail -3)
    echo -e "  ${GREEN}✓${NC} gbaby-quant built with features: ${QUANT_FEATURES}"
else
    echo -e "  ${RED}✗${NC} Rust not found. Install from https://rustup.rs"
    echo "    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# ── Step 3: Install Node dependencies (Graphify) ───────────────

echo ""
echo -e "${BOLD}[3/5] Installing Graphify...${NC}"

if command -v npm &>/dev/null; then
    (cd "$(dirname "$0")/.." && npm install --silent 2>&1 | tail -1)
    echo -e "  ${GREEN}✓${NC} Graphify installed"
else
    echo -e "  ${RED}✗${NC} Node.js not found. Install from https://nodejs.org"
    exit 1
fi

# ── Step 4: Initialize knowledge graph ──────────────────────────

echo ""
echo -e "${BOLD}[4/5] Initializing knowledge graph...${NC}"

if [[ -f "$(dirname "$0")/../graph/GRAPH_REPORT.md" ]]; then
    echo -e "  ${YELLOW}○${NC} Graph already exists — run 'npm run graph:sync' to update"
else
    (cd "$(dirname "$0")/.." && npx graphify init 2>&1 | tail -3) || true
    echo -e "  ${GREEN}✓${NC} Knowledge graph initialized"
fi

# ── Step 5: Set up brain directory ──────────────────────────────

echo ""
echo -e "${BOLD}[5/5] Setting up GBrain...${NC}"

BRAIN_DIR="$(dirname "$0")/../brain"
mkdir -p "$BRAIN_DIR"/{people,decisions,ideas,meetings}
echo -e "  ${GREEN}✓${NC} Brain directories created"

# ── Done ────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${GREEN}GBaby is alive.${NC}"
echo ""
echo -e "  Backend:  ${BACKEND_MSG}"
echo -e "  Brain:    brain/"
echo -e "  Graph:    npm run graph:sync"
echo -e "  Config:   gbaby.toml"
echo ""
echo -e "  ${CYAN}Next:${NC} Run ${BOLD}bash scripts/doctor.sh${NC} to verify everything works."
echo ""
