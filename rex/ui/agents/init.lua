-- Agent actions. Each one composes model (what agents exist), ops (what to do to them), and prompts.

local fn = require("ui.fn")
local prompt = require("ui.prompt")
local model = require("ui.agents.model")
local ops = require("ui.agents.ops")
local spawn = require("ui.agents.spawn")

local function action(name, title, run, args)
  rex.action{ name = name, title = title, keywords = "agent claude codex", args = args, run = run }
end

-- An action that picks one agent and applies do_it to it.
local function pick_one(name, title, do_it)
  action(name, title, function()
    local agent = ops.pick(model.list(), { title = title:gsub("…$", "") })
    if agent then do_it(agent) end
  end)
end

pick_one("agents", "Go to Agent…", ops.focus)
pick_one("agents_review", "Review Agent Changes…", ops.review)

action("agents_next", "Go to Next Agent Needing You", function(ctx)
  local next_agent = fn.find(model.list(), function(agent)
    return model.needs_you(agent) and agent.block_id ~= ctx.block_id
  end)
  if next_agent then ops.focus(next_agent) end
end)

action("agents_close", "Close Agents…", function()
  local picked = ops.pick(model.list(), {
    title = "Close agents", confirm = "Close", multiple = true, selected = model.in_state("done"),
  })
  fn.each(picked or {}, ops.close)
end)

action("agents_send", "Send to Agents…", function()
  local picked = ops.pick(model.list(), { title = "Send to agents", confirm = "Next", multiple = true })
  if picked == nil or #picked == 0 then return end
  local text = rex.ui.input{ title = "Message", placeholder = "Typed into each agent, then Return" }
  if text == nil or text == "" then return end
  local question = string.format('Send "%s" to %d agent%s?', text, #picked, #picked == 1 and "" or "s")
  if not prompt.confirm(question, "Send") then return end
  fn.each(picked, function(agent) ops.send(agent, text) end)
end)

action("agent_new", "Start Agent…", spawn.run, spawn.args)
