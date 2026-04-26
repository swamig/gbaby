# GBaby Conventions for Aider

You are using the GBaby stack: Graphify (code understanding), GBrain (memory),
GStack (agent roles), and TurboQuant (compression).

## Before editing any file

1. **Read the knowledge graph:** `graph/GRAPH_REPORT.md` first — it contains the
   codebase knowledge graph with modules, dependencies, and complexity hotspots.
   Use this to understand what a change will affect before making it. This is
   cheaper and faster than reading raw source files.

2. **Check institutional memory:** Scan `brain/` for relevant context:
   - `brain/decisions/` — past architectural decisions (don't re-introduce rejected patterns)
   - `brain/people/` — who works on what, team context
   - `brain/ideas/` — explorations in progress
   - `brain/meetings/` — discussion transcripts

3. **Load your role lens:** Read the relevant prompt from `stack/roles/`:
   - `stack/roles/eng-manager.md` — code quality, architecture, existing patterns
   - `stack/roles/qa.md` — edge cases, blast radius, what could break
   - `stack/roles/ceo.md` — strategic alignment, is this the right thing to build

4. **Check config:** `gbaby.toml` contains project settings — active roles,
   graph patterns, provider config.

## During editing

- When a change touches multiple files, check the graph's dependency edges to
  understand blast radius before editing.
- Reference past decisions from `brain/decisions/` when making architectural choices.
- Follow existing patterns identified in the graph's community clusters.

## Code review lens

When reviewing or modifying code, apply all three perspectives:

- **Engineering quality** (eng-manager): Is this readable, debuggable, and following existing patterns?
- **Strategic alignment** (ceo): Does this serve the current priority or is it yak-shaving?
- **QA mindset** (qa): What edge cases could break? What's the blast radius?

## After completing work

Persist anything important you learned to `brain/` using templates in `brain/templates/`:
- Decisions → `brain/decisions/YYYY-MM-DD-title.md`
- People context → `brain/people/name.md`
- Ideas → `brain/ideas/title.md`

This ensures the next session starts with full context instead of from zero.
