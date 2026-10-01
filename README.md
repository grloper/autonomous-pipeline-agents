# AgentGate

Repository automation for reviewing agent-authored pull requests, measuring later outcomes and proposing instruction changes. Its Python scripts inspect diffs and PR facts, apply merge policy, detect some instruction-injection patterns and synthesize candidate guidance.

## Useful local scenario

Compare how the policy treats fictional low-risk agent edits, failing CI, suspicious instructions and risky changes without connecting GitHub:

```sh
python -m pip install -r .github/scripts/requirements.txt pyyaml
python -X utf8 .github/scripts/demo.py
python -m unittest discover -s tests -v
```

The Windows audit passed 204 unit tests using local fixtures and fake clients, and all 12 offline demo scenarios behaved as expected. These tests exercise policy, injection checks, PR outcomes, repository inspection and prompt synthesis. They do not demonstrate that agents improved over time or that the system operated on real repositories. The UTF-8 flag supports Windows consoles with a legacy default encoding.

## Implementation

`gate.py` evaluates merge policy; `injection.py` inspects changes; `outcomes.py` measures later PR status; `prompts.py` and `synth.py` build proposed instruction rules; `scan.py` and `doctor.py` inspect repository setup. These live in `.github/scripts/`; `.github/workflows/` connects them to GitHub events.

Workflows can request privileged external actions such as comments, repository writes or merges when configured. The audit did not invoke these production workflows, post messages, install a GitHub App or perform external agent runs. Pattern-based injection checks are not a general defense against all prompt injection. No production adoption or measured agent-quality claim is established.
