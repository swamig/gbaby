# GBaby — Aider Integration

> **Status: Scaffolded, not yet battle-tested.** Aider's git-first workflow pairs
> well with GBaby's knowledge graph — every AI edit becomes a reviewable commit
> backed by codebase understanding. Help us test — see [Tip Jar](../../README.md#tip-jar).

## Why Aider + GBaby

Aider auto-commits every AI edit to git. Combined with GBaby:

- **Graphify** → Aider reads the knowledge graph before editing, so it understands
  the dependency chain *before* touching a file
- **GBrain** → Past decisions inform Aider's approach (it won't re-introduce a
  pattern that was already rejected)
- **TurboQuant** → When using a self-hosted model, inference is 6x more memory-efficient

## Setup

1. Install Aider: `pip install aider-chat`
2. Run `npx gbaby setup`
3. Add the GBaby conventions file to Aider's context:

```bash
aider --read integrations/aider/aider_conventions.md
```

Or add to `.aider.conf.yml`:

```yaml
read:
  - integrations/aider/aider_conventions.md
  - graph/GRAPH_REPORT.md
```

## Provider examples

### Self-hosted vLLM + TurboQuant

```bash
aider --openai-api-base http://localhost:8000/v1 --model openai/meta-llama/Llama-3.1-70B
```

### Groq

```bash
export GROQ_API_KEY=your-key
aider --model groq/llama-3.3-70b-versatile
```

### Ollama (free)

```bash
aider --model ollama/llama3.1:70b
```

## Known gaps

- Aider's repo-map may overlap with Graphify — need to benchmark whether
  disabling repo-map in favor of GRAPH_REPORT.md saves tokens
- GStack role prompts aren't triggered automatically in Aider — need `/commands`
- Brain persistence requires manual file creation (Aider doesn't have hooks)
