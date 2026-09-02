# jimmy Plugin Port Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the pstack Cursor plugin to Claude Code in full as a plugin named `jimmy`, living inside this dotfiles repo.

**Architecture:** Vendor the upstream tree verbatim, then drive it to correctness with a grep-based audit harness that acts as the test suite. Translation happens first across the whole tree (Cursor constructs → Claude Code constructs), then the `pstack`/`poteto` → `jimmy` rename runs as a separate mechanical pass so the audit can distinguish a missed translation from a missed rename.

**Tech Stack:** Markdown skills, Claude Code plugin manifests (`.claude-plugin/`), Bash (audit harness), Bun + TypeScript (the vendored `orch` and `watch-pr` CLIs), `gh`.

**Spec:** `docs/superpowers/specs/2026-09-01-pstack-claude-port-design.md`

## Global Constraints

- **Upstream provenance:** cursor/plugins commit `82f1d4f49ba8f21e3315a89c97e82f7c02a48fba`, pstack v0.14.6. Recorded in the plugin README; never changed by a task.
- **License:** upstream `LICENSE` (MIT, Copyright (c) 2026 Lauren Tan) is copied verbatim and never edited.
- **Plugin version:** `0.14.6-claude.1`.
- **Plugin name:** `jimmy`. Marketplace name: `jaime-plugins`.
- **Skill inventory:** exactly 45 skill directories, 23 playbooks, 2 upstream agents. A task that changes these counts is wrong unless the plan says so (Task 3 adds role agents).
- **Model set:** only `sonnet`, `opus`, `haiku`, `fable`, or `inherit`. No other model string may appear in the shipped tree.
- **Effort set:** only `low`, `medium`, `high`, `xhigh`, `max`.
- **Only `README.md` may contain the strings `pstack` or `poteto`** after Task 11, in the fork credit. (`LICENSE` is exempt from edits entirely but happens to contain neither — standard MIT text names the copyright holder, not the project.) Everywhere else is a rename failure.
- **Prose voice:** neutral third person. No first-person authorial voice, borrowed or invented.
- **Commit style:** conventional commits, one commit per task minimum.
- **Verifying which file the audit blames:** the audit prints whole matched lines, so grepping its raw output for a name also matches that name appearing inside another file's hit text. Always pipe through `cut -d: -f1` first to reduce each hit to its filename before grepping. `audit-port.sh 2>&1 | cut -d: -f1 | grep -c '<name>'` is the reliable form.

## File Structure

```
dotfiles/claude/plugins/
├── .claude-plugin/
│   └── marketplace.json                  # marketplace "jaime-plugins", lists jimmy
└── jimmy/
    ├── .claude-plugin/plugin.json        # name jimmy, version 0.14.6-claude.1
    ├── LICENSE                           # verbatim from upstream, never edited
    ├── README.md                         # rewritten neutral; carries fork credit
    ├── scripts/
    │   └── audit-port.sh                 # THE TEST HARNESS. Plan-owned, not upstream.
    ├── agents/
    │   ├── jimmy-agent.md                # upstream poteto-agent, renamed in Task 11
    │   ├── comment-sicko.md              # upstream, verbatim
    │   └── roles/                        # NEW (Task 3): model+effort+tool carriers
    │       ├── critic-risk.md            # fable · max · read-only
    │       ├── critic-deep.md            # opus · max · read-only
    │       ├── critic-broad.md           # opus · xhigh · read-only
    │       ├── critic-fast.md            # sonnet · high · read-only
    │       ├── judge.md                  # fable · max · read-only
    │       ├── worker-fast.md            # sonnet · high · writes
    │       └── worker-deep.md            # fable · max · writes
    ├── skills/                           # 45 skills
    │   ├── mode/                         # upstream poteto-mode, renamed in Task 11
    │   │   ├── SKILL.md
    │   │   ├── playbooks/                # 23
    │   │   ├── references/
    │   │   └── scripts/                  # orch, watch-pr, check-plan.mjs, worktree-audit.sh
    │   ├── setup-jimmy/                  # upstream setup-pstack, renamed in Task 11
    │   └── …42 more
    ├── automations/benny/                # dormant; NOT scanned as skills
    └── docs/guide/                       # 10 parts, rewritten
```

**Responsibility split.** `scripts/audit-port.sh` is the only file this plan authors from scratch that is not shipped content — it exists to make every other task independently verifiable. `agents/roles/` is the only place model and effort choices are written down as executable config; skills reference role agents by `subagent_type` and never hardcode a model string. `~/.claude/jimmy-models.md` (written by `setup-jimmy`, not by this repo) is the user's override layer.

---

### Task 1: Plugin skeleton, marketplace, and the audit harness

Creates the container and the test that every later task runs. Nothing is vendored yet, so the harness is proven against an empty tree.

**Files:**
- Create: `claude/plugins/.claude-plugin/marketplace.json`
- Create: `claude/plugins/jimmy/.claude-plugin/plugin.json`
- Create: `claude/plugins/jimmy/scripts/audit-port.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: `claude/plugins/jimmy/scripts/audit-port.sh [--with-rename]` — exits `0` when every check passes, `1` otherwise; prints one `ok`/`FAIL` line per check, and indented offending `path:line:text` under each FAIL. Every later task runs this. `--with-rename` additionally enables the rename checks, which are expected to fail until Task 11.

- [ ] **Step 1: Create the marketplace manifest**

```bash
mkdir -p claude/plugins/.claude-plugin claude/plugins/jimmy/.claude-plugin claude/plugins/jimmy/scripts
cat > claude/plugins/.claude-plugin/marketplace.json <<'EOF'
{
  "name": "jaime-plugins",
  "owner": {
    "name": "Jaime Abbariao"
  },
  "plugins": [
    {
      "name": "jimmy",
      "source": "./jimmy",
      "description": "Rigorous agent workflows: playbook routing, multi-lens review panels, and verification-first engineering principles."
    }
  ]
}
EOF
```

- [ ] **Step 2: Create the plugin manifest**

```bash
cat > claude/plugins/jimmy/.claude-plugin/plugin.json <<'EOF'
{
  "name": "jimmy",
  "version": "0.14.6-claude.1",
  "description": "Rigorous agent workflows: playbook routing, multi-lens review panels, and verification-first engineering principles.",
  "author": {
    "name": "Jaime Abbariao"
  },
  "license": "MIT",
  "keywords": ["workflow", "principles", "review", "planning", "subagents"],
  "skills": "./skills/",
  "agents": ["./agents/", "./agents/roles/"]
}
EOF
```

Note `agents` **replaces** the default `agents/` scan, so both directories must be listed explicitly. `automations/` is deliberately absent from every path field — that is what keeps benny dormant.

- [ ] **Step 3: Write the audit harness**

```bash
cat > claude/plugins/jimmy/scripts/audit-port.sh <<'EOF'
#!/usr/bin/env bash
# Verifies the jimmy plugin contains no untranslated Cursor constructs.
# Usage: audit-port.sh [--with-rename]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_RENAME=0
[[ "${1:-}" == "--with-rename" ]] && WITH_RENAME=1

fail=0

# Scans shipped content only. LICENSE and README carry upstream provenance by design.
# -I skips binary files (the guide's .jpg images). Every text file is scanned regardless
# of extension: an --include allowlist silently misses package.json, bun.lock,
# configuration.example.yaml, and the extensionless watch-pr script.
scan() {
  grep -rIEn "$1" \
    "$ROOT/skills" "$ROOT/agents" "$ROOT/automations" "$ROOT/docs" \
    2>/dev/null
}

check() {
  local label="$1" pattern="$2" hits
  hits="$(scan "$pattern")"
  if [[ -n "$hits" ]]; then
    printf 'FAIL  %s\n' "$label"
    sed 's/^/      /' <<<"$hits"
    printf '\n'
    fail=1
  else
    printf 'ok    %s\n' "$label"
  fi
}

echo "== translation checks =="
check "no Cursor Task tool"        '`Task` call|Task tool|`Task`s|three `Task`'
check "no generalPurpose"          'generalPurpose'
check "no AskQuestion"             '(^|[^r])\bAskQuestion\b'
check "no environment: cloud/local" 'environment: "(cloud|local)"'
check "no cloud_base_branch"       'cloud_base_branch'
check "no Cursor readonly param"   '`readonly`: |readonly: `(true|false)`'
check "no inherit-parent alias"    'inherit-parent'
check "no .cursor paths"           '\.cursor/'
check "no pstack-models.mdc"       'pstack-models\.mdc'
check "no Cursor model slugs"      'grok-[0-9]|gpt-[0-9]+\.[0-9]+-sol|claude-fable-5-1-thinking|claude-opus-5-thinking'
check "no Bugbot"                  '[Bb]ugbot'
check "no Cursor mentions"         '\bCursor\b'
check "no /add-plugin"             '/add-plugin'

