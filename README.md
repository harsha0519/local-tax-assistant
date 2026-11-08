# Local Tax Assistant

A private AI assistant for **US tax and personal finance questions** that runs entirely on a home PC. It answers questions using **retrieval-augmented generation (RAG)** over 25 official IRS publications for tax year 2025, and cites the publication it used.

No cloud AI service is involved: the model, the documents and the chat history all stay on the local machine.

> **Not tax advice.** This is a learning project. Always verify answers against irs.gov or a tax professional.

---

## Results

Tested against 7 questions with known TY2025 answers (see [`tests/tax_tests.py`](tests/tax_tests.py)):

| Question | Expected | Result | Time |
|---|---|---|---|
| Standard deduction, single (2025) | $15,750 | ✅ Pass | 52s |
| Standard deduction, married filing jointly (2025) | $31,500 | ✅ Pass | 35s |
| 401(k) employee deferral limit, under 50 (2025) | $23,500 | ✅ Pass | 40s |
| IRA contribution limit, under 50 (2025) | $7,000 | ✅ Pass | 98s |
| Max child tax credit per child (2025) | $2,200 | ✅ Pass | 37s |
| HSA limit, self-only coverage (2025) | $4,300 | ✅ Pass | 32s |
| Apple 10-K: what products does Apple make? | smartphones, ... | ✅ Pass | 29s |

**Score: 7/7.** Every answer cited the knowledge base. Full details: [`tests/results.md`](tests/results.md).

---

## How it works

```
 You ──► Open WebUI (chat page, localhost:8080)
            │
            ├─1─► Search the knowledge base (hybrid: meaning + keywords)
            │       └─ 25 IRS publications, split into ~1,200-character passages
            │          indexed with qwen3-embedding:0.6b in ChromaDB
            │
            ├─2─► Take the top 6 passages and add them to the prompt
            │
            └─3─► Ollama runs Qwen3.8 35B-A3B (local) ──► answer + citations
```

**Why RAG instead of fine-tuning?**
- Fine-tuning a 35B model needs far more GPU memory than a 12 GB consumer card.
- Exact figures (like "$15,750") are more reliable when the model *reads* them than when it *memorizes* them.
- Updating for a new tax year means swapping documents, not retraining.

---

## Stack

| Part | Tool | Role |
|---|---|---|
| Model server | [Ollama](https://ollama.com) | Runs the language model locally |
| Language model | Qwen3.8 35B-A3B Distill (GGUF, Q4_K_M) | Writes the answers |
| Embedding model | `qwen3-embedding:0.6b` | Turns passages into searchable vectors |
| Chat UI + RAG | [Open WebUI](https://github.com/open-webui/open-webui) | Chat page, knowledge base, citations, web search |
| Vector store | ChromaDB (Open WebUI default) | Stores the indexed passages |

**Hardware used:** Intel i7-13700KF, NVIDIA RTX 4070 (12 GB), 32 GB RAM, Windows 11.
The 21 GB model runs split about 50/50 between GPU and CPU.

**Speed tuning:** enabling flash attention and a q8_0 KV cache took generation from about **7 to about 57 tokens/second**.

---

## Setup (Windows)

### 1. Install Ollama and the models
```powershell
.\scripts\setup-ollama.ps1
```
Installs Ollama, sets the speed settings, and downloads the chat and embedding models (about 22 GB).

### 2. Install and start Open WebUI
```powershell
.\scripts\start-openwebui.ps1
```
Installs Open WebUI on first run (via [uv](https://docs.astral.sh/uv/)) and starts it at **http://localhost:8080**.

### 3. Download the IRS publications
```powershell
.\scripts\download-irs-pubs.ps1
```
Downloads the 25 publications listed in [`knowledge/irs-publications.md`](knowledge/irs-publications.md) from irs.gov into `data/irs/`.

### 4. Build the knowledge base (in Open WebUI)
1. **Admin Panel → Settings → Documents**
   - Embedding engine: **Ollama**, model: **qwen3-embedding:0.6b**
   - Hybrid search: **on**, Top K: **6**
   - Chunk size: **1200**, chunk overlap: **150**
2. **Workspace → Knowledge → +** and name it **US Tax & Finance**, then upload the PDFs from `data/irs/`
3. **Workspace → Models → +** and create **us-tax-finance** using the Qwen model, then attach the knowledge base
4. *(Optional)* **Admin Panel → Settings → Web Search**: enable DuckDuckGo, and set function calling to **legacy** so the model actually searches

### 5. Run the tests
Create an API key in Open WebUI (**Settings → Account → API keys**), then:
```powershell
$env:OWUI_API_KEY = "<your key>"
python tests\tax_tests.py
```

---

## Lessons learned

- **Context length matters.** Ollama's default context was too small for RAG; it's set to 32,768 tokens here.
- **Function calling mode changes behavior.** In Open WebUI v0.13, web search only ran reliably with function calling set to `legacy`. In `native` mode the model often skipped searching.
- **Test with known answers.** A small set of questions with exact expected figures caught problems fast and made changes measurable.

## Roadmap

- [ ] Grow the test set to 30+ questions, including tricky edge cases
- [ ] Compare models (Qwen 35B vs. smaller models) on accuracy and speed
- [ ] Add TY2026 publications when the IRS releases them
- [ ] Add a system prompt so the assistant always states the tax year and cites sources

## License

Code in this repository: [MIT](LICENSE). IRS publications are US government works and are downloaded directly from irs.gov; they are not stored in this repository.
