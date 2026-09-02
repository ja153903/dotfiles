# benny

benny gives you two workflows for slack issue reports. one triages each report. the other reproduces confirmed bugs and may prepare a small draft fix.

benny's two workflows run on request — invoke `/triage-issue-reports` or
`/reproduce-and-fix-issues` in the target repository. There is no trigger layer;
nothing fires on its own.

the files in this directory are dormant setup sources. they do not appear as slash skills in this plugin.

## set it up

0. Install pstack in the target repository — benny depends on its `how`, `why`,
   `tdd`, `unslop`, and principle skills:

   ```
   /plugin install pstack@jaime-plugins
   ```

1. Point Claude Code at `FOR_AGENTS.md` and name the target repository.
2. Let setup merge this directory into the target at `.claude/benny/`, and its
   three skills into the target's `.claude/skills/`. It must preserve
   destination-only files and surface conflicts instead of overwriting local
   edits.
3. Keep user-owned configuration in `.claude/benny-config/`. Adapt
   [`configuration.example.yaml`](./templates/configuration.example.yaml) and
   [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md).
   A pack refresh replaces `.claude/benny/` wholesale and never touches
   `.claude/benny-config/`.
4. Commit `.claude/benny/`, `.claude/benny-config/`, and the installed skills
   before using either workflow. Send a harmless test report and verify the
   triage output.
