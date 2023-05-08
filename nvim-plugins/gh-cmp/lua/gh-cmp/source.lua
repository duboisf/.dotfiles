local github = require "gh-cmp.github"
local a = require "plenary.async"

---@alias BufferNumber number

---@class Source
---@field private cache ghcmp.Cache
---@field private github_owner string
local source = {}

---@enum ghcmp.SocialAccountProviderIcon
local social_account_provider_icons = {
  TWITTER = "",
}

---@param social_accounts ghcmp.SocialAccount[]
---@return string
local function format_social_accounts(social_accounts)
  local results = {}
  for _, social_account in ipairs(social_accounts) do
    local icon = social_account_provider_icons[social_account.provider] or ""
    if icon ~= "" then
      icon = icon .. " "
    end
    table.insert(results, string.format("%s[%s](%s)", icon, social_account.displayName, social_account.url))
  end
  return table.concat(results, "\n")
end

---Format documentation for nvim-cmp
---@param data ghcmp.CompletionItemData
---@return string
local function format_documentation(data)
  local edge = data.edge
  local member = edge.node
  local role = edge.role:sub(1, 1) .. edge.role:sub(2):lower()
  local documentation = role .. " of " .. data.org_name .. " org\n"
  if member.location ~= nil then
    documentation = documentation .. string.format("Located in %s\n", member.location)
  end
  if member.company ~= nil then
    documentation = documentation .. string.format("Works at %s\n", member.company)
  end
  local social_accounts = format_social_accounts(member.socialAccounts.nodes)
  if social_accounts ~= "" then
    documentation = documentation .. social_accounts .. "\n"
  end
  if member.bio ~= nil then
    documentation = documentation .. "\n" .. member.bio
  end
  return documentation
end

---@class ghcmp.CompletionItem: lsp.CompletionItem
---@field data ghcmp.CompletionItemData

---@class ghcmp.CompletionItemData
---@field org_name string
---@field edge ghcmp.OrgMemberEdge

---Format a single item for nvim-cmp
---@param edge ghcmp.OrgMemberEdge
---@return ghcmp.CompletionItem
local function format_item(edge)
  local member = edge.node
  local label = member.name or ""
  if label == "" then
    label = "@" .. member.login
  else
    label = label .. " (@" .. member.login .. ")"
  end
  return {
    label = label,
    insertText = "@" .. member.login,
    data = edge,
    cmp = {
      kind_hl_group = "CmpItemKindUser",
      kind_text = "User",
    },
    dup = 1,
  }
end

--- Return a new instance of this source.
---@param cache ghcmp.Cache
---@param github_owner string
---@return Source
local function new(cache, github_owner)
  local self = { cache = cache, github_owner = github_owner }
  self = setmetatable(self, { __index = source })
  return self
end

---Return whether this source is available in the current context or not (optional).
---@param self Source
---@return boolean
function source:is_available()
  return true
end

---Return the debug name of this source (optional).
---@param self Source
---@return string
function source:get_debug_name()
  return "GitHub users"
end

---Return LSP"s PositionEncodingKind.
---@NOTE: If this method is ommited, the default value will be `utf-16`.
---@param self Source
---@return lsp.PositionEncodingKind
function source:get_position_encoding_kind()
  return "utf-16"
end

---Return the keyword pattern for triggering completion (optional).
---If this is ommited, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@param self Source
---@return string
function source:get_keyword_pattern()
  return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
---@param self Source
---@return string[]
function source:get_trigger_characters()
  return { "@" }
end

---Invoke completion (required).
---@param self Source
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(_, callback)
  local response = self.cache:get(self.github_owner)
  if not response then
    github.org_users(self.github_owner, function(ok, results)
      response = { items = {}, isIncomplete = false }
      if ok and results then
        local edges = results.data.organization.membersWithRole.edges
        for _, edge in ipairs(edges) do
          local completion_item = format_item(edge)
          completion_item.data = {
            org_name = results.data.organization.name,
            edge = edge,
          }
          table.insert(response.items, completion_item)
        end
        callback(response)
      end
      self.cache:set(self.github_owner, response)
      a.void(function()
        self.cache:save()
      end)()
    end)
  else
    callback(response)
  end
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param self Source
---@param completion_item ghcmp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  completion_item.documentation = {
    kind = "markdown",
    value = format_documentation(completion_item.data),
  }
  callback(completion_item)
end

---Executed after the item was selected.
---@param self Source
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

return {
  new = new,
}
