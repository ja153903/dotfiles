# Porting pstack to Claude Code

**Status:** approved design, ready for implementation planning
**Date:** 2026-09-01
**Upstream:** [cursor/plugins `pstack`](https://github.com/cursor/plugins/tree/main/pstack) v0.14.6
**Upstream commit:** `82f1d4f49ba8f21e3315a89c97e82f7c02a48fba` (2026-09-01)

## Goal

Port the pstack Cursor plugin to Claude Code in full, as a plugin living inside
this dotfiles repository. The port is a one-time hard fork: after translation we
own the result outright and re-syncing upstream is a manual chore we choose to
do, not automated machinery.

## Scope

Everything upstream ships:

- 45 skills, including the `poteto-mode` router and its 23 playbooks, the 21
  `principle-*` skills, and the workflow skills (`how`, `why`, `architect`,
  `arena`, `swarm`, `interrogate`, `reflect`, `recall`, `blast-radius`, `tdd`,
  `unslop`, `no-comments`, `technical-writing`, and the rest)
- 2 agents (`poteto-agent`, `comment-sicko`)
- the `benny` automation suite (skills only — see Non-goals)
- the Bun/TypeScript scripts (`orch`, `watch-pr`, `check-plan.mjs`,
  `worktree-audit.sh`, `bootstrap.ts`)
- the 10-part `docs/guide`, rewritten for Claude Code

## Non-goals

- **benny's Slack triggers.** Upstream benny is two Cursor Automations fired by
  Slack issue reports. Claude Code has no Automations equivalent. The three
  benny skills port intact but the trigger layer is dropped; they stay dormant
  and are installed into a target repo by `setup-benny` (see Decision 8).
- **Upstream re-sync machinery.** No transform script, no submodule. Hard fork.
- **Cross-vendor model panels.** Not achievable; see Decision 1.

## Decisions

### 1. Model routing maps onto the Claude family

Claude Code's `Agent` tool accepts only `sonnet`, `opus`, `haiku`, `fable`.
Upstream pstack routes roles across vendors (`grok-4.6-fast-xhigh`,
`gpt-5.6-sol-max`, `claude-fable-5-1-thinking-max`, `claude-opus-5-thinking-xhigh`).
Cross-vendor panels cannot be reproduced natively, and bridging to external CLIs
was rejected as unmaintainable.

Upstream encodes reasoning effort as a model-slug suffix (`-max`, `-xhigh`).
Claude Code has a first-class `effort` field (`low|medium|high|xhigh|max`), so
that half of the mapping is higher-fidelity than the slug it replaces.

| Role | Upstream | Ported |
|---|---|---|
| feature, refactoring | `grok-4.6-fast-xhigh` | `sonnet` · `high` |
| how explorer, why investigators, swarm workers | `grok-4.6-fast-xhigh` | `sonnet` · `high` |
| bug-fix, perf-issue, hillclimb | `claude-fable-5-1-thinking-max` | `fable` · `max` |
| judgment and prose, hardest tasks, how explainer | `claude-fable-5-1-thinking-max` | `fable` · `max` |
| why synthesizer, reflect judgment/divergent/synthesizer | `claude-fable-5-1-thinking-max` | `fable` · `max` |
| reflect tooling | `gpt-5.6-sol-max` | `opus` · `max` |
| 4-slot panels: how critics, arena runners, architect runners, interrogate reviewers | fable / gpt-sol / grok / opus | `fable`·`max`, `opus`·`max`, `opus`·`xhigh`, `sonnet`·`high` |

**Consequence — panel divergence must be re-sourced.** Two upstream vendor slots
collapse onto opus, so a same-family panel risks converging on the same reading
of the same diff. Upstream already ships per-role reviewer prompts
(`interrogate/references/reviewer-prompt.md`,
`reflect/references/{tooling,judgment,divergent}-reviewer.md`). We extend that
pattern so **every** panel slot carries an explicitly named adversarial lens.
This is the one place the port adds rather than translates, and it is forced by
this decision.

**Consequence — effort reaches subagents via agent files.** The `Agent` tool
takes `model` but has no `effort` parameter. Plugin agent definitions
(`agents/*.md`) do support `effort`. So `agents/` gains thin role agents (e.g.
`pstack:critic-deep` = opus·max, `pstack:worker-fast` = sonnet·high) that skills
spawn by `subagent_type`. Skills must not attempt to pass effort to `Agent`
directly.

### 2. The plugin lives inside this dotfiles repo

```
dotfiles/claude/plugins/
├── .claude-plugin/marketplace.json      # marketplace: "jaime-plugins"
└── pstack/
    ├── .claude-plugin/plugin.json       # name: pstack, version 0.14.6-claude.1
    ├── skills/                          # 45 skills → /pstack:how, /pstack:poteto-mode, …
    ├── agents/                          # poteto-agent, comment-sicko, + panel role agents
    ├── automations/benny/               # dormant; installed into a target repo by setup-benny
    ├── docs/guide/
    └── README.md                        # records the upstream commit above
```

Installed once with `/plugin marketplace add ~/programming/dotfiles/claude/plugins`
then `/plugin install pstack@jaime-plugins`. `setup.sh` records the marketplace
add so a fresh machine reproduces it.

Plugin namespacing (`pstack:tdd`, `pstack:recall`, `pstack:reflect`) prevents
collision with the personal skills already symlinked from
`~/.claude/skills` → `dotfiles/claude/skills`, and with bundled skills of the
same name. This is why a plugin was chosen over dropping 45 skill directories
into the existing flat skills folder.

### 3. Model configuration is read on demand, not always-applied

Upstream writes `~/.cursor/rules/pstack-models.mdc` with `alwaysApply: true`.
Claude Code has no always-applied rules file. The nearest equivalent — putting
it in `~/.claude/CLAUDE.md` — would load the table into every session's context,
including the majority that never delegate.

`setup-pstack` instead writes `~/.claude/pstack-models.md`, a plain markdown
file that the ~15 skills which delegate read on demand. Each such skill keeps
its existing structure: read the file if present, fall back to the inline
default otherwise. The file remains an override layer, not a requirement, and
re-running `setup-pstack` overwrites it whole so runs stay idempotent.

`setup-pstack`'s model-detection step changes from enumerating Cursor `Task`
slugs to the fixed Claude Code set (`sonnet`, `opus`, `haiku`, `fable`) crossed
with available effort levels, plus the `inherit` alias.

### 4. Sticky mode uses skill-registered hooks

Upstream `poteto-mode` is a Cursor sticky mode (`mode: true`) carrying a
`reminder:` string:

> `New task? Playbook match or rigor needed -> apply /poteto-mode. Casual turn or user opts out -> don't.`

Claude Code has no sticky modes, but skill frontmatter `hooks:` persist for the
rest of the session once the skill is invoked. `poteto-mode` registers a
`UserPromptSubmit` hook that re-injects that reminder, backed by a state file so
`pause-safely` and an explicit user opt-out can clear it.

**Fallback if the hook proves noisy in practice:** rely on the skill body
remaining in session context, which approximates upstream behavior. This is a
deliberate fallback, not a failure — record which one is in force in the plugin
README.

### 5. Frontmatter translation

Claude Code's skill frontmatter is a superset of what pstack uses, so most
fields pass through untouched.

| Upstream field | Ported |
|---|---|
| `name`, `description` | unchanged |
| `disable-model-invocation` (44 skills) | unchanged — same field, same meaning |
| `paths` (`typescript-best-practices`) | unchanged |
| `mode: true` (`poteto-mode`) | dropped; behavior moves to Decision 4 |
| `reminder` (`poteto-mode`) | becomes the hook's injected text |
| `icon`, `color` (`poteto-mode`) | dropped — no Claude Code equivalent |

Agent frontmatter gains `model` and `effort` per Decision 1.

### 6. Mechanical substitutions across the tree

| Upstream | Ported |
|---|---|
| `Task` tool | `Agent` tool |
| `subagent_type: generalPurpose` | `subagent_type: general-purpose` |
| `AskQuestion` | `AskUserQuestion` |
| `todolist` | `TodoWrite` |
| `environment: "cloud"` + `run_in_background: true` | background `Agent` with `isolation: "worktree"`; note that `isolation: "remote"` exists but is access-gated |
| `environment: "local"` | plain `Agent` (the default) |
| `cloud_base_branch` | explicit worktree/branch setup in the brief |
| `~/.cursor/rules/pstack-models.mdc` | `~/.claude/pstack-models.md` |
| `.cursor/skills/` | `.claude/skills/` |
| `.cursor/settings.json` | `.claude/settings.json` |
| `.cursor/automations/benny/`, `.cursor/benny/` | `.claude/benny/` |
| `.cursor/projects/`, `.cursor/worktrees/` | the user's worktree path |
| Bugbot | `/code-review` plus GitHub PR review threads |
| `/add-plugin pstack` | `/plugin install pstack@jaime-plugins` |
| `/loop` | **unchanged** — Claude Code has `/loop` |

Slack, Linear, Sentry, Datadog and Notion references in `why/references/sources/`
are MCP-based and harness-agnostic; they carry over unchanged.

### 7. Scripts need repackaging, not redesign

`orch`, `watch-pr`, `check-plan.mjs`, `worktree-audit.sh` and `bootstrap.ts` are
Bun/node CLIs over `gh` and a local store. Nothing in them is Cursor-coupled.

- rename the package from `@cursor-skill/poteto-mode-tools`
- path references become `${CLAUDE_PLUGIN_ROOT}`-relative
- skills that shell out gain matching `allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/…)` grants
- `bun` is added to `mise.toml`

Their existing `bun test` and `tsc --project watch-pr/tsconfig.json --noEmit
--strict` suites are the regression net for this section and must stay green.

### 8. benny ports as dormant skills

Upstream benny is deliberately dormant: its files are setup sources merged into
a *target* repository, not slash skills in the plugin. That intent is preserved.
`automations/benny/` stays outside the scanned `skills/` directory, and
`setup-benny` merges it into a target repo — writing configuration to
`.claude/benny/` and skills to the target's `.claude/skills/`, preserving
destination-only files and surfacing conflicts rather than overwriting local
edits. Only the Slack/Automation trigger layer is dropped.

## Verification

1. `claude plugin validate .` passes on the marketplace directory.
2. All 45 skills appear in the `/plugin` listing under the `pstack` namespace.
3. Grep proves no residual `Task` tool references, `AskQuestion`, `.cursor/`
   paths, or Cursor model slugs outside quoted upstream provenance.
4. Scripts typecheck and their test suites pass.
5. Smoke tests: `/pstack:how` on a real subsystem, `/pstack:interrogate` on a
   real diff, and `/pstack:poteto-mode` correctly routing a request to a
   playbook.
6. A panel skill (`/pstack:interrogate`) demonstrably spawns four agents with
   four distinct lenses, confirming Decision 1's divergence mechanism.
