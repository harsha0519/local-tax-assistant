"""Accuracy tests for the local tax assistant.

Asks the Open WebUI model questions with known TY2025 answers and checks
that the expected figure appears in the reply.

Usage (PowerShell):
    $env:OWUI_API_KEY = "<your Open WebUI API key>"
    python tests\\tax_tests.py

Optional settings:
    OWUI_URL    Open WebUI address (default http://127.0.0.1:8080)
    TEST_MODEL  model to test (default us-tax-finance)

Requires: pip install requests
"""
import os
import sys
import time

import requests

BASE = os.environ.get("OWUI_URL", "http://127.0.0.1:8080")
MODEL = os.environ.get("TEST_MODEL", "us-tax-finance")


def load_key() -> str:
    key = os.environ.get("OWUI_API_KEY")
    if key:
        return key.strip()
    path = os.path.expanduser("~/.owui-key")  # optional local file, never committed
    if os.path.exists(path):
        return open(path, encoding="utf-8-sig").read().strip()
    sys.exit("Set OWUI_API_KEY to an Open WebUI API key (Settings > Account > API keys).")


# (question, acceptable substrings for the correct answer)
TESTS = [
    ("What is the standard deduction for a single filer for tax year 2025?", ["15,750"]),
    ("What is the standard deduction for married filing jointly for tax year 2025?", ["31,500"]),
    ("What is the 2025 maximum employee elective deferral to a 401(k) plan, under age 50?", ["23,500"]),
    ("What is the 2025 IRA contribution limit for someone under age 50?", ["7,000"]),
    ("What is the maximum child tax credit per qualifying child for tax year 2025?", ["2,200"]),
    ("What is the 2025 HSA contribution limit for self-only HDHP coverage?", ["4,300"]),
    ("According to Apple's 10-K, what types of products does Apple design, manufacture and market?", ["smartphone"]),
]


def main() -> None:
    headers = {"Authorization": f"Bearer {load_key()}"}
    results = []
    for question, wanted in TESTS:
        start = time.time()
        r = requests.post(
            f"{BASE}/api/chat/completions",
            headers=headers,
            timeout=900,
            json={
                "model": MODEL,
                "stream": False,
                "messages": [{"role": "user", "content": question}],
                "features": {"web_search": False},  # test the knowledge base only
            },
        )
        seconds = time.time() - start
        if r.status_code != 200:
            print(f"HTTP {r.status_code}: {r.text[:300]}")
            results.append(False)
            continue
        data = r.json()
        answer = data["choices"][0]["message"]["content"]
        ok = any(w.lower() in answer.lower().replace("$", "") for w in wanted)
        sources = sorted({
            s.get("source", {}).get("name")
            for s in data.get("sources", [])
            if isinstance(s, dict) and s.get("source", {}).get("name")
        })
        results.append(ok)
        print(f"\n{'PASS' if ok else 'FAIL'} ({seconds:.0f}s) Q: {question}")
        print(f"  expected: {wanted}")
        print(f"  sources:  {sources[:5]}")
        print(f"  answer:   {answer.strip()[:450]}")

    print(f"\nSCORE: {sum(results)}/{len(TESTS)}")


if __name__ == "__main__":
    main()