if [[ "$WITH_RENAME" == "1" ]]; then
  echo
  echo "== rename checks =="
  check "no pstack identifiers"    'pstack'
  check "no poteto identifiers"    'poteto'
fi

echo
echo "== structure checks =="
skills=$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
plays=$(find "$ROOT/skills" -path '*/playbooks/*.md' 2>/dev/null | wc -l | tr -d ' ')
for pair in "45:$skills:skill directories" "23:$plays:playbooks"; do
  want="${pair%%:*}"; rest="${pair#*:}"; got="${rest%%:*}"; what="${rest#*:}"
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %s (%s)\n' "$what" "$got"
  else
    printf 'FAIL  %s: expected %s, found %s\n' "$what" "$want" "$got"
    fail=1
  fi
done

echo
[[ "$fail" == "0" ]] && echo "AUDIT PASS" || echo "AUDIT FAIL"
exit "$fail"
EOF
chmod +x claude/plugins/jimmy/scripts/audit-port.sh
```

- [ ] **Step 4: Run the harness to verify it fails on an empty tree**

Run: `claude/plugins/jimmy/scripts/audit-port.sh`
Expected: all translation checks print `ok` (nothing to find yet), both structure checks print `FAIL` (`expected 45, found 0` and `expected 23, found 0`), final line `AUDIT FAIL`, exit code `1`.

This is the harness proving it can fail. If it prints `AUDIT PASS` here, the structure checks are broken — fix before continuing.

- [ ] **Step 5: Verify the manifests parse**

Run: `python3 -c "import json;[json.load(open(p)) for p in ['claude/plugins/.claude-plugin/marketplace.json','claude/plugins/jimmy/.claude-plugin/plugin.json']];print('json ok')"`
Expected: `json ok`

- [ ] **Step 6: Commit**

```bash
git add claude/plugins
git commit -m "feat(jimmy): plugin skeleton, marketplace, and port audit harness"
```

---

### Task 2: Vendor the upstream tree

Copies pstack in verbatim so every later task is a reviewable diff against a known-good baseline. No translation happens here — the audit is expected to fail loudly, and its output becomes the working inventory for Tasks 5–10.

**Files:**
- Create: `claude/plugins/jimmy/skills/` (45 directories, verbatim)
- Create: `claude/plugins/jimmy/agents/{poteto-agent,comment-sicko}.md` (verbatim)
- Create: `claude/plugins/jimmy/automations/benny/` (verbatim)
- Create: `claude/plugins/jimmy/docs/guide/` (verbatim)
- Create: `claude/plugins/jimmy/LICENSE` (verbatim, never edited again)

**Interfaces:**
- Consumes: `audit-port.sh` from Task 1.
- Produces: the full upstream tree at `claude/plugins/jimmy/`, with skill directory names still using upstream identifiers (`poteto-mode/`, `setup-pstack/`) until Task 11.

- [ ] **Step 1: Clone upstream at the pinned commit**

```bash
git clone --filter=blob:none -q https://github.com/cursor/plugins.git /tmp/pstack-upstream
git -C /tmp/pstack-upstream checkout -q 82f1d4f49ba8f21e3315a89c97e82f7c02a48fba
git -C /tmp/pstack-upstream rev-parse HEAD
```

Expected output: `82f1d4f49ba8f21e3315a89c97e82f7c02a48fba`. If it differs, stop — the pin is the provenance guarantee.

- [ ] **Step 2: Copy the tree**

```bash
SRC=/tmp/pstack-upstream/pstack
DST=claude/plugins/jimmy
cp -R "$SRC/skills" "$DST/skills"
mkdir -p "$DST/agents"
cp "$SRC/agents/poteto-agent.md" "$SRC/agents/comment-sicko.md" "$DST/agents/"
cp -R "$SRC/automations" "$DST/automations"
cp -R "$SRC/docs" "$DST/docs"
cp "$SRC/LICENSE" "$DST/LICENSE"
```

Upstream's `.cursor-plugin/`, `.gitignore`, and `README.md` are deliberately **not** copied — Task 1 wrote the manifest and Task 12 writes the README.

- [ ] **Step 3: Remove vendored build artifacts**

```bash
rm -rf claude/plugins/jimmy/skills/poteto-mode/scripts/node_modules
```

- [ ] **Step 4: Run the audit to capture the violation inventory**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | tee /tmp/jimmy-audit-baseline.txt`
Expected: structure checks now print `ok    skill directories (45)` and `ok    playbooks (23)`. Every translation check prints `FAIL` with file:line hits. Final line `AUDIT FAIL`.

If either structure check fails here, the copy is incomplete — re-run Step 2 before continuing.

- [ ] **Step 5: Confirm the license is intact**

Run: `head -3 claude/plugins/jimmy/LICENSE`
Expected: `MIT License`, blank line, `Copyright (c) 2026 Lauren Tan`

- [ ] **Step 6: Commit**

```bash
git add claude/plugins/jimmy
git commit -m "feat(jimmy): vendor pstack v0.14.6 verbatim at 82f1d4f"
```

---

### Task 3: Role agents

Skills currently name raw model slugs and a Cursor `readonly` flag. The `Agent` tool accepts `model` but has no `effort` or `readonly` parameter, while plugin agent definitions support `model`, `effort`, and `disallowedTools`. Role agents are where those three settle, so every later skill edit can reference a `subagent_type` instead of restating a model.

**Files:**
- Create: `claude/plugins/jimmy/agents/roles/critic-risk.md`
- Create: `claude/plugins/jimmy/agents/roles/critic-deep.md`
- Create: `claude/plugins/jimmy/agents/roles/critic-broad.md`
- Create: `claude/plugins/jimmy/agents/roles/critic-fast.md`
- Create: `claude/plugins/jimmy/agents/roles/judge.md`
- Create: `claude/plugins/jimmy/agents/roles/worker-fast.md`
- Create: `claude/plugins/jimmy/agents/roles/worker-deep.md`

**Interfaces:**
- Consumes: `plugin.json` `agents` array from Task 1 (already lists `./agents/roles/`).
- Produces: seven `subagent_type` values used by Tasks 5–7 — `jimmy:critic-risk`, `jimmy:critic-deep`, `jimmy:critic-broad`, `jimmy:critic-fast`, `jimmy:judge`, `jimmy:worker-fast`, `jimmy:worker-deep`. The five critic/judge roles are read-only (`disallowedTools: Write, Edit, NotebookEdit`); the two worker roles may write. This is the full panel vocabulary — no later task invents an eighth role.

  The four **critic** roles map 1:1 onto the four panel slots in spec Decision 1: `critic-risk` = fable·max, `critic-deep` = opus·max, `critic-broad` = opus·xhigh, `critic-fast` = sonnet·high. `judge` is not a panel slot — it is the arena cross-judge and the reflect synthesizer.

- [ ] **Step 1: Write the five read-only review roles**

Each carries a distinct named lens. This is spec Decision 1's divergence mechanism: with two upstream vendor slots collapsed onto opus, the lens is what keeps a four-agent panel from returning four copies of the same review.

