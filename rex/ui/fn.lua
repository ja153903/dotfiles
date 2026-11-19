-- Small list helpers for composing pipelines. Each returns a new list and leaves its input alone.

local M = {}

function M.map(list, f)
  local out = {}
  for i, x in ipairs(list) do out[i] = f(x) end
  return out
end

function M.filter(list, keep)
  local out = {}
  for _, x in ipairs(list) do
    if keep(x) then out[#out + 1] = x end
  end
  return out
end

-- map, dropping nil results.
function M.filter_map(list, f)
  local out = {}
  for _, x in ipairs(list) do
    local y = f(x)
    if y ~= nil then out[#out + 1] = y end
  end
  return out
end

function M.flat_map(list, f)
  local out = {}
  for _, x in ipairs(list) do
    for _, y in ipairs(f(x)) do out[#out + 1] = y end
  end
  return out
end

function M.find(list, pred)
  for _, x in ipairs(list) do
    if pred(x) then return x end
  end
  return nil
end

function M.each(list, f)
  for _, x in ipairs(list) do f(x) end
end

function M.index_by(list, key)
  local out = {}
  for _, x in ipairs(list) do out[key(x)] = x end
  return out
end

function M.sort_by(list, key)
  local out = M.map(list, function(x) return x end)
  table.sort(out, function(a, b) return key(a) < key(b) end)
  return out
end

return M
