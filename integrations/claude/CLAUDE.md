# GBaby — Claude Code Integration

This project uses the GBaby stack: Graphify (code understanding) + GBrain
(persistent memory) + GStack (agent roles) + TurboQuant (compression).

## Before starting any task

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

- Prefer reading `graph/GRAPH_REPORT.md` over grepping the full codebase. Only
  fall back to raw file reads when the graph doesn't have the detail you need.
- When a change touches multiple files, check the graph's dependency edges to
  understand blast radius before editing.
- Reference past decisions from `brain/decisions/` when making architectural choices.

## Knowledge persistence

After completing a task, persist anything important you learned to `brain/`:
- Decisions → `brain/decisions/YYYY-MM-DD-title.md`
- People → `brain/people/name.md`
- Ideas → `brain/ideas/title.md`

Use the templates in `brain/templates/`. This ensures the next session starts
with full context instead of from zero.

## Configuration

All GBaby settings are in `gbaby.toml` at the project root.