```bash
mkdir -p claude/plugins/jimmy/agents/roles

cat > claude/plugins/jimmy/agents/roles/critic-risk.md <<'EOF'
---
name: critic-risk
description: Operational risk lens for review panels. Hunts failure modes in production — partial failure, retries, migration order, rollback. Read-only.
model: fable
effort: max
disallowedTools: Write, Edit, NotebookEdit
---

You are the operational reviewer on a multi-lens panel. Other reviewers cover
correctness, design, and mechanics from the code's point of view; yours is the
only lens that asks what happens when this runs for real and something else is
already broken.

Ask what happens on partial failure, on retry, on concurrent execution, on a
rollback, on a deploy where old and new run side by side. Ask what this change
assumes about ordering, clock, network, or data that already exists in
production. Ask how someone would notice it had gone wrong.

Report findings as: the failure mode, the condition that triggers it, and what
an operator sees when it happens. Skip anything that only fails in theory.
EOF

cat > claude/plugins/jimmy/agents/roles/critic-deep.md <<'EOF'
---
name: critic-deep
description: Correctness lens for review panels. Hunts logic errors, broken invariants, and unhandled states in a diff or design. Read-only.
model: opus
effort: max
disallowedTools: Write, Edit, NotebookEdit
---

You are the correctness reviewer on a multi-lens panel. Other reviewers cover
design, risk, and mechanics; do not duplicate them.

Your lens is whether the code does what it claims, under every input it can
actually receive. Trace the states the change can reach. Name the invariant each
branch assumes and find the path that violates it. Prefer one concrete failing
scenario — specific inputs, specific wrong output — over a list of concerns.

Report findings as: location, the invariant broken, the input that breaks it.
Report nothing you cannot tie to a path through the code you have read.
EOF

cat > claude/plugins/jimmy/agents/roles/critic-broad.md <<'EOF'
---
name: critic-broad
description: Design and blast-radius lens for review panels. Hunts coupling, boundary violations, and consequences outside the diff. Read-only.
model: opus
effort: xhigh
disallowedTools: Write, Edit, NotebookEdit
---

You are the design reviewer on a multi-lens panel. Another reviewer already
covers correctness within the diff; your job is everything the diff touches
that is not in the diff.

Your lens is structure and consequence. Who else calls this? What contract just
changed silently? Which module now knows something it should not? Does this
change make the next change harder? Read outward from the diff into its callers
until you can say what breaks and what merely bends.

Report findings as: location, the boundary or contract at stake, the caller or
future change that pays for it.
EOF

cat > claude/plugins/jimmy/agents/roles/critic-fast.md <<'EOF'
---
name: critic-fast
description: Mechanical lens for review panels. Hunts dead code, duplication, naming drift, and missing tests. Read-only.
model: sonnet
effort: high
disallowedTools: Write, Edit, NotebookEdit
---

You are the mechanical reviewer on a multi-lens panel. Other reviewers cover
correctness and design; leave those to them.

Your lens is hygiene at speed. Dead branches, copy-pasted blocks that should be
one function, names that no longer describe what they hold, error paths with no
test, comments that contradict the code beneath them, reinvented standard
library.

Breadth beats depth here. Cover the whole diff. Report findings as: location,
what is wrong, the one-line fix.
EOF

cat > claude/plugins/jimmy/agents/roles/judge.md <<'EOF'
---
name: judge
description: Cross-judge and synthesizer for panels and arenas. Scores candidates against a rubric and recommends one with rationale. Read-only.
model: fable
effort: max
disallowedTools: Write, Edit, NotebookEdit
---

You are the judge. You did not produce any of the candidates in front of you and
you have no stake in which wins.

Score each candidate against every criterion in the rubric you were given, using
the rubric's own words. Where candidates differ, say what the difference costs,
not merely that it exists. Where they agree, say so briefly and move on.

Recommend exactly one base, and name the parts of the others worth grafting onto
it. A recommendation with no rationale is not a verdict. If the rubric cannot
separate two candidates, say that instead of inventing a tiebreak.
EOF
```

- [ ] **Step 2: Write the two writing worker roles**

```bash
cat > claude/plugins/jimmy/agents/roles/worker-fast.md <<'EOF'
---
name: worker-fast
description: Fast mechanical implementer for precisely specified work. Use when the change is fully described and needs execution, not judgment.
model: sonnet
effort: high
---

You implement work that is already decided. The brief you were given names the
change, the files, and how to verify it.

Execute it to the letter. Where the brief is precise, do not improve on it.
Where the brief is genuinely silent on something you must decide, pick the
option most consistent with the surrounding code and say which you picked in
your report.

Verify before reporting. Report as PASS, ISSUES, or BLOCKED, with the command
you ran and its output as evidence.
EOF

cat > claude/plugins/jimmy/agents/roles/worker-deep.md <<'EOF'
---
name: worker-deep
description: Deep implementer for work needing judgment — cross-cutting design, concurrency, subtle algorithms, or a vague intent.
model: fable
effort: max
---

You implement work that still needs judgment. The brief names an outcome; how to
reach it is partly yours to decide.

Understand before changing. Read the surrounding system until you can say why it
is shaped the way it is, then make the smallest change that achieves the outcome
without fighting that shape. If the brief's approach proves wrong once you can
see the code, say so and propose the alternative rather than forcing it.

Verify before reporting. Report as PASS, ISSUES, or BLOCKED, with the command
you ran and its output as evidence, plus any judgment call you made that the
brief did not settle.
EOF
```

- [ ] **Step 3: Verify frontmatter uses only permitted values**

Run:
```bash
grep -h '^model:\|^effort:' claude/plugins/jimmy/agents/roles/*.md | sort | uniq -c
```
Expected: only `model:` values from `sonnet|opus|fable` and only `effort:` values from `high|xhigh|max` — seven of each in total, distributed as `3 fable`, `2 opus`, `2 sonnet` and `4 max`, `1 xhigh`, `2 high`. Any other string violates the Global Constraints model/effort sets.

- [ ] **Step 4: Verify the audit still reports the same translation failures**

Run: `claude/plugins/jimmy/scripts/audit-port.sh`
Expected: `AUDIT FAIL`, and the structure checks still print `ok    skill directories (45)` — role agents live under `agents/`, not `skills/`, so the count must not move.

- [ ] **Step 5: Commit**

```bash
git add claude/plugins/jimmy/agents/roles
git commit -m "feat(jimmy): add role agents carrying model, effort, and write posture"
```

---

### Task 4: Model configuration and the setup skill

Replaces the `~/.cursor/rules/pstack-models.mdc` always-applied rule with a read-on-demand file, and rewrites the setup skill's model detection for Claude Code's fixed model set.

**Note on naming:** this task writes `~/.claude/pstack-models.md` — translation only. Task 11 renames it to `~/.claude/jimmy-models.md` along with everything else. Doing the rename here would make the audit unable to tell a missed translation from a missed rename.

**Files:**
- Modify: `claude/plugins/jimmy/skills/setup-pstack/SKILL.md` (whole body)

**Interfaces:**
- Consumes: the seven role agent names from Task 3.
- Produces: the config file contract that Tasks 5–7 read — `~/.claude/pstack-models.md`, one `role: value` line per role, where a value is a role agent name (`jimmy:critic-deep`), a comma-separated list of them for panel roles, or `inherit`. A role with no line falls back to the skill's inline default. Skills read this file when present and never hardcode a model string.

- [ ] **Step 1: Confirm the current failures for this file**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -n 'setup-pstack'`
Expected: hits under `no AskQuestion`, `no .cursor paths`, `no Cursor model slugs`, and `no inherit-parent alias`.

- [ ] **Step 2: Rewrite the setup skill**

```bash
cat > claude/plugins/jimmy/skills/setup-pstack/SKILL.md <<'EOF'
---
name: setup-pstack
description: Configure which role agent each pstack role uses. Writes a config file that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
---

# Setup

Write `~/.claude/pstack-models.md`, a config file that sets the role agent used
for each role. The skills read it when present and fall back to their inline
defaults when a line is absent, so this is an override layer, not a requirement.

## Steps

### 1. Show the available roles

Role agents ship with the plugin and carry a fixed model and effort level. There
is nothing to detect — the set is:

| Role agent | Model | Effort | Writes | Lens |
|---|---|---|---|---|
| `jimmy:critic-risk` | fable | max | no | operational risk, failure modes |
| `jimmy:critic-deep` | opus | max | no | correctness, invariants |
| `jimmy:critic-broad` | opus | xhigh | no | design, blast radius |
| `jimmy:critic-fast` | sonnet | high | no | mechanics, hygiene |
| `jimmy:judge` | fable | max | no | scoring candidates against a rubric |
| `jimmy:worker-fast` | sonnet | high | yes | precisely specified implementation |
| `jimmy:worker-deep` | fable | max | yes | implementation needing judgment |

`inherit` is also valid for any role and means the role runs on the parent
session's model with no subagent model override.

### 2. Load current state

The default role mapping is the file shape shown in step 4. If
`~/.claude/pstack-models.md` already exists, read it and treat its values as the
current choices. Otherwise start from those defaults.

### 3. Map and confirm

Show every role with its current value. Ask whether to accept as-is or change
specific roles, offering the role agents above plus `inherit`. Prefer
`AskUserQuestion` over free text.

Panel roles (`how critics`, `arena runners`, `architect runners`,
`interrogate reviewers`) take a list, and one subagent runs per entry, so the
list length sets the fan-out. Keep the entries distinct: the panel's value comes
from four different lenses, and listing the same role agent four times produces
four near-identical reviews at four times the cost. If the user wants a larger
panel, repeat a role only after all four critics are already in the list.

`arena cross-judge pool` is also a list; Arena selects one entry from it.
`swarm workers` is the default for every worker unless a race assigns another
role per arm.

### 4. Write the config

Write `~/.claude/pstack-models.md`, overwriting the whole file so re-runs stay
idempotent. Shape:

```
# pstack role configuration. One line per role.
# Delete a line to fall back to the skill default.
# `inherit` means the role runs on the parent session's model.
feature, refactoring: jimmy:worker-fast
bug-fix: jimmy:worker-deep
perf-issue: jimmy:worker-deep
hillclimb: jimmy:worker-deep
judgment and prose: jimmy:worker-deep
hardest tasks: jimmy:worker-deep
how explorer: jimmy:worker-fast
how explainer: jimmy:worker-deep
how critics: jimmy:critic-risk, jimmy:critic-deep, jimmy:critic-broad, jimmy:critic-fast
why investigators: jimmy:worker-fast
why synthesizer: jimmy:judge
reflect tooling: jimmy:critic-fast
reflect judgment: jimmy:critic-deep
reflect divergent: jimmy:critic-broad
reflect synthesizer: jimmy:judge
arena runners: jimmy:worker-deep, jimmy:worker-fast, jimmy:worker-deep, jimmy:worker-fast
arena cross-judge pool: jimmy:judge, jimmy:critic-deep
swarm workers: jimmy:worker-fast
architect runners: jimmy:critic-risk, jimmy:critic-deep, jimmy:critic-broad, jimmy:critic-fast
interrogate reviewers: jimmy:critic-risk, jimmy:critic-deep, jimmy:critic-broad, jimmy:critic-fast
```

