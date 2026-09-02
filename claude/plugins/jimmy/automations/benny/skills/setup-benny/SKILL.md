---
name: setup-benny
description: Install Benny into a target repository and configure its triage and repro workflows. Use when installing Benny or changing its Slack, tracker, repository, routing, control, model, or budget settings.
disable-model-invocation: true
---

# Set up Benny

Benny ships as a dormant pack inside pstack. The plugin manifest exposes only pstack's normal skill root; this file and the two operational files are not slash skills of this plugin.

The human enters setup by pointing Claude Code at the pack's `FOR_AGENTS.md`. The bootstrap flow copies the whole pack into the target repository, then reads this file directly at `.claude/benny/skills/setup-benny/SKILL.md`.

Benny needs external configuration and its two workflow skills installed in the target repository. There is no trigger layer: the user invokes `/triage-issue-reports` and `/reproduce-and-fix-issues` by hand.

Never put a secret value in plugin files or committed configuration.

## 1. Copy the pack and install shared pstack skills

Do this before asking for Benny configuration.

Ask which repository will run the workflows. The source pack is the directory containing `FOR_AGENTS.md`. The destination is `<target-repository>/.claude/benny/`.

Merge the entire source pack into the destination:

1. Create the destination when it is absent.
2. Copy every source file to the same relative path.
3. Preserve destination-only files. Never delete unrelated files during install or refresh.
4. Never overwrite user-owned configuration, feature maps, or routing maps. Those live in `.claude/benny/` at paths the pack does not manage.
5. When an existing source-managed file differs, inspect the diff and merge without discarding local edits. If ownership is ambiguous, stop and ask before replacing it.
6. Verify that the destination contains `FOR_AGENTS.md`, this setup file, both operational files, their references, and the templates.

If this file is already being read from the target destination, treat the copy as complete and run the same verification before continuing.

Then install the three skills so the user can invoke them. Copy `skills/setup-benny/`, `skills/triage-issue-reports/`, and `skills/reproduce-and-fix-issues/` — each with its `references/` directory — into `<target-repository>/.claude/skills/`, under the same merge rules as the pack itself.

Install pstack in the target repository for Benny's shared dependencies:

```
/plugin install pstack@jaime-plugins
```

Start a fresh agent rooted in the target repository. Verify that these shared pstack skills resolve there:

- `how`
- `why`
- `tdd`
- `unslop`
- `principle-separate-before-serializing-shared-state`
- `principle-minimize-reader-load`
- `principle-guard-the-context-window`
- `principle-sequence-verifiable-units`
- `principle-fix-root-causes`
- `principle-prove-it-works`

Do not count a skill loaded from the current session. The check must show that a fresh agent in the target repository resolves them.

If any shared dependency does not resolve, stop and explain the failure.

The Benny pack under `.claude/benny/` is reference material, not a skill root. Do not add it to a plugin manifest. The installed copies under `.claude/skills/` are what make `/triage-issue-reports` and `/reproduce-and-fix-issues` invocable.

Tell the user that `.claude/benny/`, the installed skills, and any referenced secret-free configuration must be committed before either workflow is used. Do not commit them unless the user asks.

## 2. Adapt the configuration

Open these copied examples:

- `../../templates/configuration.example.yaml`
- `../reproduce-and-fix-issues/references/feature-map.example.md`

Create user-owned copies at paths the pack does not manage. These are configuration files, not pack files. Example locations:

- Project config, such as `.claude/benny/configuration.yaml`
- Project feature map, such as `.claude/benny/feature-map.md`
- Project routing map, such as `.claude/benny/routing.md`
- User config, such as `~/.config/benny/configuration.yaml`
- User feature map, such as `~/.config/benny/feature-map.md`

Fill one feature-map section for every user-facing feature Benny may reproduce. Keep it at the user point of view. Do not freeze implementation details or current code paths in the map.

Do not edit the copied examples. Pack refreshes may update source-managed files after conflict review, but they must never touch the user-owned copies.

Keep these files committed and secret-free so a fresh checkout of the target repository can read them. Reference them by stable repository-relative paths. Never reference the plugin source directory or a plugin cache path.

