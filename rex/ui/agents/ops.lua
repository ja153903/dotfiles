-- Effects on agents: choose them in the palette, jump to them, type into them, close them, and
-- review their changes in a floating pane. Call only from an action's run function.

local fn = require("ui.fn")
local model = require("ui.agents.model")

local M = {}

local shell = "com.superlogical.terminal.shell"

-- Choose from agents. Returns one agent, or a list with opts.multiple; nil when cancelled.
-- opts: title, confirm, multiple, selected (a predicate that starts matching items ticked).
function M.pick(agents, opts)
  local items = fn.map(agents, function(agent)
    local item = model.to_item(agent)
    item.selected = opts.selected and opts.selected(agent) or nil
    return item
  end)
  local answer = rex.ui.pick{
    title = opts.title,
    placeholder = "Filter agents",
    confirm = opts.confirm,
    multiple = opts.multiple,
    items = items,
  }
  if answer == nil then return nil end

  local by_id = fn.index_by(agents, function(agent) return agent.block_id end)
  if opts.multiple then
    return fn.map(answer, function(id) return by_id[id] end)
  end
  return by_id[answer]
end

function M.focus(agent)
  rex.session.focus_block(model.where(agent))
  rex.client.queue("session.select", { session_id = agent.session_id, window_id = agent.window_id })
end

-- Type a line into the agent and press Return.
function M.send(agent, text)
  local args = model.where(agent)
  args.data = text .. "\r"
  return rex.block.call(model.terminal, "write", args)
end

function M.close(agent)
  return rex.call("block.close", model.where(agent))
end

-- The agent process's directory; falls back to the last directory a shell reported.
function M.cwd(agent)
  local where = model.where(agent)
  local proc = rex.block.call(model.terminal, "process", where) or {}
  local dir = (proc.foreground or {}).cwd or (proc.child or {}).cwd
  if dir then return dir end
  local reported = rex.block.call(model.terminal, "pwd", where)
  return reported and reported.pwd and model.path_of(reported.pwd)
end

-- A focused floating terminal over the current window running argv; it closes when argv exits.
function M.overlay(argv, cwd)
  -- The app puts focus back on the previous pane as a rex.ui prompt closes, so a layer created at
  -- the same moment loses it. Wait for the prompt to finish closing first.
  -- ponytail: fixed delay; replace with a client focus action if Rex adds one.
  rex.exec({ "sleep", "0.35" })
  local _, err = rex.session.new_layer{
    bounds = { 0.06, 0.06, 0.88, 0.88 },
    focus = true,
    layout = rex.layout.block{ flavor = shell, options = { command = argv, cwd = cwd } },
  }
  if err ~= nil then rex.log("warn", "agents: " .. tostring(err)) end
end

-- Open lazygit in the agent's working directory.
function M.review(agent)
  local dir = M.cwd(agent)
  if dir == nil then
    rex.log("warn", "agents: no working directory reported for " .. agent.block_id)
    return
  end
  M.overlay({ "lazygit" }, dir)
end

return M