### 5. Confirm

Tell the user the config was written and that skills pick it up on their next
run. Re-running this skill updates it.

### 6. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a
`verify-*` skill, or an existing harness). If not, offer once: "want a
project-local verification skill, so agents can drive the app the way a user
does and prove changes work? I can generate one with
`/create-verification-skill`." On yes, invoke `/create-verification-skill`. On
no, move on without pushing.
EOF
```

Note `arena runners` deliberately uses writing worker roles, not critics — arena runners produce candidate artifacts, they do not review. The read-only critic roles would be unable to write their candidate.

- [ ] **Step 3: Run the audit to verify this file is clean**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -c 'setup-pstack'`
Expected: `0`

- [ ] **Step 4: Commit**

```bash
git add claude/plugins/jimmy/skills/setup-pstack/SKILL.md
git commit -m "feat(jimmy): read-on-demand role config and rewritten setup skill"
```

---

### Task 5: Translate the delegating skills

The eight skills that spawn subagents. Each currently names raw model slugs, `generalPurpose`, and a Cursor `readonly` flag; each becomes a reference to a role agent from Task 3.

**Files:**
- Modify: `claude/plugins/jimmy/skills/how/SKILL.md` (lines 48, 50, 67, 69, 79, 81, 116, 118)
- Modify: `claude/plugins/jimmy/skills/why/SKILL.md` (lines 120, 122, 166, 168)
- Modify: `claude/plugins/jimmy/skills/arena/SKILL.md` (lines 28, 33, 41)
- Modify: `claude/plugins/jimmy/skills/swarm/SKILL.md` (lines 25, 30, 32)
- Modify: `claude/plugins/jimmy/skills/architect/SKILL.md` (line 33)
- Modify: `claude/plugins/jimmy/skills/interrogate/SKILL.md` (lines 36, 46-50)
- Modify: `claude/plugins/jimmy/skills/reflect/SKILL.md` (lines 25, 37, 49)
- Modify: `claude/plugins/jimmy/skills/no-comments/SKILL.md` (line 19)

**Interfaces:**
- Consumes: the seven role agent names from Task 3; the config contract from Task 4.
- Produces: nothing later tasks depend on. This task is pure translation.

**The substitution rules for this task.** Apply these uniformly; they are the whole task.

| Upstream construct | Replacement |
|---|---|
| `` `subagent_type`: `generalPurpose` `` + `` `model`: <slug> `` + `` `readonly`: `true` `` | `` `subagent_type`: `<role agent>` `` (one line; the role carries model, effort, and write posture) |
| `` `readonly`: `false` `` plus prose about readonly stripping MCP | delete the flag; replace the rationale with "role agents keep MCP access; the prompt forbids file writes" |
| `Task tool` / `` `Task` call `` | `Agent tool` / `` `Agent` call `` |
| `run_in_background: true` | "spawn in the background" (the `Agent` tool runs subagents in the background by default) |
| `environment: "cloud"` | `isolation: "worktree"` |
| `environment: "local"` | omit (the default) |
| `cloud_base_branch` | an explicit branch instruction in the worker's brief |
| `~/.cursor/rules/pstack-models.mdc` | `~/.claude/pstack-models.md` |
| a bare model slug list as a default | the matching role agent list from Task 4's table |
| `inherit-parent` / `auto` | `inherit` |

