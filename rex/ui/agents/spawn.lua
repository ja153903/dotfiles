-- Start Agent…: choose a provider, a project, optionally a fresh git worktree, and a first prompt,
-- then open the agent in a new tab. Every answer can also come from the action's args.

local fn = require("ui.fn")
local prompt = require("ui.prompt")

local M = {}

local shell = "com.superlogical.terminal.shell"
local projects_root = os.getenv("HOME") .. "/programming"

local providers = {
  { id = "claude", title = "Claude", command = "claude" },
  { id = "codex", title = "Codex", command = "codex" },
}
local provider_by_id = fn.index_by(providers, function(p) return p.id end)

local function basename(path) return path:match("([^/]+)/*$") end

local function run_ok(argv)
  local result = rex.exec(argv)
  return result ~= nil and result.ok, result
end

local function project_dirs()
  local ok, result = run_ok({ "find", projects_root, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-not", "-name", ".*" })
  if not ok then return {} end
  local dirs = {}
  for line in result.stdout:gmatch("[^\n]+") do dirs[#dirs + 1] = line end
  table.sort(dirs)
  return dirs
end

local function is_git_repo(dir)
  return (run_ok({ "git", "-C", dir, "rev-parse", "--is-inside-work-tree" }))
end

-- A new worktree beside dir on a new branch; returns its path, or nil and git's message.
local function add_worktree(dir, branch)
  local path = dir:gsub("/+$", "") .. "-" .. branch:gsub("[^%w%-_.]", "-")
  local ok, result = run_ok({ "git", "-C", dir, "worktree", "add", "-b", branch, path })
  if ok then return path end
  return nil, result and result.stderr
end

local function command_for(provider, first_prompt)
  if first_prompt == "" then return { provider.command } end
  return { provider.command, first_prompt }
end

local function ask_provider()
  local items = fn.map(providers, function(p) return { id = p.id, title = p.title, icon = "person" } end)
  return rex.ui.pick{ title = "Start agent", placeholder = "Provider", items = items }
end

local function ask_project()
  local items = fn.map(project_dirs(), function(dir)
    return { id = dir, title = basename(dir), subtitle = dir, icon = "folder" }
  end)
  return prompt.answer_text(rex.ui.pick{
    title = "Project", placeholder = "Filter projects, or type a path", items = items, allow_other = true,
  })
end

-- The directory to run in: dir itself, or a new worktree when the person asks for one.
local function ask_workdir(dir)
  if not is_git_repo(dir) then return dir end
  local choice = rex.ui.pick{
    title = basename(dir),
    items = {
      { id = "here", title = "Work in " .. basename(dir), icon = "folder" },
      { id = "worktree", title = "New worktree…", icon = "branch" },
    },
  }
  if choice ~= "worktree" then return choice and dir end
  local branch = rex.ui.input{ title = "Branch for the worktree", placeholder = "agent/…", value = "agent/" }
  if branch == nil or branch == "" then return nil end
  local path, err = add_worktree(dir, branch)
  if path == nil then rex.log("warn", "agents: git worktree add failed: " .. tostring(err)) end
  return path
end

local function ask_prompt(provider)
  return rex.ui.input{
    title = "First prompt for " .. provider.title,
    placeholder = "Leave empty to start without one",
    confirm = "Start",
  }
end

local function open_agent(provider, dir, first_prompt)
  local _, err = rex.session.new_window{
    window_label = provider.title .. " · " .. basename(dir),
    layout = rex.layout.block{
      flavor = shell,
      options = { cwd = dir, command = command_for(provider, first_prompt) },
    },
  }
  if err ~= nil then error(err, 0) end
end

M.args = { provider = "string?", dir = "string?", branch = "string?", prompt = "string?" }

function M.run(ctx, args)
  local provider = provider_by_id[args.provider or ask_provider() or ""]
  if provider == nil then return end

  local dir
  if args.dir and args.branch then
    local err
    dir, err = add_worktree(args.dir, args.branch)
    if dir == nil then error("git worktree add failed: " .. tostring(err), 0) end
  elseif args.dir then
    dir = args.dir
  else
    local project = ask_project()
    dir = project and ask_workdir(project)
  end
  if dir == nil then return end

  local first_prompt = args.prompt or ask_prompt(provider)
  if first_prompt == nil then return end

  open_agent(provider, dir, first_prompt)
end

return M
