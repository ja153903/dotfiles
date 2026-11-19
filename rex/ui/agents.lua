-- Go to Agent…: pick any terminal that reports program status (Claude Code, Codex, …) and jump to it.

local terminal = "com.superlogical.terminal"
local rank = { blocked = 1, error = 2, done = 3, working = 4, idle = 5 }
local providers = { ["claude-code"] = "Claude", codex = "Codex" } -- unknown apps show their raw id

-- The agent running in a block, or nil when nothing has reported status there.
local function agent_in(session, block)
  if block.creator_name ~= terminal or block.placement ~= "placed" then return nil end
  local where = { session_id = session.session_id, block_id = block.block_id }
  local status = rex.block.call(terminal, "program_status", where)
  local record = status and status.records and status.records[1]
  if record == nil then return nil end

  local app = record.effective_app
  local term = rex.block.call(terminal, "title", where)
  return {
    rank = rank[record.state] or 6,
    session_id = session.session_id,
    window_id = block.window_id,
    block_id = block.block_id,
    item = {
      id = block.block_id,
      title = (term and term.title ~= "" and term.title) or app or block.label,
      subtitle = table.concat({ providers[app] or app or "?", session.label, record.msg }, " · "),
      detail = record.state,
      icon = "terminal",
    },
  }
end

-- Every agent across all sessions, the ones waiting on you first.
local function list_agents()
  -- Without this, calls on sessions other than the action's fail with 409 "not attached".
  local result, err = rex.call("session.attach_all", { event_scope = "session" })
  if result == nil then
    rex.log("warn", "agents: " .. tostring(err))
    return {}
  end

  local agents = {}
  for _, session in ipairs(result.sessions or {}) do
    local list = rex.call("session.list_blocks", { session_id = session.session_id })
    for _, block in ipairs(list and list.blocks or {}) do
      local agent = agent_in(session, block)
      if agent then table.insert(agents, agent) end
    end
  end
  table.sort(agents, function(a, b) return a.rank < b.rank end)
  return agents
end

rex.action{
  name     = "agents",
  title    = "Go to Agent…",
  keywords = "claude codex agent",
  run      = function(ctx, args)
    local items, by_id = {}, {}
    for _, agent in ipairs(list_agents()) do
      table.insert(items, agent.item)
      by_id[agent.item.id] = agent
    end

    local id = rex.ui.pick{ title = "Agents", placeholder = "Filter agents", items = items }
    local agent = id and by_id[id]
    if agent == nil then return end

    rex.session.focus_block{ session_id = agent.session_id, block_id = agent.block_id }
    rex.client.queue("session.select", { session_id = agent.session_id, window_id = agent.window_id })
  end,
}
