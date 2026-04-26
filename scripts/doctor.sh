#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BOLD}GBaby Doctor${NC}"
echo ""

ISSUES=0

check() {
    local label="$1"
    local cmd="$2"
    local fix="$3"

    if eval "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} ${label}"
    else
        echo -e "  ${RED}✗${NC} ${label}"
        echo -e "    Fix: ${fix}"
        ISSUES=$((ISSUES + 1))
    fi
}

echo -e "${BOLD}System${NC}"
check "Rust toolchain" "command -v cargo" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
check "Node.js" "command -v node" "https://nodejs.org"
check "npm" "command -v npm" "Installed with Node.js"
check "Claude Code" "command -v claude" "npm install -g @anthropic-ai/claude-code"

echo ""
echo -e "${BOLD}GPU / Acceleration${NC}"

if command -v nvidia-smi &>/dev/null; then
    GPU=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    echo -e "  ${GREEN}✓${NC} NVIDIA GPU: ${GPU}"
elif [[ "$(uname)" == "Darwin" ]] && system_profiler SPDisplaysDataType 2>/dev/null | grep -q "Apple M"; then
    CHIP=$(system_profiler SPHardwareDataType 2>/dev/null | grep "Chip" | awk -F': ' '{print $2}')
    echo -e "  ${GREEN}✓${NC} Apple Silicon: ${CHIP} (Metal)"
else
    echo -e "  ${YELLOW}○${NC} No GPU detected — CPU mode (still fast)"
fi

# Check AVX2 on Intel
if [[ "$(uname)" == "Darwin" ]] && sysctl -n machdep.cpu.features 2>/dev/null | grep -q AVX2; then
    echo -e "  ${GREEN}✓${NC} AVX2 SIMD available"
elif [[ "$(uname)" == "Linux" ]] && grep -q avx2 /proc/cpuinfo 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} AVX2 SIMD available"
fi

echo ""
echo -e "${BOLD}GBaby Components${NC}"
check "gbaby-quant (Rust crate)" "test -f target/release/libgbaby_quant.rlib || test -f target/release/libgbaby_quant.dylib || cargo check -p gbaby-quant 2>/dev/null" "bash scripts/setup.sh"
check "Graphify (npm)" "test -d node_modules/graphify || npm list graphify 2>/dev/null" "npm install"
check "gbaby.toml config" "test -f gbaby.toml" "cp gbaby.toml.example gbaby.toml"
check "Brain directory" "test -d brain/people" "bash scripts/setup.sh"

echo ""
echo -e "${BOLD}Knowledge Graph${NC}"
if [[ -f "graph/GRAPH_REPORT.md" ]]; then
    echo -e "  ${GREEN}✓${NC} Graph exists"
    NODES=$(grep -c "^-" graph/GRAPH_REPORT.md 2>/dev/null || echo "?")
    echo -e "    ${NODES} nodes indexed"
else
    echo -e "  ${YELLOW}○${NC} No graph yet — run: npm run graph:init"
fi

echo ""
if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All healthy. The monster is alive.${NC}"
else
    echo -e "${RED}${BOLD}${ISSUES} issue(s) found. Fix them and run doctor again.${NC}"
fi