## 3. Fill the required choices

Ask for or confirm:

- Source Slack channel ID
- Optional operations or status channel ID
- Repository URL and default branch
- Triage identity or Slack user ID
- Issue tracker type, team, project, labels, and intake status
- Tracker adapter skill or MCP actions
- Optional routing map path
- Required control skill name
- Required user-facing feature-map path
- Status emoji strings
- Pull request URL format
- Polling and effort budgets
- Model slug for triage, repro, code work, and media review

Use only model identifiers the user's Claude Code install actually offers, or `inherit` to take the parent session's model. `~/.claude/pstack-models.md` shows what they already configured. Do not guess an identifier and do not carry over a private default.

The source channel, triage identity, repository, tracker adapter, control skill, and feature map must be explicit. Fail setup if any required value stays ambiguous.

## 4. Check integration capabilities

The triage workflow needs:

- Read access to the configured source Slack channel and its threads
- Thread-reply access in that channel
- Attachment metadata and file download access when reports include media
- Search, read, create, and update access through the configured issue-tracker adapter

The repro workflow needs:

- Read access to the source thread
- Thread-reply access in the source channel
- Optional post and edit access in the configured operations channel
- Repository read and history access
- A pull request action that can open a draft pull request
- The configured control-adapter skill

Prefer a configured Slack MCP server for reads and posts. The optional `BENNY_SLACK_BOT_TOKEN` may fill a narrow gap such as editing one operations status message or downloading an attachment. Store the value in a secret manager or environment, not in YAML.

Do not use undocumented integration endpoints.

## 5. Prepare the routing map

If the user wants reroutes or owner pings:

1. Copy `../triage-issue-reports/references/routing.example.md` to a user-owned path the pack does not manage, such as `.claude/benny/routing.md`.
2. Replace every placeholder with public or organization-local values.
3. Keep owner pings off by default.
4. Allow a ping only for a configured feature owner or a confirmed likely regression author.

If no routing map is configured, triage may classify a report but must not guess a destination or owner.

## 6. Verify the control adapter

Read `../reproduce-and-fix-issues/references/control-adapter.md` and the user's completed feature map.

Confirm that the named skill can:

- Bring up the target app
- Navigate every mapped feature through the real UI
- Exercise mapped states through declared adapter actions
- Inspect state without forcing the result
- Capture screenshots
- Start and stop a recording
- Clean up its processes and temporary data

If any capability is missing, do not run the repro workflow. It must fail closed rather than claim a reproduction it did not perform.

## 7. Hand off the two workflows

Read `../../FOR_AGENTS.md` from the copied pack and confirm the finished configuration matches the user's stated intent for both workflows.

Then tell the user how to run them in the target repository:

- `/triage-issue-reports`, pointed at one top-level report in the configured source Slack channel. It reads that thread, classifies, dedupes against the tracker, and posts exactly one thread reply ending in `[benny:bug]`, `[benny:performance]`, or `[benny:other]`.
- `/reproduce-and-fix-issues`, pointed at the same report. It waits for the trusted triage marker, reproduces through the mapped real UI, and may open one draft pull request.

Neither runs on its own. Nothing polls, nothing fires on a Slack event, and no scheduler is involved. If the user asks for automatic triage, tell them this port has no trigger layer.

Both skills read their own operational file. Do not paraphrase their contents into a wrapper prompt.

## 8. Test thread safety

Use a test channel or a harmless test report.

Before testing, confirm that `.claude/benny/`, the installed skills, and every referenced secret-free configuration file are committed on the branch the workflows run from. If any check fails, stop and tell the user the workflows are not ready.

Verify:

1. Triage stores the root `thread_ts` and posts exactly one verdict as a reply.
2. The verdict contains one configured marker.
3. Repro accepts the marker only from the configured triage identity.
4. Repro keeps the same immutable source coordinates.
5. No source-channel root message appears.
6. A delegated worker cannot use any Slack write action.
7. Missing coordinates, a deleted parent, or a failed preflight produces no post and no tracker issue.

Use Benny on real reports only after all seven checks pass.
