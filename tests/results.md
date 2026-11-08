# Test Results

**Date:** 2026-11-07
**Model:** `us-tax-finance` (Qwen3.8 35B-A3B Distill, Q4_K_M + "US Tax & Finance" knowledge base)
**Web search:** off (knowledge base only)
**Hardware:** RTX 4070 12 GB, i7-13700KF, 32 GB RAM

| # | Question | Expected | Result | Time | Cited KB |
|---|---|---|---|---|---|
| 1 | Standard deduction, single, TY2025 | $15,750 | PASS | 52s | Yes |
| 2 | Standard deduction, married filing jointly, TY2025 | $31,500 | PASS | 35s | Yes |
| 3 | 401(k) elective deferral limit, under 50, 2025 | $23,500 | PASS | 40s | Yes |
| 4 | IRA contribution limit, under 50, 2025 | $7,000 | PASS | 98s | Yes |
| 5 | Max child tax credit per qualifying child, TY2025 | $2,200 | PASS | 37s | Yes |
| 6 | HSA limit, self-only HDHP coverage, 2025 | $4,300 | PASS | 32s | Yes |
| 7 | Apple 10-K: products Apple designs and markets | smartphones | PASS | 29s | Yes |

**Score: 7/7** · Average time per answer: ~46 seconds

## Sample answer (test 1)

> For tax year 2025, the standard deduction for a single filer is **$15,750** [3].
> This same amount also applies to taxpayers who are married filing separately...

## Notes
- Answers are slow (30–100s) because the 21 GB model is split between GPU and CPU on a 12 GB card.
- A pass means the expected figure appears in the answer; answers were also spot-checked by hand.
