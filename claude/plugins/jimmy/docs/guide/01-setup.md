# Set up jimmy

In this page you install the plugin, pick which models jimmy uses, and run your first task. Setup is one command plus a short conversation.

## Install the plugin

In a Claude Code chat, run:

```text
/plugin marketplace add ~/programming/dotfiles/claude/plugins
/plugin install jimmy@jaime-plugins
```

Claude Code confirms the plugin is installed.

## Pick your models

Run:

```text
/setup-jimmy
```

[`/setup-jimmy`](../../skills/setup-jimmy/SKILL.md) detects the models you have access to, shows you each role (code delegates, judgment, the review panels), and asks what you want. Answer the questions. It writes `~/.claude/jimmy-models.md`, a small config file every jimmy skill reads.

You only override what you care about. A role with no line in the config file keeps the skill's default. To restore a default later, delete that role's line, or just run `/setup-jimmy` again.

You might be wondering what happens if you use Auto. Set a role to `inherit` and jimmy omits the subagent `model` field, so the subagent inherits your parent session's model. It isn't a model slug. For a panel role the value is a list, and one subagent runs per entry, so the list length sets the panel size. Setup also configures `swarm workers`, the default model for every `/swarm` worker unless a race names a model for each arm.

## Accept the verification offer, or don't

At the end of setup, `/setup-jimmy` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.claude/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers when it earns its place.

No restart needed. Every jimmy skill reads `~/.claude/jimmy-models.md` when it runs, so the next invocation picks up what you just wrote.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/jimmy:mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. The first item is always "read the Principles section". The rest are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/jimmy:mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. `/jimmy:mode` is sticky. It stays on for the conversation until you opt out by saying so.

Next: [Route work through `/jimmy:mode`](./02-mode.md).
