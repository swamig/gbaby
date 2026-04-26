# GBaby — Gemini CLI Integration

> **Status: Scaffolded, not yet battle-tested.** The config and role prompts are
> ready but haven't been validated end-to-end on Gemini CLI. Want to help test?
> See the Tip Jar in README.md — credit donations for "gemini testing" go
> directly to API credits for validation.

## Setup

1. Run `bash scripts/setup.sh` (shared across all platforms)
2. Copy this directory's config into your Gemini CLI workspace:

```bash
cp integrations/gemini/gemini_config.json ~/.gemini/config.json
```

3. The knowledge graph and brain are platform-agnostic — Gemini reads the same
   `graph/GRAPH_REPORT.md` and `brain/` directories as Claude.

## System instruction

Add to your Gemini system prompt:

```
Before starting any task, read graph/GRAPH_REPORT.md for codebase structure
and check brain/decisions/ for relevant past decisions. Role prompts are in
stack/roles/. Persist new knowledge to brain/ using templates in brain/templates/.
```

## Known gaps

- GStack role prompts reference Claude Code-specific features (skills, hooks) —
  these need Gemini equivalents
- Auto-graph-sync via hooks isn't wired for Gemini yet
- Brain persistence relies on agent file-write capability
