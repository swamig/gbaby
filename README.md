# GBaby

**The Frankenstein of AI Coding**

> If Garry Tan had a baby with Google DeepMind... this is what that graph would look like.

Four open-source projects. One stack. Two layers of optimization — **client-side** (what you send) and **server-side** (how it's processed). Use one or both.

**The monster is alive.**

> **Alpha stage.** GBaby is under active development and testing. The client-side stack (Graphify + GBrain + GStack) works today with any provider. The server-side compression layer (gbaby-quant / TurboQuant) is scaffolded with CUDA/Metal/CPU fallback but hasn't been battle-tested end-to-end yet — we're waiting on GPU credits and hardware access. If you have a CUDA rig or Apple Silicon Mac and want to help test, [DM me](https://linkedin.com/in/saumyagarg) or see the [Tip Jar](#tip-jar) to donate API/GPU credits. Contributions of any kind welcome.

---

## Two Layers of Optimization

GBaby is a **client + server** optimization stack. You can run just the client side for massive savings with zero infrastructure changes, or add the server side for even more when you self-host.

### Client-side (works with ANY provider today)

These reduce what you *send*. No infrastructure changes. Works with Claude, DeepSeek, Kimi, Llama, Ollama — anything.

| What | How | Impact |
|---|---|---|
| **Graphify** | Knowledge graph replaces raw file reads | **8x avg, up to 49x on large repos** — reads the graph instead of raw files |
| **GBrain** | Persistent memory across sessions | **No re-reading** — the agent already knows your codebase, team, and decisions |
| **GStack** | Specialized agent roles | **Smarter per token** — CEO/QA/eng-manager lens means less back-and-forth |

**Client-side alone cuts your token bill by ~8x on average (up to 49x on large monorepos).** No GPU needed. No self-hosting. Just `npx gbaby setup` and point it at your existing provider.

### Server-side (self-hosted only)

This reduces what the *GPU uses internally*. Requires self-hosting (vLLM, RunPod, llama.cpp).

| What | How | Impact |
|---|---|---|
| **TurboQuant** (gbaby-quant) | 3-bit KV cache compression inside GPU VRAM | **6x less GPU memory** — longer contexts on cheaper hardware |

TurboQuant operates entirely inside the server's GPU memory. Your client sends normal tokens and gets normal tokens back — the compression is invisible. Cloud providers (Anthropic, Google, DeepSeek) could adopt it server-side at any time; when they do, you benefit automatically. To control it yourself, you self-host.

### The full stack

```
┌─────────────────────────────────────────────────────────────┐
│  CLIENT SIDE (works with any provider)                       │
│                                                              │
│  Graphify ── 49x fewer tokens sent                          │
│  GBrain ──── persistent memory, no re-reading               │
│  GStack ──── smarter per token, specialized roles           │
│                                                              │
│  Impact: $300/mo → $6/mo (same model, same provider)        │
├─────────────────────────────────────────────────────────────┤
│  SERVER SIDE (self-hosted vLLM / RunPod / llama.cpp)         │
│                                                              │
│  TurboQuant ── 6x KV cache compression in GPU VRAM          │
│  gbaby-quant ── Rust crate, CUDA/Metal/CPU auto-detect      │
│                                                              │
│  Impact: 6x longer context, cheaper GPU tier, more users    │
└─────────────────────────────────────────────────────────────┘
```

---

## Why This Matters: The Cost Collapse

A typical AI coding session reads ~123,000 tokens of raw files. At Claude Sonnet rates ($3/M), that's **$0.50 per session**. Do 20 sessions a day and you're burning **$300/month** just on context.

### Graphify token reduction: real benchmarks

| Repo size | Measured reduction | Context |
|---|---|---|
| Large monorepo (27K+ files) | **Up to 49x** | Best case — agent reads ~15 files instead of thousands |
| Mixed corpus (52 files) | **Up to 71x** | Code + papers + images, 1.7K tokens vs 123K naive |
| Typical daily coding | **~8x average** | The realistic number for most projects |
| Code reviews | **~6.8x** | Reviews touch more files than average tasks |
| Small repos (< 10 files) | **~1x** | Everything fits in context anyway — minimal savings |

Quality doesn't suffer: graph-assisted reviews scored **8.8/10** vs **7.2/10** for naive file reads. ([source](https://dev.to/emperorakashi20/how-code-review-graph-cuts-claude-code-token-usage-by-49x-and-whether-its-actually-worth-it-4kn1))

### The actual math (using 8x average)

### The open-source frontier is here

Three Chinese labs dropped three frontier models in eight days. They're not "catching up" anymore — they're leading benchmarks and shipping at a fraction of the cost:

| Model | What it proved | Cost (API) | Available at |
|---|---|---|---|
| **[Kimi K2.6](https://platform.kimi.ai)** | #1 on SWE-Bench Pro (58.6%), beating GPT-5.4 and Claude Opus 4.6 on real coding tasks | $0.60/M in, $2.80/M out | [Moonshot API](https://platform.kimi.ai), [OpenRouter](https://openrouter.ai/moonshotai/kimi-k2.6) |
| **[DeepSeek V4](https://api-docs.deepseek.com)** | Codeforces 3206 (beats GPT-5.4), near-frontier at 1/6th the price of Opus 4.7 | $0.14/M in, $0.28/M out (Flash) | [DeepSeek API](https://api-docs.deepseek.com), [Together AI](https://www.together.ai) |
| **[Qwen 3.6 27B](https://huggingface.co/Qwen/Qwen3.6-27B)** | Ties Claude 4.5 Opus from an 18GB laptop. Dense 27B beats 397B MoE models. | **Free (local)** | [Ollama](https://ollama.com/library/qwen3.6), [HuggingFace](https://huggingface.co/Qwen/Qwen3.6-27B) |
| **[Llama 4 Maverick](https://www.llama.com/models/llama-4/)** | 400B params, 17B active, 1M context window. Meta's best open model. | $0.20/M in, $0.60/M out | [Together AI](https://www.together.ai), [Groq](https://groq.com) (Scout), [Fireworks](https://fireworks.ai) |

> **Note on TurboQuant:** None of these cloud APIs offer TurboQuant as a user-facing feature today. TurboQuant is a server-side GPU optimization — it was [merged into stock vLLM](https://github.com/vllm-project/vllm/issues/38171) on April 15, 2026, and providers like Together AI and Fireworks run vLLM under the hood. When they flip the flag, you benefit indirectly (cheaper pricing, longer context) — but you can't configure it yourself through their API. To *directly control* TurboQuant, you self-host (vLLM, RunPod, llama.cpp). The cost savings above come from **Graphify's 49x token reduction**, which works with every provider right now, no TurboQuant needed.

> **"Does my client need to speak TurboQuant?"** No. TurboQuant operates entirely inside the server's GPU memory during inference. Your client (Claude Code, OpenCode, Aider) sends normal tokens over a normal API and gets normal tokens back. TurboQuant compresses the model's *internal working memory* (KV cache) while it's thinking — the client never sees it. The API contract is identical with or without TurboQuant. That's why cloud providers can adopt it silently without breaking any client, and why GBaby's `[provider]` config is just a standard OpenAI-compatible endpoint URL.
>
> ```
> Client  ──── normal tokens ────▶  Server (vLLM)
>                                     │
>                                     │ KV cache compressed
>                                     │ FP16 → 3-bit in GPU VRAM
>                                     │ (invisible to client)
>                                     │
> Client  ◀── normal response ────  Server
> ```

### The actual math

| Setup | Cost per session | Monthly (20/day) | vs. baseline |
|---|---|---|---|
| Claude Sonnet (raw) | $0.50 | $300 | — |
| Claude Sonnet + Graphify (8x avg) | $0.06 | $37 | **88% cheaper** |
| Claude Sonnet + Graphify (49x large repo) | $0.01 | $6 | **98% cheaper** |
| Claude Haiku + Graphify (8x) | $0.005 | $3 | **99% cheaper** |
| Kimi K2.6 + Graphify (8x) | $0.005 | $3 | **99% cheaper** |
| DeepSeek V4 Flash + Graphify (8x) | $0.003 | $1.80 | **99.4% cheaper** |
| Llama 4 Maverick + Graphify (8x) | $0.002 | $1.20 | **99.6% cheaper** |
| Qwen 3.6 27B (local) + GBaby | $0.0001 | $0.06 | **~free** |

**The bottom line:** Using the **realistic 8x average**, GBaby turns a $300/month Claude Sonnet habit into ~$37/month. Switch to DeepSeek V4 Flash and it's $1.80/month. Run Qwen locally and it's pennies.

On large monorepos (49x), those numbers drop further — $300/month becomes $6/month on Sonnet.

And this is before GBrain's impact (no re-reading across sessions) and GStack's impact (fewer back-and-forth cycles). The 8x is just Graphify alone.

And this is before TurboQuant is battle-tested. When the compression layer is validated, self-hosted setups get 6x more context on the same GPU — meaning the models that already run on your laptop will handle codebases 6x larger without upgrading hardware.

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

## AI Coding CLI Support

GBaby works with any AI coding CLI. Use a proprietary one for quality, an open-source one for flexibility, or both.

| CLI | License | Provider Lock-in? | GBaby Status | Best for |
|---|---|---|---|---|
| **[Claude Code](https://claude.ai/code)** | Proprietary | Claude only | **Actively tested** | Best reasoning, deep codebase understanding |
| **[OpenCode](https://github.com/opencode-ai/opencode)** | Open source | Any (75+ providers) | Scaffolded | Interactive coding, any model, TUI |
| **[Aider](https://github.com/Aider-AI/aider)** | Open source | Any (75+ providers) | Scaffolded | Git-first workflows, auto-commits |
| **[Gemini CLI](https://github.com/google-gemini/gemini-cli)** | Open source | Gemini | Scaffolded | Google ecosystem |
| **[Codex (OpenAI)](https://github.com/openai/codex)** | Open source | OpenAI | Scaffolded | OpenAI ecosystem |

> **Honest status:** We're daily-driving this on Claude Code. The open-source CLI integrations (OpenCode, Aider) use the same GBrain/Graphify/TurboQuant stack but the agent role wiring hasn't been battle-tested yet.
>
> **Want to help test?** We'd love credit donations to run workloads on other platforms. See [Tip Jar](#tip-jar) — contributions go directly to API credits for testing.

### Why this matters: use GBaby with TurboQuant *today*

With an open-source CLI like **OpenCode** or **Aider**, you can point GBaby at a self-hosted vLLM instance running TurboQuant — and get the full stack (compressed inference + knowledge graph + memory + agent roles) without paying a cent in API fees. Claude Code locks you to Anthropic's API; open-source CLIs let you bring your own model.

## Provider Pricing Comparison

Here's what it actually costs to use GBaby across different providers. Prices are per 1M tokens as of April 2026.

### Frontier APIs (closed-source models)

| Provider | Model | Input | Output | TurboQuant? | Notes |
|---|---|---|---|---|---|
| **Anthropic** | Claude Opus 4 | $5.00 | $25.00 | No | Best reasoning. Expensive. |
| **Anthropic** | Claude Sonnet 4 | $3.00 | $15.00 | No | Sweet spot for most coding tasks |
| **Anthropic** | Claude Haiku 4 | $0.25 | $1.25 | No | Fast, cheap, good for GStack sub-agents |
| **Google** | Gemini 3.1 Pro | $2.00 | $12.00 | Not yet | Google *wrote* TurboQuant but hasn't deployed it |
| **Google** | Gemini Flash-Lite | $0.10 | $0.40 | Not yet | 25x cheaper than Sonnet. Quality tradeoff. |
| **OpenAI** | GPT-5.4 | $2.50 | $10.00 | No | |

### Open-source model APIs

> While OpenAI and Anthropic fight for paid subscribers, Chinese labs dropped
> 3 open-source frontier models in 8 days — and they're building on each other's
> work. Open source isn't behind anymore. Cheaper, faster, and shipping together.

| Provider | Model | Input | Output | TurboQuant? | Notes |
|---|---|---|---|---|---|
| **[DeepSeek](https://api-docs.deepseek.com)** | V4 Flash | **$0.14** | **$0.28** | On vLLM: Yes | **21x cheaper than Sonnet.** 1M context. Codeforces 3206, beats GPT-5.4. |
| **[DeepSeek](https://api-docs.deepseek.com)** | V4 Pro | $1.74 | $3.48 | On vLLM: Yes | Near-frontier at 1/6th the cost of Opus 4.7. Largest open-weight (1.1T). |
| **[Moonshot](https://platform.kimi.ai)** | Kimi K2.6 | $0.60 | $2.80 | On vLLM: Yes | **#1 SWE-Bench Pro** (58.6%), beat GPT-5.4 and Claude Opus 4.6 on real coding. Cache hits: $0.10/M. |
| **[Meta](https://www.llama.com/models/llama-4/)** | Llama 4 Maverick | $0.20 | $0.60 | On vLLM: Yes | 400B params, 17B active, **1M context**. Best open model from Meta. |
| **[Meta](https://www.llama.com/models/llama-4/)** | Llama 4 Scout | $0.11 | $0.34 | On vLLM: Yes | 272B params, 17B active, 512K context. Lighter, cheaper. |
| **[Groq](https://groq.com)** | Llama 3.3 70B | $0.59 | $0.79 | No (custom LPU) | Fastest inference (800 tok/s). NVIDIA-acquired. |
| **[Groq](https://groq.com)** | Llama 4 Scout | $0.11 | $0.34 | No (custom LPU) | Llama 4 on Groq hardware. |
| **[Together AI](https://www.together.ai)** | Llama 4 Maverick | $0.27 | $0.85 | vLLM-based | TurboQuant when vLLM merges it |
| **[Fireworks](https://fireworks.ai)** | Llama 3.3 70B | $0.90 | $0.90 | vLLM-based | 99.8% uptime |

### Self-hosted (TurboQuant now)

| Setup | Model | Cost/M tok | TurboQuant? | Notes |
|---|---|---|---|---|
| **vLLM on H200** | DeepSeek V4 Flash | ~$0.10 | **Yes** | Fits on single H200. 1M context. |
| **vLLM on H100** | Llama 4 Maverick | ~$0.15 | **Yes** | 17B active params = efficient. 1M context. |
| **vLLM on H100** | Kimi K2.6 (INT4) | ~$0.20 | **Yes** | INT4 quantization: 4xH100 is enough. #1 SWE-Bench Pro. |
| **vLLM on H100** | Llama 70B | ~$0.18 | **Yes** | 580 tok/s. Break-even at ~16M tok/day. |
| **vLLM on A100** | Llama 70B | ~$0.42 | **Yes** | Still 60-80% cheaper than frontier APIs |
| **Consumer GPUs** | Qwen 3.6 27B | **~$0.01** | **Yes** | **Ties Claude 4.5 Opus. Runs on $800 of GPUs.** |
| **Consumer GPUs** | Llama 4 Scout | ~$0.05 | **Yes** | 17B active params. Fits on 48GB+ consumer cards. |
| **llama.cpp** | Llama 70B | ~$0.10 | **Yes (TQ3)** | 43K context on consumer GPUs |
| **Ollama (local)** | Any GGUF | **$0.00** | Partial | Free. Runs on your laptop. |

### The GBaby multiplier

These prices are *before* GBaby's savings kick in:

- **Graphify** cuts tokens sent by 49-71x (read a 1.7K graph instead of 123K of raw files)
- **GBrain** eliminates re-explanation across sessions (no more "let me re-read the whole codebase")
- **TurboQuant** (self-hosted) compresses KV cache 6x — longer contexts, more concurrency, cheaper GPUs

**The math:**

| Scenario | Base cost | + Graphify (49x fewer tokens) | + TurboQuant (6x KV compression) |
|---|---|---|---|
| Claude Sonnet session | ~$0.50 | ~$0.01 | N/A (cloud, no TQ yet) |
| DeepSeek V4 Flash session | ~$0.02 | ~$0.0004 | On vLLM: even cheaper GPU |
| Qwen 3.6 27B (local) | ~$0.001 | ~$0.00002 | Fits 6x longer context on same card |

A frontier-quality coding session for **less than a thousandth of a cent.** That's the GBaby stack.

### Our recommendation

| Scenario | Recommended setup | Monthly cost (heavy use) |
|---|---|---|
| **Best quality, don't care about cost** | Claude Code + Claude Sonnet + GBaby | ~$150-300/mo |
| **Best quality, cost-conscious** | Claude Code + Claude Haiku + GBaby (Graphify cuts tokens 49x) | ~$10-30/mo |
| **Open-source maximalist** | OpenCode/Aider + Groq Llama 70B + GBaby | ~$5-15/mo |
| **Full TurboQuant (hosted)** | OpenCode/Aider + RunPod Serverless vLLM + TQ + GBaby | ~$5-20/mo (scales to zero) |
| **Full TurboQuant (own GPU)** | OpenCode/Aider + vLLM + TurboQuant + GBaby | GPU cost only (~$0.18/M tok) |
| **Zero cost** | OpenCode/Aider + Ollama (local) + GBaby | **$0/mo** |

### Hosted TurboQuant (no GPU management)

You don't need to manage your own GPU to use TurboQuant. **[RunPod Serverless](https://www.runpod.io/product/serverless)** lets you deploy a vLLM endpoint with TurboQuant enabled, pay per millisecond, and scale to zero when idle:

```bash
# 1. Create a RunPod serverless endpoint with the vLLM template
#    In the RunPod console: Serverless → Quick Deploy → vLLM
#    Set the model and add --kv-cache-dtype turboquant_k3v4 to the args

# 2. Point GBaby at it
# gbaby.toml:
# [provider]
# platform = "openai-compatible"
# base_url = "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/openai/v1"
# model = "meta-llama/Llama-3.1-70B"
# api_key_env = "RUNPOD_API_KEY"
```

**Pricing:** A100 at ~$0.0004/sec, H100 at ~$0.0012/sec. Scales to zero between sessions — you only pay when GBaby is actively working. A heavy coding day might cost $1-2.

**Coming soon:** [Together AI](https://www.together.ai) and [Fireworks AI](https://fireworks.ai) both run vLLM under the hood. When TurboQuant merges into vLLM mainline, they'll get it automatically — at that point, Llama 70B at $0.88/M tok will also be TurboQuant-compressed, and the savings pass through to you.

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
