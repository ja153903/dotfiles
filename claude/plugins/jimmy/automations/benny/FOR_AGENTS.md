# benny intent

## what i want

i want two workflows that work together on one slack issue channel. i invoke each one myself; nothing fires on its own.

### workflow 1: triage issue reports

- entry: i invoke `/triage-issue-reports` and point it at one top-level report in my configured source slack channel. it keeps that report's original thread coordinates.
- behavior: i want it to read the thread and attachments, classify the report as a bug or performance issue, feature request, question or feedback, or reroute, and trace the likely owning layer before routing.
- tracker: i want it to search my configured tracker for duplicates, update a confident duplicate, and create a ticket only for a clear net-new bug.
- tools: i want slack thread read and reply access, my configured tracker integration, and my optional routing map.
- outcome: i want exactly one reply in the source thread with a short verdict and `[benny:bug]`, `[benny:performance]`, or `[benny:other]`. a bug or performance marker may include the tracker url.
- boundary: i never want it to post a root message in the source channel.

### workflow 2: reproduce and fix confirmed bugs

- entry: i invoke `/reproduce-and-fix-issues` on the same top-level report. it acts only after the trusted triage marker is present in the original thread.
- gates: i want it to stop when someone clearly owns the fix. if an existing pull request or merged commit may fix the report, i want verification instead of a competing change.
- behavior: i want it to use my configured control adapter and feature map, reproduce the exact symptom twice through the real ui, and capture screenshots, video, and a read-only state cross-check.
- fix: i want it to verify existing pull requests without authoring over them. after a confirmed repro, it may attempt one bounded root-cause fix, use tdd when the test is cheap, smoke the blast radius, and open a draft pull request only when before-and-after proof passes.
- tools: i want slack thread read and reply access, repository and history access, draft pull request creation, my configured tracker, and my control adapter.
- outcome: i want evidence and a verified result in the source or optional operations threads, plus an optional draft pull request. updates should be concise.
- boundary: i never want it to post a root message in the source channel.

### shared rules

- i want the source channel and root thread coordinates to stay immutable for the whole run.
- i treat utility and debug bots as evidence, not delegation or fix ownership.
- i allow subagents to help, but they cannot post to slack or receive slack credentials.
- i want this entire pack committed at `.claude/benny/` in the target repository, and its three skills installed into the target's `.claude/skills/`.
- i want jimmy installed in the target repository only for shared dependencies such as `how`, `why`, `tdd`, `unslop`, and the required principle skills.
- i keep user-owned configuration, feature maps, routing maps, and secrets in `.claude/benny-config/`. a pack refresh replaces `.claude/benny/` wholesale and never touches `.claude/benny-config/`, so it cannot overwrite them.
- i want both workflows to fail closed when channel coordinates, tracker access, the control adapter, or the feature map are missing or uncertain.
- i want draft pull requests only. do not merge or deploy.

### my configuration

- source slack channel: `<channel>`
- optional operations channel: `<channel or none>`
- repository and default branch: `<repo>`, `<branch>`
- tracker: `<type, team, project, labels, intake status>`
- routing map: `<path or none>`
- triage identity: `<slack identity>`
- control skill: `<configured skill or adapter>`
- feature map: `<committed same-repo path under .claude/benny-config/, or behavior to paraphrase>`
- models: `<triage, reproduce, code, media review>`
- status emoji strings: `<seen, reproducing, reproduced, blocked, fixing, failed, pull request opened>`
- budgets: `<polling, verdict wait, follow-up, repro, rejection, fix>`
- optional bot token capability: `<none, file download, or editable operations status>`

start from [`configuration.example.yaml`](./templates/configuration.example.yaml) and [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md). copy and fill them outside this pack, under `.claude/benny-config/`. keep secret values in a secret manager or environment.

## for the agent

the human enters setup by pointing claude code at this file. do not look for or invoke a discovered benny slash skill in this plugin.

1. ask which repository will run the workflows.
2. treat the directory containing this `FOR_AGENTS.md` as the source pack.
3. merge the entire source pack into `<target-repository>/.claude/benny/`, and install its three skills into `<target-repository>/.claude/skills/`.
4. preserve every destination-only file. never delete unrelated files, and never write into `<target-repository>/.claude/benny-config/` — that directory is the user's.
5. a refresh replaces `.claude/benny/` wholesale — nothing hand-edited belongs there. if you find local edits to a pack file, stop and ask before replacing it, and move anything worth keeping into `.claude/benny-config/`.
6. verify that the copied `FOR_AGENTS.md` and `skills/setup-benny/SKILL.md` exist in the target repository.
7. read and follow `.claude/benny/skills/setup-benny/SKILL.md` directly from the target repository.

i want jimmy installed in the target repository for shared dependencies:

```
/plugin install jimmy@jaime-plugins
```

i want verification from a fresh agent rooted in the target repository. confirm that jimmy's `how`, `why`, `tdd`, `unslop`, and the principle skills used by benny resolve there. do not count skills loaded from the current session.

if any shared dependency does not resolve, stop and explain what failed. do not add `.claude/benny/skills/` to a plugin manifest — the installed copies under the target's `.claude/skills/` are what make the two workflows invocable.

tell me that `.claude/benny/`, `.claude/benny-config/`, and the installed skills must be committed before either workflow is used.
