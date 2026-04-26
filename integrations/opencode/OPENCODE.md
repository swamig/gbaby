# GBaby — OpenCode Integration

> **Status: Scaffolded, not yet battle-tested.** OpenCode's model-agnostic design
> makes it the natural fit for running GBaby with self-hosted vLLM + TurboQuant
> or cheap providers like Groq. Help us test — see [Tip Jar](../../README.md#tip-jar).

## Why OpenCode + GBaby

OpenCode supports 75+ LLM providers. That means you can:

1. Point it at a self-hosted vLLM with TurboQuant enabled → full compression stack
2. Point it at Groq ($0.59/M tok for Llama 70B) → cheapest hosted inference
3. Point it at Ollama → completely free, runs on your laptop
4. Still get GBaby's Graphify (49x fewer tokens), GBrain (memory), and GStack (agent roles)

This is **the zero-cost path to the full GBaby stack**.

## Setup

1. Install OpenCode: https://opencode.ai
2. Run `npx gbaby setup` (shared across all platforms)
3. Configure OpenCode to use your preferred provider
4. Copy the instructions file:

```bash
cp integrations/opencode/opencode_instructions.md AGENTS.md
```

## Provider examples

### Self-hosted vLLM + TurboQuant (full stack)

```bash
# Terminal 1: Start vLLM with TurboQuant
vllm serve meta-llama/Llama-3.1-70B --kv-cache-dtype turboquant_k3v4

# Terminal 2: Point OpenCode at it
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=dummy
opencode
```

### Groq (cheapest hosted)

```bash
export OPENAI_API_BASE=https://api.groq.com/openai/v1
export OPENAI_API_KEY=your-groq-key
opencode
```

### Ollama (free, local)

```bash
ollama serve  # Terminal 1
export OPENAI_API_BASE=http://localhost:11434/v1
opencode      # Terminal 2
```

## Known gaps

- GStack role prompts reference Claude Code-specific features — need OpenCode equivalents
- OpenCode's TUI handles file edits differently from Claude Code
- Auto-graph-sync via hooks isn't wired for OpenCode yet
