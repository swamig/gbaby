# GBaby Benchmarks

Reproducible token usage benchmarks across repo sizes and configurations.

## Methodology

Each benchmark runs an identical coding task three ways:

1. **Baseline** — raw Claude Code, no GBaby
2. **Graphify only** — knowledge graph loaded, no GBrain
3. **Full GBaby** — Graphify + GBrain + GStack role

We measure:
- **Input tokens** (what we send)
- **Output tokens** (what we get back)
- **Total cost** (at the provider's rate)
- **Task quality** (manual 1-10 score on correctness and completeness)

## Test repos

| Repo | Files | Language | Size category |
|---|---|---|---|
| Small open-source lib | ~10-20 files | TypeScript | Small |
| Mid-size API server | ~50-100 files | Rust/Python | Medium |
| Large monorepo | ~1,000+ files | Mixed | Large |
| analytics-sdk (our own) | ~200+ files | Rust + TS | Medium-large |

## Test tasks

Each task is run on each repo in each configuration:

1. **Code review** — "Review the most recent PR for bugs and style issues"
2. **Feature addition** — "Add rate limiting to the main API endpoint"
3. **Bug investigation** — "Find why [specific test] is failing"
4. **Architecture question** — "Explain how the auth system works"
5. **Refactor** — "Extract [function] into its own module"

## Running benchmarks

```bash
# Prerequisites
npx gbaby setup

# Run all benchmarks
bash benchmarks/run.sh

# Run a single benchmark
bash benchmarks/run.sh --repo small --task review --config baseline
bash benchmarks/run.sh --repo small --task review --config graphify
bash benchmarks/run.sh --repo small --task review --config full
```

## Results

Results are written to `benchmarks/results/` as JSON:

```json
{
  "repo": "analytics-sdk",
  "task": "code-review",
  "config": "graphify",
  "input_tokens": 15200,
  "output_tokens": 2100,
  "total_tokens": 17300,
  "quality_score": null,
  "baseline_tokens": 123000,
  "reduction_factor": 8.1,
  "timestamp": "2026-04-27T10:00:00Z"
}
```

## Status

**Not yet run.** We need API credits to execute these benchmarks across
all configurations. See the [Tip Jar](../README.md#tip-jar) if you'd
like to help fund benchmark runs.

The benchmark harness is ready — we just need to pull the trigger.
