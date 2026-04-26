# GBaby — Codex (OpenAI) Integration

> **Status: Scaffolded, not yet battle-tested.** The config and role prompts are
> ready but haven't been validated end-to-end with Codex CLI. Want to help test?
> See the Tip Jar in README.md — credit donations for "codex testing" go
> directly to API credits for validation.

## Setup

1. Run `bash scripts/setup.sh` (shared across all platforms)
2. Copy the Codex instructions file:

```bash
cp integrations/codex/codex_instructions.md AGENTS.md
```

3. Codex reads `AGENTS.md` as its project-level system prompt, which wires in
   the GBaby stack context.

## How it works

Codex operates in a sandboxed environment. The integration works by:

1. `AGENTS.md` tells Codex about the GBaby stack and where to find context
2. Codex reads `graph/GRAPH_REPORT.md` for codebase understanding
3. Codex reads `brain/` for institutional memory
4. Role prompts in `stack/roles/` guide behavior for specific tasks

## Known gaps

- Codex sandbox restrictions may limit brain/ write operations
- GStack roles reference Claude Code-specific features — need Codex equivalents
- Auto-graph-sync needs to be triggered manually or via a pre-task hook
- Codex tool-use format differs from Claude — role prompts may need adaptation
