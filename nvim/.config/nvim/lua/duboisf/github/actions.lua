local actions = {}

local function searchAndReplaceTag(buf, action, tag, sha)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local escapeAction = action:gsub("%-", "%%-")
  local pattern = string.format("^%%s+%%-?%%s+uses: %s@%s$", escapeAction, tag)
  -- vim.notify("searching for pattern " .. pattern, vim.log.levels.DEBUG)
  local found = false
  for i, line in ipairs(lines) do
    if line:find(pattern) then
      found = true
      lines[i] = line:gsub("@.+", "@" .. sha .. " # " .. tag)
    end
  end
  if found then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
end

local function replaceTagWithCommitSha(buf, action, tag)
  local repo = string.gsub(action, "^([^/]+)/([^/]+).*", "%1/%2")
  local on_exit = vim.schedule_wrap(function(obj)
    if obj.code == 0 then
      if #obj.stdout > 0 then
        local commitSha = obj.stdout:sub(1, 40)
        -- vim.notify(string.format("replacing action %s tag %s with %s", action, tag, commitSha), vim.log.levels.DEBUG)
        searchAndReplaceTag(buf, action, tag, commitSha)
      else
        error(string.format("tag %s not found for actions %s", action, tag))
      end
    else
      error(string.format("Failed to get commit sha for %s@%s:\n:%s", repo, tag, obj.stderr))
    end
  end)
  vim.system({ "git", "ls-remote", "https://github.com/" .. repo, tag }, { text = true }, on_exit)
end

local function isActionInIgnoreList(orgsToIgnore, action)
  for _, org in ipairs(orgsToIgnore) do
    if action:match("^" .. org .. "/") then
      return true
    end
  end
  return false
end

function actions.UpdateTagsWithCommitSha(orgsToIgnore)
  local orgsToIgnore = orgsToIgnore or {}
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local actions = {}
  for _, line in ipairs(lines) do
    local actionWithTag = line:match("^%s+%-?%s+uses: (.+@v[%d%.]+)")
    if actionWithTag ~= nil and not isActionInIgnoreList(orgsToIgnore, actionWithTag) then
      -- vim.notify(string.format("Found action %s", actionWithTag), vim.log.levels.DEBUG)
      actions[actionWithTag] = ""
    end
  end
  for actionWithTag, _ in pairs(actions) do
    -- vim.notify("processing action " .. actionWithTag)
    local action, tag = actionWithTag:match("^(.+)@(.+)$")
    local ok, err = pcall(replaceTagWithCommitSha, buf, action, tag)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

return actions
