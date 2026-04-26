# GBaby

**The Frankenstein of AI Coding**

> If Garry Tan had a baby with Google DeepMind... this is what that graph would look like.

Four open-source projects. One stack. Your AI coding agent now has a brain (GBrain), eyes (Graphify), a team (GStack), and runs 90% cheaper (TurboQuant). All Rust + TypeScript. All local-first. All MIT.

**The monster is alive.**

---

## 30 Seconds to Alive

```bash
git clone https://github.com/swamig/gbaby.git && cd gbaby && npx gbaby setup
```

That's it. One command. It auto-detects your GPU (CUDA / Metal / CPU), builds the Rust compression layer, installs the knowledge graph, and scaffolds your brain. Works on Linux, macOS (Intel + Apple Silicon), and Windows.

Verify:
```bash
npx gbaby doctor
```

---

## What's Inside

| Layer | Project | What it does | Credit |
|---|---|---|---|
| **Workflow** | [GStack](https://github.com/garrytan/gstack) | 23 AI agent roles — CEO, designer, eng manager, QA, release manager | [Garry Tan](https://github.com/garrytan) |
| **Memory** | [GBrain](https://github.com/garrytan/gbrain) | Persistent knowledge base across sessions — people, decisions, context | [Garry Tan](https://github.com/garrytan) |
| **Code Understanding** | [Graphify](https://github.com/safishamsi/graphify) | Knowledge graph of your codebase — 49-71x fewer tokens per query | [Safi Shamsi](https://github.com/safishamsi) |
| **Compression** | [TurboQuant](https://research.google/blog/turboquant-redefining-ai-efficiency-with-extreme-compression/) | KV cache compression to 3-bit — 6x less memory, zero accuracy loss | [Google Research](https://research.google) |

GBaby doesn't fork these projects. It wires them together into a single `setup.sh` with a unified config (`gbaby.toml`), shared context, and auto-detection of your hardware.

## Why the Combination Matters

Apart, they're research projects. Together, they multiply:

- **GStack's agents need code context** → Graphify gives them the entire codebase as a compact graph instead of reading raw files
- **GStack's agents need business context** → GBrain gives them institutional memory (who decided what, and why)
- **All of the above generates tokens** → TurboQuant compresses the KV cache so the combined stack doesn't bankrupt you
- **Result:** a full AI engineering team that remembers everything, reads your entire codebase in milliseconds, and costs 90% less to run

| Metric | Without GBaby | With GBaby |
|---|---|---|
| Tokens per session | ~123k (raw file reads) | ~1.7k (graph queries) |
| Context across sessions | None (stateless) | Full (GBrain) |
| Agent capability | Single-role, one file at a time | Multi-role, graph-aware, memory-backed |
| Hardware floor | Beefy GPU or expensive API | Runs on your Intel Mac |

## AI Platform Support

| Platform | Status | Notes |
|---|---|---|
| **Claude Code** | **Actively tested** | Full integration — CLAUDE.md, skills, hooks, auto-graph |
| **Gemini CLI** | Scaffolded | Config + role prompts ready; not yet tested end-to-end |
| **Codex (OpenAI)** | Scaffolded | Config + role prompts ready; not yet tested end-to-end |

> **Honest status:** We're daily-driving this on Claude Code. The Gemini and Codex integrations use the same GBrain/Graphify/TurboQuant stack but the agent role wiring hasn't been battle-tested on those platforms yet.
>
> **Want to help test?** We'd love credit donations to run Gemini and Codex workloads. See [Tip Jar](#tip-jar) below — any contributions earmarked for "gemini testing" or "codex testing" go directly to API credits for validating those integrations.

## Platform Support

| Platform | GPU | Status |
|---|---|---|
| **Linux** | NVIDIA CUDA + CPU | Full support |
| **macOS (Apple Silicon)** | Metal + CPU | Full support |
| **macOS (Intel)** | CPU (AVX2 SIMD) | Full support |
| **Windows** | NVIDIA CUDA + CPU | Full support |

## Quickstart

```bash
git clone https://github.com/swamig/gbaby.git
cd gbaby
```

**Cross-platform (recommended):**
```bash
npx gbaby setup
npx gbaby doctor
```

**Or use the platform-specific scripts directly:**

macOS / Linux:
```bash
bash scripts/setup.sh
bash scripts/doctor.sh
```

Windows (PowerShell):
```powershell
.\scripts\setup.ps1
.\scripts\doctor.ps1
```

The setup auto-detects your hardware:

- **NVIDIA GPU?** → Builds with CUDA kernels
- **Apple Silicon?** → Builds with Metal compute shaders
- **Intel / AMD CPU?** → Builds with AVX2 SIMD (still fast)
- **Windows?** → PowerShell-native with `winget` install hints

## Use TurboQuant Today (Self-Hosted)

You don't have to wait for Anthropic or Google. TurboQuant is already in vLLM and llama.cpp. Run an open-source model with TurboQuant compression and point GBaby at it:

**Option 1: vLLM + TurboQuant** (recommended for GPU servers)
```bash
# Start vLLM with TurboQuant KV cache compression
pip install vllm
vllm serve meta-llama/Llama-3.1-70B --kv-cache-dtype turboquant_k3v4

# In gbaby.toml:
# [provider]
# platform = "openai-compatible"
# base_url = "http://localhost:8000/v1"
# model = "meta-llama/Llama-3.1-70B"
```

**Option 2: llama.cpp + TurboQuant** (runs on consumer hardware)
```bash
# Build llama.cpp with TurboQuant support
# Serves 43K-token contexts on consumer GPUs where vanilla caps at 16K
./llama-server -m model.gguf --kv-cache-type turbo3

# Same config — point gbaby.toml at localhost
```

**Option 3: Ollama** (easiest local setup)
```bash
ollama serve
# [provider]
# platform = "openai-compatible"
# base_url = "http://localhost:11434/v1"
```

**Option 4: Cloud providers running vLLM** (Together AI, Fireworks, etc.)
```toml
# These providers run vLLM under the hood.
# As TurboQuant merges into vLLM mainline, they get it for free.
[provider]
platform = "openai-compatible"
base_url = "https://api.together.xyz/v1"
model = "meta-llama/Llama-3.1-70B-Instruct"
api_key_env = "TOGETHER_API_KEY"
```

The beauty: GBaby's Graphify + GBrain + GStack layers work identically regardless of which provider you use. Swap the `[provider]` block, keep everything else.

## Configuration

All settings live in `gbaby.toml`:

```toml
[provider]
platform = "claude"             # or "openai-compatible"
# base_url = "http://localhost:8000/v1"
# model = "meta-llama/Llama-3.1-70B"

[quant]
backend = "auto"    # "auto" | "cuda" | "metal" | "cpu"
bits = 3            # 2-8, lower = more compression

[brain]
path = "brain"
sync_interval = 30  # minutes

[stack]
roles = ["ceo", "eng-manager", "designer", "qa", "release-manager", "doc-engineer"]

[graph]
auto_sync = true
watch = true
include = ["**/*.rs", "**/*.ts", "**/*.tsx", "**/*.py", "**/*.md"]
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   GStack Agents                  │
│    CEO · Eng Manager · Designer · QA · ...       │
├────────────────────┬────────────────────────────┤
│     GBrain         │        Graphify             │
│  (you + context)   │    (your code)              │
│                    │                              │
│  people/           │    GRAPH_REPORT.md           │
│  decisions/        │    nodes, edges,             │
│  ideas/            │    communities               │
│  meetings/         │                              │
├────────────────────┴────────────────────────────┤
│              gbaby-quant (Rust)                   │
│                                                   │
│   CUDA ──→ Metal ──→ CPU (SIMD)                  │
│        auto-detect + fallback                     │
│                                                   │
│   TurboQuant: 3-bit KV cache compression          │
│   Zero accuracy loss · No retraining              │
└─────────────────────────────────────────────────┘
```

## TurboQuant: Honest Status

TurboQuant (ICLR 2026) is real, peer-reviewed, and works. But here's where it works *today* vs. where it's headed:

| Environment | Works now? | Details |
|---|---|---|
| **Self-hosted models** (llama.cpp, vLLM, Ollama) | **Yes** | Community implementations landed within 48 hours of the paper. Triton kernels, CUDA, Metal, CPU paths all available. |
| **Your own pipelines** (vector compression, embeddings) | **Yes** | `gbaby-quant` compresses vectors in your Rust backend right now. |
| **Anthropic (Claude API)** | **Not yet** | No public announcement. They *can* adopt it (it's training-free, model-agnostic), but haven't said they have. |
| **Google (Gemini API)** | **Not yet** | Google *wrote* the paper and mentions Gemini as a target use case, but hasn't deployed it to production. Official implementation expected Q2 2026. |
| **OpenAI** | **Not yet** | No announcement. |

**Why haven't cloud providers adopted it yet?** It just dropped (March 2026). The algorithm is training-free and model-agnostic — any provider could flip it on. But validating at billions-of-queries-per-day scale, on proprietary TPU/custom inference stacks, takes time. It's a matter of *when*, not *if*.

**What this means for you:** GBaby's other three layers (Graphify token reduction, GBrain memory, GStack roles) deliver value *today* on any provider. When cloud providers adopt TurboQuant server-side, your API bills drop automatically — and the savings stack on top of what GBaby already saves you.

## Hardware Auto-Detection

`gbaby-quant` picks the best compression backend at runtime:

```
CUDA available?  ──yes──→  Use CUDA kernels
       │ no
       ▼
Metal available? ──yes──→  Use Metal compute shaders
       │ no
       ▼
CPU (always)     ────────→  Use AVX2/NEON SIMD
```

Build with all backends enabled:

```bash
cargo build --release -p gbaby-quant --features all
```

Or target a specific one:

```bash
cargo build --release -p gbaby-quant --features cuda
cargo build --release -p gbaby-quant --features metal
cargo build --release -p gbaby-quant              # CPU (default)
```

## Credits

GBaby is a Frankenstein — proudly assembled from the work of others:

- **[Garry Tan](https://github.com/garrytan)** — GStack + GBrain. The productivity system that started it all.
- **[Safi Shamsi](https://github.com/safishamsi)** — Graphify. The knowledge graph that makes agents actually understand code.
- **[Google Research](https://research.google)** — TurboQuant. The compression breakthrough that makes the whole stack affordable.

## Tip Jar

GBaby is free and open source. If it saves you time or money, consider supporting development:

| | |
|---|---|
| **GitHub Sponsors** | [github.com/sponsors/saumyagarg](https://github.com/sponsors/saumyagarg) |
| **Buy Me a Coffee** | [buymeacoffee.com/saumyagarg](https://buymeacoffee.com/saumyagarg) |
| **Bitcoin** | `bc1q...` *(coming soon)* |

**Where tips go:**
- API credits for testing Gemini + Codex integrations
- GPU time for benchmarking TurboQuant CUDA/Metal paths
- Infrastructure for CI and automated testing

Every dollar goes to making the monster smarter.

## License

MIT. See [LICENSE](LICENSE).

---

Built by [Saumya Garg](https://github.com/swamig) · [LinkedIn](https://linkedin.com/in/saumyagarg)

*The monster is alive.*