- [ ] **Step 1: Confirm the failures**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -E 'skills/(how|why|arena|swarm|architect|interrogate|reflect|no-comments)/SKILL\.md'`
Expected: roughly 30 hit lines across the eight files. Save this list; it is the checklist for Step 2. The pattern ends in `SKILL.md` deliberately: a bare directory prefix like `skills/reflect/` would also match `skills/reflect/references/*.md`, which belong to Tasks 7 and 8, not this task.

- [ ] **Step 2: Apply the substitutions file by file**

Work one file at a time, smallest first, re-running the audit after each. Two files need more than mechanical substitution:

**`interrogate/SKILL.md`** — the Reviewer A/B/C/D table becomes role agents, and the model-slug fallback paragraph at line 50 is deleted outright. That paragraph tells the agent what to do when a slug is rejected as unresolvable; role agents cannot produce that error, so the paragraph is dead advice. Replace the table with:

```markdown
| Subagent | Default role agent |
|----------|--------------------|
| Reviewer A | `jimmy:critic-risk` |
| Reviewer B | `jimmy:critic-deep` |
| Reviewer C | `jimmy:critic-broad` |
| Reviewer D | `jimmy:critic-fast` |

For each reviewer:
- `subagent_type`: the configured `interrogate reviewers` entry, or the table default

Each role agent carries its own model, effort level, and review lens. The filled
prompt template goes to all reviewers, so every lens is applied to the same
evidence.
```

**`reflect/SKILL.md`** — line 25's transcript-directory guidance changes host. Replace `Do not glob across ~/.cursor/projects/*/` with `Do not glob across ~/.claude/projects/*/`, keeping the reasoning (it crosses workspace boundaries and reads private chats from unrelated projects) unchanged. Lines 37 and 49 lose the `readonly: false` flag and its MCP rationale, and gain `jimmy:critic-*` / `jimmy:judge` role agents per Task 4's `reflect *` config lines.

- [ ] **Step 3: Verify all eight files are clean**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -cE 'skills/(how|why|arena|swarm|architect|interrogate|reflect|no-comments)/SKILL\.md'`
Expected: `0`

- [ ] **Step 4: Verify no role agent name was invented**

Run:
```bash
grep -rhoE 'jimmy:[a-z-]+' claude/plugins/jimmy/skills | sort -u
```
Expected: only the seven names from Task 3. Anything else is a typo that will fail silently at runtime as an unresolvable subagent type.

- [ ] **Step 5: Commit**

```bash
git add claude/plugins/jimmy/skills
git commit -m "feat(jimmy): route delegating skills through role agents"
```

---

### Task 6: Translate the mode skill and add the sticky hook

The router. Its frontmatter carries Cursor's `mode: true` and `reminder:`, which become a session-scoped `UserPromptSubmit` hook.

**Files:**
- Modify: `claude/plugins/jimmy/skills/poteto-mode/SKILL.md` (frontmatter, lines 20, 89, 91)
- Create: `claude/plugins/jimmy/skills/poteto-mode/scripts/mode-reminder.sh`

**Interfaces:**
- Consumes: role agents (Task 3), config contract (Task 4).
- Produces: `mode-reminder.sh` — reads `.claude/jimmy-mode.state` in the project directory; emits the reminder line on stdout when the file exists, emits nothing and exits `0` when it does not. Task 7's `pause-safely` playbook deletes that state file.

- [ ] **Step 1: Write the reminder hook script**

```bash
cat > claude/plugins/jimmy/skills/poteto-mode/scripts/mode-reminder.sh <<'EOF'
#!/usr/bin/env bash
# Re-injects the mode reminder while the mode is active.
# Active means ${CLAUDE_PROJECT_DIR}/.claude/jimmy-mode.state exists.
set -uo pipefail
state="${CLAUDE_PROJECT_DIR:-.}/.claude/jimmy-mode.state"
[[ -f "$state" ]] || exit 0
echo "New task? Playbook match or rigor needed -> apply /jimmy:mode. Casual turn or user opts out -> don't."
EOF
chmod +x claude/plugins/jimmy/skills/poteto-mode/scripts/mode-reminder.sh
```

- [ ] **Step 2: Test the script in both states**

Run:
```bash
cd /tmp && rm -rf modetest && mkdir -p modetest/.claude && cd modetest
CLAUDE_PROJECT_DIR=$PWD ~/programming/dotfiles/claude/plugins/jimmy/skills/poteto-mode/scripts/mode-reminder.sh; echo "inactive exit=$?"
touch .claude/jimmy-mode.state
CLAUDE_PROJECT_DIR=$PWD ~/programming/dotfiles/claude/plugins/jimmy/skills/poteto-mode/scripts/mode-reminder.sh; echo "active exit=$?"
cd ~/programming/dotfiles && rm -rf /tmp/modetest
```
Expected: first call prints only `inactive exit=0`; second prints the reminder line then `active exit=0`.

- [ ] **Step 3: Replace the frontmatter**

Upstream frontmatter drops `mode`, `icon`, `color`, and `reminder`; the reminder's text moves into the hook.

```yaml
---
name: Poteto Mode
description: An agent style for concise, detailed responses, deliberate subagents, unslopped prose, simple code, and verified work. Use for /poteto-mode or requests to work in this style.
disable-model-invocation: true
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/poteto-mode/scripts/mode-reminder.sh"
---
```

The description also drops upstream's possessive first person ("poteto's agent style") per the Global Constraints voice rule.

- [ ] **Step 4: Add the activation step to the skill body**

Immediately after the skill's opening todo-list instruction, insert:

```markdown
**Activate the mode.** Run `mkdir -p .claude && touch .claude/jimmy-mode.state`
once at the start. While that file exists, a reminder is re-injected on each
turn so the mode survives across turns. Delete it when the user opts out or the
Pause Safely playbook runs. Add `.claude/jimmy-mode.state` to the project's
`.gitignore` if it is not already ignored.
```

- [ ] **Step 5: Translate lines 20, 89, and 91**

- Line 20: `AskQuestion` → `AskUserQuestion`.
- Line 89: `subagent_type: "poteto-agent"` stays (renamed in Task 11); the routed-skills sentence stays.
- Line 91: this is the densest line in the file. `run_in_background: true` → "spawn in the background"; delete "agent mode (readonly strips MCP)"; replace the two model slugs with `jimmy:worker-fast` (mechanical) and `jimmy:worker-deep` (judgment or vague intent); `inherit-parent` or `auto` → `inherit`; `Task` → `Agent`; `~/.cursor/rules/...` reference → `~/.claude/pstack-models.md`.

- [ ] **Step 6: Verify the file is clean**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -c 'poteto-mode/SKILL.md'`
Expected: `0`

- [ ] **Step 7: Commit**

```bash
git add claude/plugins/jimmy/skills/poteto-mode
git commit -m "feat(jimmy): translate mode skill and add sticky-mode hook"
```

---

### Task 7: Translate the playbooks

18 of the 23 playbooks carry Cursor constructs or bare "Cursor" prose. The other 5 are already clean and must not be edited.

**Files:**
- Modify: `claude/plugins/jimmy/skills/poteto-mode/playbooks/` — `orchestrate.md`, `multi-phase-plan.md`, `autonomous-run.md`, `session-pickup.md`, `eval.md`, `worktree-cleanup.md`, `bug-fix.md`, `hillclimb.md`, `feature.md`, `perf-issue.md`, `refactoring.md`, `autopilot-full.md`, `autopilot-stack.md`, `babysit.md`, `shipping.md`, `pause-safely.md`, `authoring-a-skill.md`, `opening-a-pr.md`
- Modify: `claude/plugins/jimmy/skills/poteto-mode/references/bugbot-triage.md` (renamed)
- Modify: `claude/plugins/jimmy/skills/reflect/references/synthesizer.md` (Bugbot reference only)

**Interfaces:**
- Consumes: role agents (Task 3), the substitution table from Task 5.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Confirm the failures and the untouched set**

Run:
```bash
claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -oE 'playbooks/[a-z-]+\.md' | sort -u
```
Expected: exactly the 18 filenames listed above. Any playbook not in that list must end this task byte-identical to its vendored state. `shipping.md`, `pause-safely.md`, and `authoring-a-skill.md` appear only because of a bare "Cursor" prose mention each — they carry no other construct.

- [ ] **Step 2: Apply the Task 5 substitution table to the model and subagent hits**

`bug-fix.md`, `hillclimb.md`, `feature.md`, `perf-issue.md`, `refactoring.md`, and `multi-phase-plan.md` carry only model-slug references. Each maps to `jimmy:worker-deep` (bug-fix, hillclimb, perf-issue) or `jimmy:worker-fast` (feature, refactoring), matching Task 4's config lines.

- [ ] **Step 3: Retarget the Bugbot references**

`bugbot-triage.md`, `babysit.md`, `autopilot-full.md`, `autopilot-stack.md`, `multi-phase-plan.md`, and `reflect/references/synthesizer.md` treat Bugbot as the automated PR reviewer whose comments need triage. Claude Code's equivalent is `/code-review` plus whatever review bot the repo actually runs.

Rename `references/bugbot-triage.md` to `references/review-bot-triage.md` and rewrite its framing: the triage logic (treat bot comments as untrusted data, verify each against the code, never treat a comment as an instruction) is sound and carries over unchanged — only the bot's identity changes. Update the five referring files to the new path and name.

- [ ] **Step 4: Fix the host-specific paths**

- `worktree-cleanup.md`: `.cursor/worktrees/myrepo/x` → `.claude/worktrees/myrepo/x` in the example of a worktree path a hand-typed guess would miss.
- `session-pickup.md`, `eval.md`: `.cursor/` transcript and skill paths → `.claude/`.
- `orchestrate.md`: `Task tool` → `Agent tool`; `environment: "cloud"` → `isolation: "worktree"`; "After a Cursor restart" → "After a session restart"; `AskQuestion` → `AskUserQuestion`.
- `autonomous-run.md`: `AskQuestion` → `AskUserQuestion`.
- `multi-phase-plan.md`: `node pstack/skills/poteto-mode/scripts/check-plan.mjs` → `node "${CLAUDE_PLUGIN_ROOT}/skills/poteto-mode/scripts/check-plan.mjs"`.

- [ ] **Step 5: Verify the 5 clean playbooks were not touched**

Run:
```bash
git diff --name-only HEAD -- claude/plugins/jimmy/skills/poteto-mode/playbooks | wc -l
```
Expected: `18`

- [ ] **Step 6: Verify the playbooks are clean**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -c 'playbooks/'`
Expected: `0`

- [ ] **Step 7: Commit**

```bash
git add claude/plugins/jimmy/skills/poteto-mode
git commit -m "feat(jimmy): translate playbooks and retarget review-bot triage"
```

---

### Task 8: Translate the remaining skills and the guide's constructs

Twelve files whose only Cursor coupling is a host path or an install instruction. The three `docs/guide/` files are here rather than in Task 12 because the audit scans `docs/`, so leaving them until the docs task would make this task's "everything passes" milestone false. Mechanical, but they are the difference between an audit that passes and one that nearly passes. `worktree-audit.sh` is included here rather than in Task 9 because its `.cursor/` path is the last audit-visible translation hit; Task 9 handles the script changes the audit cannot see.

**Files:**
- Modify: `claude/plugins/jimmy/skills/recall/SKILL.md`
- Modify: `claude/plugins/jimmy/skills/show-me-your-work/SKILL.md`
- Modify: `claude/plugins/jimmy/skills/automate-me/SKILL.md`
- Modify: `claude/plugins/jimmy/skills/create-verification-skill/SKILL.md`
- Modify: `claude/plugins/jimmy/skills/maintain-verification-skill/SKILL.md`
- Modify: `claude/plugins/jimmy/skills/reflect/references/judgment-reviewer.md`
- Modify: `claude/plugins/jimmy/skills/reflect/references/tooling-reviewer.md`
- Modify: `claude/plugins/jimmy/skills/reflect/references/divergent-reviewer.md`
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/worktree-audit.sh` (line 25 comment, line 27 path)
- Modify: `claude/plugins/jimmy/docs/guide/01-setup.md` (3 hits)
- Modify: `claude/plugins/jimmy/docs/guide/06-verify-and-ship.md` (1 hit)
- Modify: `claude/plugins/jimmy/docs/guide/07-overnight.md` (1 hit)
- Modify: `claude/plugins/jimmy/docs/guide/09-make-it-yours.md` (1 hit)
- Modify: `claude/plugins/jimmy/docs/guide/10-recipes-and-pitfalls.md` (`auto` / `inherit-parent` aliases)
- Modify: `claude/plugins/jimmy/agents/poteto-agent.md` (`generalPurpose` in its description)

**Interfaces:**
- Consumes: nothing.
- Produces: `worktree-audit.sh` reading transcripts from `$HOME/.claude/projects/<slug>` — Task 9 assumes this path is already correct and does not revisit it.

- [ ] **Step 1: Confirm the failures**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -E 'recall|show-me-your-work|automate-me|verification-skill|reviewer\.md|worktree-audit'`
Expected: hits under `no .cursor paths` only.

- [ ] **Step 2: Apply the path substitutions**

The three `reflect/references/*-reviewer.md` files share one identical line describing where `SKILL.md` files live. Replace it in all three:

```
- `Read` tool calls against any `SKILL.md` file (project `.claude/skills/`, user-level `~/.claude/skills/`, or plugin-installed paths under `~/.claude/plugins/`)
```

For the five skills: `.cursor/skills/` → `.claude/skills/`, `.cursor/settings.json` → `.claude/settings.json`, `.cursor/projects/` → `.claude/projects/`, `.cursor/plugins/` → `.claude/plugins/`.

For `worktree-audit.sh`, lines 25–27 locate the transcript directory. Claude Code stores transcripts as `.jsonl` files directly under `~/.claude/projects/<slug>`, where the slug is the absolute project path with `/` replaced by `-`. Upstream's extra `agent-transcripts` segment does not exist here:

```bash
# Transcripts dir: ~/.claude/projects/<slugified-repo-path>/, one .jsonl per session.
transcripts="$HOME/.claude/projects/$slug"
```

Confirm the slug format against a real directory before trusting it:

```bash
ls -d "$HOME/.claude/projects/$(pwd | tr / -)" && echo "slug format confirmed"
```
Expected: the directory path prints, followed by `slug format confirmed`. If it does not, read `~/.claude/projects/` and match the actual convention rather than assuming.

- [ ] **Step 3: Translate the guide's Cursor constructs**

Only the banned constructs here — prose voice and the wider Cursor framing belong to Task 12. Find them first:

```bash
grep -rnE '\.cursor/|[Bb]ugbot|/add-plugin|grok-[0-9]|gpt-[0-9]+\.[0-9]+-sol|claude-fable-5-1-thinking|claude-opus-5-thinking|generalPurpose|AskQuestion' claude/plugins/jimmy/docs/guide/
```
Expected: hits across `01-setup.md`, `06-verify-and-ship.md`, `07-overnight.md`, and `09-make-it-yours.md` — including bare "Cursor" prose mentions, which the `no Cursor mentions` audit check flags.

Apply the Task 5 substitution table to each. `/add-plugin pstack` in `01-setup.md` becomes the two-command install:

```
/plugin marketplace add ~/programming/dotfiles/claude/plugins
/plugin install pstack@jaime-plugins
```

(Task 11 renames `pstack@` to `jimmy@` with everything else.)

- [ ] **Step 4: Verify every translation check now passes**

Run: `claude/plugins/jimmy/scripts/audit-port.sh`
Expected: every line under `== translation checks ==` prints `ok`. Structure checks print `ok`. Final line `AUDIT PASS`, exit code `0`.

This is the milestone the whole translation pass was aiming at. If any check still fails, the failing file belongs to an earlier task — go back rather than patching it here.

- [ ] **Step 5: Confirm the rename work is still outstanding**

Run: `claude/plugins/jimmy/scripts/audit-port.sh --with-rename`
Expected: translation and structure checks `ok`; both rename checks `FAIL` with many hits; final line `AUDIT FAIL`. Task 11 clears these.

- [ ] **Step 6: Commit**

```bash
git add claude/plugins/jimmy/skills claude/plugins/jimmy/docs
git commit -m "feat(jimmy): translate remaining host paths and guide constructs"
```

---

### Task 9: Repackage the scripts

The Bun/TypeScript CLIs are harness-agnostic and need no redesign. What they need is a package identity, `${CLAUDE_PLUGIN_ROOT}`-relative invocation, a review-bot detector that is not hardcoded to Cursor, and a `bun` on the machine.

**Files:**
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/package.json`
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/bun.lock` (regenerated, not hand-edited)
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/watch-pr/github.ts:337-345`
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/watch-pr/github.test.ts:227`
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/watch-pr/types.ts:68-69` (`isBugbot`, `bugbotReviewPasses` fields)
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/watch-pr/policy.ts:50` (the `"bugbot"` string literal)
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/watch-pr/render.ts:62-63` (output labels)
- Modify: `claude/plugins/jimmy/skills/poteto-mode/scripts/check-plan.mjs:7` (a `grok-4.6-fast-xhigh` slug inside a string constant)
- Modify: `mise.toml`
- Test: the vendored suites — `scripts/orch/orch.test.ts`, `scripts/watch-pr/{cli,github,policy}.test.ts`

**Interfaces:**
- Consumes: `worktree-audit.sh`'s corrected transcript path from Task 8.
- Produces: nothing later tasks depend on.

**Do not touch** the local variables named `cursor` in `check-plan.mjs:90-94` and `github.ts:565-569`. Those are pagination cursors, not the vendor. A blind find-and-replace here breaks GraphQL pagination silently — the tests in Step 4 are what catch it.

- [ ] **Step 1: Add bun to the toolchain**

```bash
grep -q '^bun' mise.toml || printf 'bun = "latest"\n' >> mise.toml
mise install
bun --version
```
Expected: a version number prints.

- [ ] **Step 2: Establish the test baseline before changing anything**

```bash
cd claude/plugins/jimmy/skills/poteto-mode/scripts
bun install
bun test orch watch-pr
bun x tsc --project watch-pr/tsconfig.json --noEmit --strict
cd -
```
Expected: all tests pass and typecheck is silent. If the vendored suite is already red, stop and report — a red baseline makes every later "tests pass" claim meaningless.

- [ ] **Step 3: Rename the package**

Translation only; Task 11 takes it to `@jimmy/mode-tools`.

```bash
cd claude/plugins/jimmy/skills/poteto-mode/scripts
python3 - <<'EOF'
import json, pathlib
p = pathlib.Path("package.json")
d = json.loads(p.read_text())
d["name"] = "@pstack/poteto-mode-tools"
p.write_text(json.dumps(d, indent=2) + "\n")
EOF
bun install
cd -
```

`bun install` re-runs so `bun.lock`'s embedded workspace name follows `package.json`. The lockfile carries the same `@cursor-skill/poteto-mode-tools` string, and a stale lock leaves a second copy of the old identifier for the rename pass to trip over.

- [ ] **Step 4: Generalize the review-bot detector**

`github.ts` around line 337 identifies automated review comments by `author === "cursor"` and a `cursor_automation_id` marker. Replace the hardcoded identity with a configurable set so the watcher recognizes whatever bot the repo actually runs.

Write the failing test first, in `github.test.ts` alongside the existing case at line 227:

```typescript
test("recognizes a configured review bot other than cursor", () => {
  const comment = {
    author: { login: "claude" },
    body: "Found a possible null deref.",
  };
  expect(isReviewBotComment(comment, ["claude", "cursor"])).toBe(true);
});

test("does not treat a human comment as bot review", () => {
  const comment = { author: { login: "someone" }, body: "lgtm" };
  expect(isReviewBotComment(comment, ["claude", "cursor"])).toBe(false);
});
```

Run: `cd claude/plugins/jimmy/skills/poteto-mode/scripts && bun test watch-pr/github.test.ts`
Expected: FAIL — `isReviewBotComment is not defined`.

- [ ] **Step 5: Implement the detector**

In `github.ts`, extract the existing inline check into an exported function and default the bot list to the previous behavior plus `claude`:

```typescript
export const DEFAULT_REVIEW_BOTS = ["cursor", "claude"] as const;

export function isReviewBotComment(
  comment: { author?: { login?: string } | null },
  bots: readonly string[] = DEFAULT_REVIEW_BOTS,
): boolean {
  const login = comment.author?.login;
  return login != null && bots.includes(login);
}
```

Replace the original `author === "cursor" && …` condition with a call to it, preserving the surrounding `cursor_automation_id` marker check as an additional signal rather than a requirement.

- [ ] **Step 5b: Carry the generalization through the type, policy, and render layers**

The Bugbot concept is threaded through more than `github.ts`. Rename the fields so the type layer reflects what the code now means, letting the compiler find every use:

- `types.ts:68-69`: `isBugbot` → `isReviewBot`, `bugbotReviewPasses` → `reviewBotPasses`
- `policy.ts:50`: the `"bugbot"` string literal becomes a reference to `DEFAULT_REVIEW_BOTS` rather than a hardcoded name
- `render.ts:62-63`: output labels follow the renamed fields

Also fix `check-plan.mjs:7`, where a `grok-4.6-fast-xhigh` slug sits inside the `LANES` string constant. That string is illustrative prose in a plan-shape checker, not a model selection — replace the slug with a role agent name so the example matches this plugin.

Run `bun x tsc --project watch-pr/tsconfig.json --noEmit --strict` after the renames: a missed use is a compile error, not a silent bug. That is why the fields are renamed rather than aliased.

- [ ] **Step 6: Run the full suite**

```bash
cd claude/plugins/jimmy/skills/poteto-mode/scripts
bun test orch watch-pr
bun x tsc --project watch-pr/tsconfig.json --noEmit --strict
cd -
```
Expected: all tests pass, including the two new ones. Typecheck silent.

- [ ] **Step 7: Verify pagination cursors survived**

Run:
```bash
grep -n 'let cursor\|const cursor\|endCursor' claude/plugins/jimmy/skills/poteto-mode/scripts/check-plan.mjs claude/plugins/jimmy/skills/poteto-mode/scripts/watch-pr/github.ts
```
Expected: the pagination variables are still present and unrenamed.

- [ ] **Step 8: Commit**

```bash
git add claude/plugins/jimmy/skills/poteto-mode/scripts mise.toml
git commit -m "feat(jimmy): repackage scripts and generalize the review-bot detector"
```

---

### Task 10: benny

benny stays dormant. Its files are setup sources merged into a *target* repository, not skills in this plugin — which is why `automations/` appears in no `plugin.json` path field.

**Files:**
- Modify: `claude/plugins/jimmy/automations/benny/README.md`
- Modify: `claude/plugins/jimmy/automations/benny/FOR_AGENTS.md`
- Modify: `claude/plugins/jimmy/automations/benny/skills/setup-benny/SKILL.md`
- Modify: `claude/plugins/jimmy/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`
- Modify: `claude/plugins/jimmy/automations/benny/skills/reproduce-and-fix-issues/references/control-adapter.md`
- Modify: `claude/plugins/jimmy/automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md`
- Modify: `claude/plugins/jimmy/automations/benny/skills/triage-issue-reports/references/routing.example.md`
- Modify: `claude/plugins/jimmy/automations/benny/templates/configuration.example.yaml` (two `.cursor/benny/` paths)
- Delete: `claude/plugins/jimmy/automations/benny/templates/triage-automation-prompt.md`
- Delete: `claude/plugins/jimmy/automations/benny/templates/reproduce-automation-prompt.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing. benny is a leaf.

- [ ] **Step 1: Delete the automation prompt templates**

These two files exist only to be pasted into a Cursor Automation's editor. With no Automations to configure, they describe a UI that does not exist.

```bash
rm claude/plugins/jimmy/automations/benny/templates/triage-automation-prompt.md \
   claude/plugins/jimmy/automations/benny/templates/reproduce-automation-prompt.md
```

`templates/configuration.example.yaml` stays — it is user configuration, not trigger plumbing — but it is not inert: its `map_path` and `feature_map_path` keys hold `.cursor/benny/` paths that Step 4 must translate.

- [ ] **Step 2: Rewrite the setup instructions for a Claude Code target**

In `README.md` and `FOR_AGENTS.md`, the six-step setup becomes four. Destination paths change from `.cursor/` to `.claude/`, and the `.cursor/settings.json` plugin-enable step is replaced by installing the plugin in the target repo:

```markdown
1. Point Claude Code at `FOR_AGENTS.md` and name the target repository.
2. Let setup merge this directory into the target at `.claude/benny/`, and its
   three skills into the target's `.claude/skills/`. It must preserve
   destination-only files and surface conflicts instead of overwriting local
   edits.
3. Keep user-owned configuration in `.claude/benny/`. Adapt
   `configuration.example.yaml` and `feature-map.example.md`.
4. Commit `.claude/benny/` and the installed skills before using either
   workflow. Send a harmless test report and verify the triage output.
```

Remove the sentences describing automation drafts, their editors, and source-channel thread behavior — all trigger-layer concepts.

- [ ] **Step 3: Note that invocation is manual**

Add one line near the top of `README.md`:

```markdown
benny's two workflows run on request — invoke `/triage-issue-reports` or
`/reproduce-and-fix-issues` in the target repository. There is no trigger layer;
nothing fires on its own.
```

- [ ] **Step 4: Translate the remaining paths**

`.cursor/automations/benny/` → `.claude/benny/`, `.cursor/benny/` → `.claude/benny/`, `.cursor/skills/` → `.claude/skills/` across all eight modified files, `configuration.example.yaml` included. Leave its `prefer_cursor_actions` key alone — that is a benny config key name, not a host path, and renaming it would break the example against benny's own reader.

- [ ] **Step 5: Verify benny is clean and still dormant**

Run: `claude/plugins/jimmy/scripts/audit-port.sh 2>&1 | cut -d: -f1 | grep -c 'automations/'`
Expected: `0`

Run: `python3 -c "import json;d=json.load(open('claude/plugins/jimmy/.claude-plugin/plugin.json'));print('automations' in json.dumps(d))"`
Expected: `False` — benny must not be reachable as a skills path.

- [ ] **Step 6: Commit**

```bash
git add claude/plugins/jimmy/automations
git commit -m "feat(jimmy): port benny as dormant skills without the trigger layer"
```

---

### Task 11: The rename pass

One mechanical pass over the already-translated tree. Running it separately is what lets the audit distinguish a missed translation from a missed rename.

**Files:**
- Rename: `skills/poteto-mode/` → `skills/mode/`
- Rename: `skills/setup-pstack/` → `skills/setup-jimmy/`
- Rename: `agents/poteto-agent.md` → `agents/jimmy-agent.md`
- Rename: `skills/mode/references/review-bot-triage.md` (already renamed in Task 7 — verify only)
- Modify: every file containing `pstack` or `poteto`

**Interfaces:**
- Consumes: a tree where every translation check passes (Task 8's milestone) and Tasks 9–10 are complete.
- Produces: the final identifier set — plugin `jimmy`, skill `/jimmy:mode`, agent `jimmy-agent`, skill `/jimmy:setup-jimmy`, config `~/.claude/jimmy-models.md`, package `@jimmy/mode-tools`.

- [ ] **Step 1: Confirm the starting state**

Run: `claude/plugins/jimmy/scripts/audit-port.sh --with-rename`
Expected: every translation and structure check `ok`; both rename checks `FAIL`. If a translation check fails, an earlier task is incomplete — do not proceed.

- [ ] **Step 2: Move the directories and files**

```bash
cd claude/plugins/jimmy
git mv skills/poteto-mode skills/mode
git mv skills/setup-pstack skills/setup-jimmy
git mv agents/poteto-agent.md agents/jimmy-agent.md
cd -
```

- [ ] **Step 3: Rewrite identifiers in content**

Order matters — the longest, most specific patterns first, so `poteto-mode` never decays into `poteto` + `-mode`.

```bash
cd claude/plugins/jimmy
files=$(grep -rl 'pstack\|poteto' skills agents automations docs 2>/dev/null)
for f in $files; do
  perl -pi -e '
    s{\@cursor-skill/poteto-mode-tools}{\@jimmy/mode-tools}g;
    s{\@pstack/poteto-mode-tools}{\@jimmy/mode-tools}g;
    s{skills/poteto-mode}{skills/mode}g;
    s{poteto-mode/playbooks}{mode/playbooks}g;
    s{/poteto-mode}{/jimmy:mode}g;
    s{`poteto-mode`}{`mode`}g;
    s{poteto-agent}{jimmy-agent}g;
    s{setup-pstack}{setup-jimmy}g;
    s{pstack-models\.md}{jimmy-models.md}g;
    s{\bpoteto-mode\b}{jimmy mode}g;
    s{\bpstack\b}{jimmy}g;
    s{\bpoteto\b}{jimmy}g;
  ' "$f"
done
cd -
```

- [ ] **Step 4: Fix the skill name frontmatter by hand**

The regex leaves `name: Poteto Mode` as `name: jimmy Mode`. Set it explicitly, and set the setup skill's name to match its new directory:

```bash
cd claude/plugins/jimmy
perl -pi -e 's{^name: .*$}{name: mode}' skills/mode/SKILL.md
perl -pi -e 's{^name: .*$}{name: setup-jimmy}' skills/setup-jimmy/SKILL.md
perl -pi -e 's{^name: .*$}{name: jimmy-agent}' agents/jimmy-agent.md
cd -
```

- [ ] **Step 5: Fix the hook path**

Task 6's frontmatter hook points at `skills/poteto-mode/scripts/mode-reminder.sh`. Step 3 rewrote it to `skills/mode/`; confirm rather than assume:

```bash
grep -n 'mode-reminder.sh' claude/plugins/jimmy/skills/mode/SKILL.md
test -x claude/plugins/jimmy/skills/mode/scripts/mode-reminder.sh && echo "hook script present and executable"
```
Expected: the frontmatter path reads `${CLAUDE_PLUGIN_ROOT}/skills/mode/scripts/mode-reminder.sh`, and the script is present and executable.

- [ ] **Step 6: Run the full audit**

Run: `claude/plugins/jimmy/scripts/audit-port.sh --with-rename`
Expected: every check `ok`, including both rename checks. Final line `AUDIT PASS`, exit code `0`.

- [ ] **Step 7: Verify the scripts still pass after the rename**

```bash
cd claude/plugins/jimmy/skills/mode/scripts
bun test orch watch-pr
bun x tsc --project watch-pr/tsconfig.json --noEmit --strict
cd -
```
Expected: all green. A rename that renamed an identifier the tests depend on shows up here.

- [ ] **Step 8: Verify role agent names survived**

Run: `grep -rhoE 'jimmy:[a-z-]+' claude/plugins/jimmy/skills | sort -u`
Expected: the seven Task 3 role names, plus `jimmy:mode` from the `/jimmy:mode` rewrites. Nothing else.

- [ ] **Step 9: Commit**

```bash
git add -A claude/plugins/jimmy
git commit -m "refactor(jimmy): rename pstack and poteto identifiers to jimmy"
```

---

### Task 12: README, guide, and voice

The last content task. Upstream's docs are written in the author's first person and describe Cursor throughout; both change.

**Files:**
- Create: `claude/plugins/jimmy/README.md`
- Modify: `claude/plugins/jimmy/docs/guide/README.md` and `01-setup.md` … `10-recipes-and-pitfalls.md`
- Modify: `claude/plugins/jimmy/agents/jimmy-agent.md` (description)
- Modify: `claude/plugins/jimmy/skills/mode/SKILL.md` (description)

**Interfaces:**
- Consumes: the final identifier set from Task 11.
- Produces: the fork credit line, which is one of only two places `pstack`/`poteto` may appear.

- [ ] **Step 1: Write the plugin README**

```bash
cat > claude/plugins/jimmy/README.md <<'EOF'
# jimmy

Rigorous agent workflows for Claude Code. jimmy trades throughput for quality:
go deep on one agent, verify what it produced, and parallelize only work you can
trust.

## Install

```
/plugin marketplace add ~/programming/dotfiles/claude/plugins
/plugin install jimmy@jaime-plugins
```

## Get started

1. Run `/jimmy:setup-jimmy` to choose which role agent handles each role.
2. Use `/jimmy:mode` whenever a task needs rigor.

`/jimmy:mode` reads the request, matches it to one of 23 playbooks, and routes to
the other skills as the steps need them. It stays active across turns once
entered; say so to opt out.

## Review panels

Panel skills (`/jimmy:interrogate`, `/jimmy:how` in critique mode,
`/jimmy:architect`, `/jimmy:arena`) fan out to four reviewers with four
different lenses:

| Role agent | Model · effort | Lens |
|---|---|---|
| `jimmy:critic-risk` | fable · max | operational risk, failure modes |
| `jimmy:critic-deep` | opus · max | correctness, invariants |
| `jimmy:critic-broad` | opus · xhigh | design, blast radius |
| `jimmy:critic-fast` | sonnet · high | mechanics, hygiene |

`/jimmy:setup-jimmy` changes any of it, writing `~/.claude/jimmy-models.md`.

## Credit

jimmy is a fork of [pstack](https://github.com/cursor/plugins/tree/main/pstack)
by Lauren Tan, ported from Cursor to Claude Code. Upstream: `cursor/plugins`
commit `82f1d4f49ba8f21e3315a89c97e82f7c02a48fba`, pstack v0.14.6. The original
MIT license is preserved in `LICENSE` and covers this fork.

Changes from upstream: role-to-model routing targets the Claude model family
with per-role effort levels; multi-vendor review panels are replaced by
single-family panels with explicit per-slot lenses; Cursor Automations are
dropped, so benny's skills run on request rather than on a trigger.
EOF
```

- [ ] **Step 2: Rewrite the guide's Cursor framing**

Task 8 already removed the banned constructs; what remains is prose framing. Each of the 11 guide files describes Cursor's UI and workflow:

- Cursor cloud agents → background subagents and worktree isolation
- Cursor's plan mode → Claude Code's plan mode
- `/loop` stays as-is
- Bugbot → `/code-review` and repo review bots

`docs/guide/images/*.jpg` are copied verbatim; update any caption text that names Cursor.

- [ ] **Step 3: Strip the first-person voice**

Find the remaining authorial first person and rewrite it in third person describing what jimmy does:

```bash
grep -rn "\bi'm\b\|\bi've\b\|\bi don't\b\|\bmy skills\b\|\bmy style\b\|\bmy answer\b" \
  claude/plugins/jimmy/README.md claude/plugins/jimmy/docs claude/plugins/jimmy/skills claude/plugins/jimmy/agents \
  --include='*.md' -i
```
Expected after rewriting: no matches. Note the upstream description of `jimmy-agent` ("any request for poteto's style") and the `mode` skill description both became "an agent style" in earlier tasks — verify they read as neutral prose, not as a possessive with the name swapped.

- [ ] **Step 4: Verify the credit line is the only provenance mention**

Run: `claude/plugins/jimmy/scripts/audit-port.sh --with-rename`
Expected: `AUDIT PASS`. The audit does not scan `README.md` or `LICENSE`, which is exactly why the credit line is allowed to name pstack.

Run: `grep -rl 'pstack\|poteto' claude/plugins/jimmy`
Expected: exactly one path — `claude/plugins/jimmy/README.md`. `LICENSE` does not appear because standard MIT text names the copyright holder, not the project. If any other path appears, Task 11 missed it.

- [ ] **Step 5: Commit**

```bash
git add claude/plugins/jimmy
git commit -m "docs(jimmy): rewrite README and guide for Claude Code in neutral voice"
```

---

### Task 13: Install, validate, and smoke test

Everything so far verified the files. This verifies the plugin actually loads and runs.

**Files:**
- Modify: `setup.sh` (record the marketplace add)
- Modify: `README.md` (repo root — note the plugin)

**Interfaces:**
- Consumes: the complete plugin.
- Produces: a working install. Terminal task.

- [ ] **Step 1: Validate the plugin structurally**

```bash
claude plugin validate claude/plugins
```
Expected: no errors. This checks JSON syntax, duplicate names, and path traversal.

- [ ] **Step 2: Install it**

```bash
claude plugin marketplace add ~/programming/dotfiles/claude/plugins
claude plugin install jimmy@jaime-plugins
```

- [ ] **Step 3: Verify all 45 skills and 9 agents loaded**

In a Claude Code session, run `/plugin` and inspect the jimmy entry.
Expected: 45 skills under the `jimmy:` namespace, and 9 agents (`jimmy-agent`, `comment-sicko`, and the 7 role agents). A skill count below 45 means a directory failed frontmatter parsing — check the skill whose name is missing.

- [ ] **Step 4: Smoke test the router**

In a session inside a real project, run:
```
/jimmy:mode investigate how the audit harness decides a check has failed
```
Expected: it opens a todo list, matches the Investigation playbook, and produces a cited answer without writing code. Confirm `.claude/jimmy-mode.state` was created.

- [ ] **Step 5: Smoke test a panel — the spec's Decision 1 acceptance criterion**

Make a small deliberate change with a real defect (e.g. an off-by-one in a loop bound) and run:
```
/jimmy:interrogate review this diff
```
Expected: four subagents spawn, one per critic role. Their findings must differ by lens — the correctness reviewer should catch the off-by-one; the others should not simply restate it. Four near-identical reviews mean the lens prompts are not doing their job, and the fix belongs in `agents/roles/`, not here.

- [ ] **Step 6: Smoke test the read-only posture**

```
/jimmy:how explain the watch-pr polling policy
```
Expected: explorer subagents read files and produce an explanation; no file is modified. Confirm with `git status --porcelain` that the working tree is unchanged.

- [ ] **Step 7: Record the install in the dotfiles**

```bash
cat >> setup.sh <<'EOF'

# --- Claude Code plugins ---
# jimmy lives in this repo; register it as a local marketplace.
setup_claude_plugins() {
    if command -v claude &>/dev/null; then
        claude plugin marketplace add "$DOTFILES_DIR/claude/plugins" 2>/dev/null || true
        claude plugin install jimmy@jaime-plugins 2>/dev/null || true
        echo "  ok: jimmy plugin"
    else
        echo "  skip: claude not installed"
    fi
}
EOF
```

Then add `setup_claude_plugins` to the script's main invocation list, matching how the other setup functions are called.

- [ ] **Step 8: Verify setup.sh is still valid and idempotent**

```bash
bash -n setup.sh && echo "syntax ok"
./setup.sh
./setup.sh
```
Expected: `syntax ok`, then two clean runs with the second reporting `ok:` for everything rather than re-doing work.

- [ ] **Step 9: Note the plugin in the repo README**

Add one line to the root `README.md` describing `claude/plugins/jimmy` and pointing at its own README.

- [ ] **Step 10: Final audit and commit**

```bash
claude/plugins/jimmy/scripts/audit-port.sh --with-rename
git add -A
git commit -m "feat(jimmy): install via local marketplace and record in setup.sh"
```
Expected: `AUDIT PASS` before committing.

---

## Deferred

Recorded so they are choices rather than omissions:

- **`isolation: "remote"`** is access-gated. Skills that upstream ran on Cursor cloud use `isolation: "worktree"` instead. If remote access is available later, `swarm` and the autopilot playbooks are where it would pay off.
- **The `mode/` name.** If the mode skill is ever copied out of the plugin into a flat skills directory, a bare `mode` is too generic and needs renaming then (spec Decision 9).
- **Sticky-mode hook noise.** If the `UserPromptSubmit` reminder proves intrusive, the fallback is deleting the hook and relying on the skill body persisting in session context. Record which is in force in the plugin README.
- **Upstream re-sync.** No machinery, by decision. Re-syncing means diffing upstream against `82f1d4f` and reapplying by hand.
