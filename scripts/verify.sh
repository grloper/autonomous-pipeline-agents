#!/usr/bin/env bash
# Verification gate: autonomous-pipeline-agents (Python GitHub-workflow policy scripts): ruff, mypy (non-blocking), unittest
#
# NOT CHECKED (do not claim these from a green run): the workflows running on real GitHub (merge gate, scan, doctor, outcomes), GitHub API calls and LLM calls.
#
# Usage: scripts/verify.sh   (exit 0 = pass). Non-blocking steps print "WARN" and never fail the run.
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n== %s\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "verify: required tool '$1' not found" >&2; exit 2; }; }
# warn_step "name" cmd...: run a check that fails today for pre-existing reasons; report but do not block.
warn_step() { local n="$1"; shift; step "$n (non-blocking)"; if ! "$@"; then echo "WARN: '$n' failed (pre-existing, non-blocking)"; fi; }
need git; need bash

step "shell syntax"
for f in scripts/*.sh; do bash -n "$f"; done

step "workflow lint (actionlint)"
if command -v actionlint >/dev/null 2>&1; then actionlint
elif command -v pipx >/dev/null 2>&1; then pipx run --spec actionlint-py==1.7.12.25 actionlint
else echo "verify: actionlint (or pipx) required" >&2; exit 2; fi

step "python environment"
need python3
VENV="${VERIFY_VENV:-.venv-verify}"
if [[ ! -x "$VENV/bin/python" ]]; then python3 -m venv "$VENV"; fi
PY="$VENV/bin/python"
"$PY" -m pip install -q --disable-pip-version-check -r .github/scripts/requirements.txt pyyaml ruff==0.17.0 mypy==2.4.0
export PATH="$PWD/$VENV/bin:$PATH"

step "ruff"
ruff check .github/scripts tests scripts
warn_step "mypy" mypy --ignore-missing-imports .github/scripts
step "unit tests"
python -m unittest discover -s tests -v

printf '\nPASS: ruff + unittest + actionlint + shell syntax.\n'
printf 'NOT CHECKED: the workflows running on real GitHub (merge gate, scan, doctor, outcomes), GitHub API calls and LLM calls.\n'
