# GBaby Brain

This directory is your persistent knowledge base — powered by GBrain.

## Structure

```
brain/
  templates/     # Markdown templates for new entries
  people/        # People you work with
  decisions/     # Architectural and business decisions
  ideas/         # Captured ideas and explorations
  meetings/      # Meeting transcripts and notes
```

## Usage

GBaby's Claude Code integration auto-loads brain entries into agent context.
Create new entries from templates:

```bash
cp brain/templates/person.md brain/people/jane-doe.md
# Edit the file, filling in the {{placeholders}}
```

Or let the agent create them during conversation — it will persist knowledge
here automatically via GBrain's cron sync.
