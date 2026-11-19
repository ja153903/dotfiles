-- Reusable palette prompts built on rex.ui. Call only from an action's run function.

local M = {}

-- True only when the person explicitly picks the confirm row.
function M.confirm(title, yes)
  local answer = rex.ui.pick{
    title = title,
    items = { { id = "yes", title = yes }, { id = "no", title = "Cancel" } },
  }
  return answer == "yes"
end

-- The text typed into a pick with allow_other, or the chosen id.
function M.answer_text(answer)
  if type(answer) == "table" then return answer.text end
  return answer
end

return M
