#!/usr/bin/env bash
set -euo pipefail

# GBaby Benchmark Runner
# Measures token usage across configurations: baseline, graphify, full gbaby

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

RESULTS_DIR="$(dirname "$0")/results"
mkdir -p "$RESULTS_DIR"

REPO="${1:-}"
TASK="${2:-}"
CONFIG="${3:-}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

usage() {
    echo "Usage: bash benchmarks/run.sh [--repo REPO] [--task TASK] [--config CONFIG]"
    echo ""
    echo "  --repo      small | medium | large | analytics-sdk"
    echo "  --task      review | feature | bug | architecture | refactor"
    echo "  --config    baseline | graphify | full"
    echo ""
    echo "Omit all flags to run the full benchmark matrix."
    exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo) REPO="$2"; shift 2 ;;
        --task) TASK="$2"; shift 2 ;;
        --config) CONFIG="$2"; shift 2 ;;
        --help|-h) usage ;;
        *) shift ;;
    esac
done

# Task prompts
declare -A TASKS
TASKS[review]="Review the most recent commit for bugs, security issues, and style problems. Be specific about file and line numbers."
TASKS[feature]="Add rate limiting to the main API endpoint. Limit to 100 requests per minute per IP."
TASKS[bug]="Investigate why the test suite has any failing tests. Identify the root cause."
TASKS[architecture]="Explain how the main request handling pipeline works, from HTTP request to response."
TASKS[refactor]="Identify the largest function in the codebase and extract it into smaller, well-named functions."

run_benchmark() {
    local repo="$1"
    local task="$2"
    local config="$3"
    local prompt="${TASKS[$task]}"
    local result_file="$RESULTS_DIR/${repo}_${task}_${config}_$(date +%s).json"

    echo -e "${BOLD}Running:${NC} repo=${CYAN}$repo${NC} task=${CYAN}$task${NC} config=${CYAN}$config${NC}"

    local extra_context=""
    case $config in
        baseline)
            extra_context=""
            ;;
        graphify)
            if [[ -f "graph/GRAPH_REPORT.md" ]]; then
                extra_context="First read graph/GRAPH_REPORT.md to understand the codebase structure before proceeding. "
            else
                echo "  WARNING: No GRAPH_REPORT.md found. Run 'npm run graph:init' first."
                return 1
            fi
            ;;
        full)
            extra_context="First read graph/GRAPH_REPORT.md for codebase structure. Then check brain/decisions/ for past decisions. Then read the relevant role from stack/roles/. "
            ;;
    esac

    local full_prompt="${extra_context}${prompt}"

    # Run claude with JSON output to capture token usage
    # --output-format json gives us usage stats
    local output
    output=$(claude --print --output-format json -p "$full_prompt" 2>/dev/null) || {
        echo "  ERROR: claude command failed. Is Claude Code installed?"
        return 1
    }

    # Extract token counts from JSON output
    local input_tokens output_tokens
    input_tokens=$(echo "$output" | jq -r '.usage.input_tokens // .input_tokens // "unknown"' 2>/dev/null || echo "unknown")
    output_tokens=$(echo "$output" | jq -r '.usage.output_tokens // .output_tokens // "unknown"' 2>/dev/null || echo "unknown")

    # Write result
    cat > "$result_file" <<RESULT_EOF
{
  "repo": "$repo",
  "task": "$task",
  "config": "$config",
  "input_tokens": $input_tokens,
  "output_tokens": $output_tokens,
  "quality_score": null,
  "timestamp": "$TIMESTAMP"
}
RESULT_EOF

    echo -e "  ${GREEN}Done${NC} → $result_file (in: $input_tokens, out: $output_tokens)"
}

# If specific args given, run single benchmark
if [[ -n "$REPO" && -n "$TASK" && -n "$CONFIG" ]]; then
    run_benchmark "$REPO" "$TASK" "$CONFIG"
    exit 0
fi

# Otherwise run full matrix
echo -e "${BOLD}${CYAN}GBaby Benchmark Suite${NC}"
echo ""

CONFIGS=("baseline" "graphify" "full")
TASK_LIST=("review" "architecture" "bug")

for config in "${CONFIGS[@]}"; do
    for task in "${TASK_LIST[@]}"; do
        run_benchmark "analytics-sdk" "$task" "$config" || true
        echo ""
    done
done

echo -e "${BOLD}${GREEN}Benchmarks complete.${NC} Results in $RESULTS_DIR/"
echo ""
echo "To summarize results:"
echo "  jq -s 'group_by(.config) | map({config: .[0].config, avg_input: (map(.input_tokens) | add / length)})' $RESULTS_DIR/*.json"
