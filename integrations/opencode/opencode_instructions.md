# GBaby Stack — OpenCode Instructions

You are using the GBaby stack, a combined AI coding productivity system.

## Before any task

1. **Read the knowledge graph:** `graph/GRAPH_REPORT.md` contains a compact
   representation of the entire codebase — modules, dependencies, complexity
   hotspots, and communities. Read this BEFORE grepping files.

2. **Check institutional memory:** `brain/decisions/` contains past architectural
   and business decisions. `brain/people/` contains context about team members.

3. **Consult your role:** Role-specific prompts in `stack/roles/` define how to
   approach different types of tasks (CEO review, QA testing, eng management).

## After completing a task

If you learned something important (a new decision, a person's role, an idea),
persist it to `brain/` using the templates in `brain/templates/`.

## Configuration

GBaby settings are in `gbaby.toml`. The `[provider]` section controls which LLM
backend is used. The `[graph]` section controls which files are indexed.
