# GBaby Conventions for Aider

## Before editing any file

1. Read `graph/GRAPH_REPORT.md` first — it contains the codebase knowledge graph
   with modules, dependencies, and complexity hotspots. Use this to understand
   what a change will affect before making it.

2. Check `brain/decisions/` for past architectural decisions related to the area
   you're about to modify. Don't re-introduce patterns that were already rejected.

3. Check `brain/people/` if the task involves a specific person or team context.

## Code review lens

When reviewing or modifying code, consider these perspectives (from `stack/roles/`):

- **Engineering quality:** Is this readable, debuggable, and following existing patterns?
- **Strategic alignment:** Does this serve the current priority or is it yak-shaving?
- **QA mindset:** What edge cases could break? What's the blast radius?

## After completing work

If you learned something important during the session, create a note:
- Decisions → `brain/decisions/YYYY-MM-DD-title.md`
- People context → `brain/people/name.md`
- Ideas → `brain/ideas/title.md`

Templates are in `brain/templates/`.
