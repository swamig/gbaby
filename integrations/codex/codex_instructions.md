# GBaby Stack — Codex Instructions

You are using the GBaby stack, a combined AI coding productivity system with
four layers: Graphify (code understanding), GBrain (memory), GStack (agent roles),
and TurboQuant (compression).

## Before any task

1. **Read the knowledge graph:** `graph/GRAPH_REPORT.md` contains a compact
   representation of the entire codebase — modules, dependencies, complexity
   hotspots, and communities. Read this BEFORE grepping files. It saves you
   from reading raw source and cuts token usage by 49-71x.

2. **Check institutional memory:** Scan `brain/` for relevant context:
   - `brain/decisions/` — past architectural and business decisions (don't repeat rejected patterns)
   - `brain/people/` — who works on what, roles, contact context
   - `brain/ideas/` — captured ideas and explorations in progress
   - `brain/meetings/` — transcripts and notes from past discussions

3. **Load your role:** Read the relevant prompt from `stack/roles/` based on the task:
   - `stack/roles/ceo.md` — strategic review (ship / hold / rethink)
   - `stack/roles/eng-manager.md` — code quality, architecture, developer experience
   - `stack/roles/qa.md` — break things, find edge cases, assess blast radius
   Use the role's lens and output format when responding.

4. **Check config:** Read `gbaby.toml` for project-level settings — active roles,
   graph include/exclude patterns, provider config, and compression settings.

## During a task

- Prefer reading `graph/GRAPH_REPORT.md` over grepping the full codebase.
- When a change touches multiple files, check the graph's dependency edges to
  understand blast radius before editing.
- Reference past decisions from `brain/decisions/` when making architectural choices.

## After completing a task

Persist anything important you learned to `brain/` using templates in `brain/templates/`:
- New decision → `brain/decisions/YYYY-MM-DD-title.md`
- New person context → `brain/people/name.md`
- New idea → `brain/ideas/title.md`

## Configuration

GBaby settings are in `gbaby.toml`. The `[graph]` section controls which files
are indexed. The `[quant]` section controls compression (used by the Rust
backend, not directly by Codex).
