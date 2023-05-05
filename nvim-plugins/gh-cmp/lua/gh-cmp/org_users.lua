local utils = require "gh-cmp.utils"

---@alias BufferNumber number

---@class Source
---@field private cache org-users.Cache
---@field private github_owner string
local source = {}

local Job = require "plenary.job"

---@class ghcmp.OrgMembersQueryResult
---@field data ghcmp.OrgMembersQueryResultData

---@class ghcmp.OrgMembersQueryResultData
---@field organization ghcmp.Organization

---@class ghcmp.Organization
---@field name string The name of the organization
---@field membersWithRole ghcmp.OrgMemberConnection

---@class ghcmp.OrgMemberConnection
---@field edges ghcmp.OrgMemberEdge[]
---@field pageInfo ghcmp.PageInfo

---@class ghcmp.PageInfo
---@field hasNextPage boolean
---@field endCursor? string

---@alias ghcmp.Role
---| ""ADMIN""
---| ""MEMBER""

---@class ghcmp.OrgMemberEdge
---@field node ghcmp.User
---@field role ghcmp.Role

---@class ghcmp.User
---@field login string
---@field name string?
---@field bio string?
---@field location string?
---@field company string?
---@field socialAccounts ghcmp.SocialAccounts
---@field status ghcmp.Status

---@class ghcmp.Status
---@field emojiHTML string?
---@field indicatesLimitedAvailability boolean
---@field message string?

---@class ghcmp.SocialAccounts
---@field nodes ghcmp.SocialAccount[]

---@class ghcmp.SocialAccount
---@field displayName string
---@field provider string
---@field url string

---@param msg string
local function log(msg)
  vim.defer_fn(function() vim.notify(msg) end, 10)
end

local graphql_query = [[
  query ($org: String!, $endCursor: String) {
    organization(login: $org) {
      name
      membersWithRole(first: 100, after: $endCursor) {
        edges {
          node {
            login
            name
            bio
            location
            company
            socialAccounts(first:20) {
              nodes {
                displayName
                provider
                url
              }
            }
            status {
              emojiHTML
              indicatesLimitedAvailability
              message
            }
          }
          role
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
]]

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
---@param data ghcmp.users.org.CompletionItemData
---@return string
function source.format_documentation(data)
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

---@class ghcmp.users.org.CompletionItem: lsp.CompletionItem
---@field data ghcmp.users.org.CompletionItemData

---@class ghcmp.users.org.CompletionItemData
---@field org_name string
---@field edge ghcmp.OrgMemberEdge

---Format a single item for nvim-cmp
---@param edge ghcmp.OrgMemberEdge
---@return ghcmp.users.org.CompletionItem
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

---@type string
local cache_file = vim.fn.stdpath("cache") .. "/gh-cmp/org-users.json"

--- Load the cache from the cache file
---@return org-users.Cache?
local function load_cache_from_file()
  local data = utils.read_file(cache_file)
  if not data then
    return nil
  end
  ---@type boolean, org-users.Cache?
  local ok, result = pcall(vim.json.decode, data)
  if not ok then
    log("Failed to parse cache file: " .. result)
    return nil
  end
  return result
end

--- Write the cache to the cache file
---@param cache org-users.Cache
local function write_cache_to_file(cache)
  -- Check if directory exists
  local cache_folder = vim.fs.dirname(cache_file)
  log("Cache folder: " .. cache_folder)
  if vim.fn.isdirectory(cache_folder) == 0 then
    log("Creating cache directory " .. cache_folder)
    local ok, err = pcall(vim.fn.mkdir, cache_folder, "p", 0700)
    log("Mkdir result: " .. tostring(ok) .. " " .. tostring(err))
    if not ok then
      log("Failed to create cache directory: " .. err)
      return
    end
  end
  local fd = io.open(cache_file, "w+")
  if fd ~= nil then
    fd:write(vim.json.encode(cache))
    fd:close()
  else
    log("Failed to open cache file for writing")
  end
end

---@alias org-users.OrgNameCacheKey string
---@alias org-users.Cache table<org-users.OrgNameCacheKey, org-users.CacheItem>

---@class org-users.CacheItem
---@field last_fetch_timestamp number The timestamp of the last fetch in seconds since epoch
---@field items lsp.CompletionResponse

--- Return a new instance of this source.
---@param github_owner string
---@return Source
function source.new(github_owner)
  local cache = load_cache_from_file()
  if not cache then
    cache = {}
  end
  local mt = { cache = cache, github_owner = github_owner }
  local self = setmetatable(mt, { __index = source })
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
  if self.cache[self.github_owner] == nil then
    local job = Job:new({
      "gh",
      "api",
      "--paginate",
      "graphql",
      "-F",
      "org=" .. self.github_owner,
      "-f",
      "query=" .. graphql_query,
      on_exit = function(job, code)
        if code ~= 0 then return end
        ---@type lsp.CompletionResponse
        local result = { items = {}, isIncomplete = false }
        local cache_item = { last_fetch_timestamp = os.time(), items = result }
        self.cache[self.github_owner] = cache_item
        ---@type boolean, ghcmp.OrgMembersQueryResult?
        local ok, parsed = pcall(
          vim.json.decode,
          job:result()[1],
          { luanil = { object = true, array = true } }
        )
        if ok and parsed and parsed.data.organization then
          local edges = parsed.data.organization.membersWithRole.edges
          for _, edge in ipairs(edges) do
            local completion_item = format_item(edge)
            completion_item.data = {
              org_name = parsed.data.organization.name,
              edge = edge,
            }
            table.insert(result.items, completion_item)
          end
        end
        callback(result)
        -- write_cache_to_file(self.cache)
      end,
    })
    job:start()
  else
    callback(self.cache[self.github_owner])
  end
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param self Source
---@param completion_item ghcmp.users.org.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  completion_item.documentation = {
    kind = "markdown",
    value = source.format_documentation(completion_item.data),
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

return source
