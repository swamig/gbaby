# GBaby — Claude Code Integration

This project uses the GBaby stack: GStack (agent roles) + GBrain (persistent memory) + Graphify (code knowledge graph) + TurboQuant (compression).

## Before starting any task

1. Read `graph/GRAPH_REPORT.md` to understand the codebase structure
2. Check `brain/decisions/` for relevant past decisions
3. Check `brain/people/` if the task involves a specific person or team

## Agent roles

Role-specific prompts are in `stack/roles/`. When reviewing code, consult the relevant role:
- `stack/roles/ceo.md` — strategic alignment
- `stack/roles/eng-manager.md` — code quality and architecture
- `stack/roles/qa.md` — testing and edge cases

## Configuration

All GBaby settings are in `gbaby.toml` at the project root.

## Knowledge persistence

When you learn something important during a session (a decision, a person's role, an idea), persist it:
- Decisions → `brain/decisions/YYYY-MM-DD-title.md`
- People → `brain/people/name.md`
- Ideas → `brain/ideas/title.md`

Use the templates in `brain/templates/`.
