# AGENTS.md

Instructions for AI coding agents and contributors.

## Verification gate (required before claiming anything works)

Run exactly this and read the output (bash, python3, internet for pip):

```
scripts/verify.sh
```

Exit code 0 = pass; anything else = not done. CI (`.github/workflows/trust-gate.yml`) runs the same script (job `verify`) plus `scripts/check-test-integrity.sh` (job `test-integrity`). What it runs: creates a venv (.venv-verify), ruff check, mypy (non-blocking), unittest discover tests, actionlint (also lints the repo's own workflows)

**Not checked by the gate:** the workflows running on real GitHub (merge gate, scan, doctor, outcomes), GitHub API calls and LLM calls.

Rules: never delete tests, add skip/ignore/xfail markers, remove assertions or loosen expected values to get green. `test-integrity` also fails if the number of test cases drops below `scripts/test-baseline.txt`; only the owner may approve a test change (PR label `test-change-approved`; refresh the baseline with `scripts/check-test-integrity.sh --update-baseline`). Do not edit `.github/`, `scripts/verify.sh` or `scripts/check-test-integrity.sh` to make a failing check pass; they are owned by @grloper (CODEOWNERS).
