-- Agents as data: find every terminal that reports program status, and pure views of the result.

local fn = require("ui.fn")

local M = {}

M.terminal = "com.superlogical.terminal"

local rank = { blocked = 1, error = 2, done = 3, working = 4, idle = 5 }
local providers = { ["claude-code"] = "Claude", codex = "Codex" } -- unknown apps show their raw id

function M.provider_name(app) return providers[app] or app or "?" end

function M.needs_you(agent)
  return agent.state == "blocked" or agent.state == "error" or agent.state == "done"
end

function M.in_state(state)
  return function(agent) return agent.state == state end
end

function M.where(agent)
  return { session_id = agent.session_id, block_id = agent.block_id }
end

-- A file:// URL from OSC 7, or a plain path, as a plain path.
function M.path_of(pwd)
  local path = pwd:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end))
end

function M.to_item(agent)
  return {
    id = agent.block_id,
    title = agent.title ~= "" and agent.title or agent.app or agent.label,
    subtitle = table.concat({ M.provider_name(agent.app), agent.session_label, agent.msg }, " · "),
    detail = agent.state,
    icon = "terminal",
  }
end

local function to_agent(session, block, record, title)
  return {
    session_id = session.session_id,
    session_label = session.label,
    window_id = block.window_id,
    block_id = block.block_id,
    label = block.label,
    title = title or "",
    app = record.effective_app,
    state = record.state,
    msg = record.msg,
  }
end

local function is_placed_terminal(block)
  return block.creator_name == M.terminal and block.placement == "placed"
end

-- The agent in a block, or nil when nothing has reported status there.
local function read_agent(session, block)
  local where = { session_id = session.session_id, block_id = block.block_id }
  local status = rex.block.call(M.terminal, "program_status", where)
  local record = status and status.records and status.records[1]
  if record == nil then return nil end
  local term = rex.block.call(M.terminal, "title", where)
  return to_agent(session, block, record, term and term.title)
end

local function agents_in(session)
  local list = rex.call("session.list_blocks", { session_id = session.session_id })
  local terminals = fn.filter(list and list.blocks or {}, is_placed_terminal)
  return fn.filter_map(terminals, function(block) return read_agent(session, block) end)
end

-- Every agent across all sessions, the ones waiting on you first.
function M.list()
  -- Without this, calls on sessions other than the action's fail with 409 "not attached".
  local result, err = rex.call("session.attach_all", { event_scope = "session" })
  if result == nil then
    rex.log("warn", "agents: " .. tostring(err))
    return {}
  end
  local agents = fn.flat_map(result.sessions or {}, agents_in)
  return fn.sort_by(agents, function(agent) return rank[agent.state] or 6 end)
end

return M
