local Job = require 'plenary.job'
local source = {}

---@class QueryResult
---@field data Data

---@class Data
---@field organization Organization

---@class Organization
---@field membersWithRole MembersWithRole

---@class MembersWithRole
---@field edges Edge[]
---@field pageInfo PageInfo

---@class PageInfo
---@field hasNextPage boolean
---@field endCursor string
--
---@class Edge
---@field node Node
---@field role string

---@class Node
---@field login string
---@field name string
---@field bio string
---@field location string

local graphql_query = [[
  query ($org: String!, $endCursor: String) {
    organization(login: $org) {
      membersWithRole(first: 100, after: $endCursor) {
        edges {
          node {
            login
            name
            bio
            location
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

--- log a message using a combination of vim.notify and vim.defer_fn
---@param msg string
---@return nil
local log = function(msg)
  vim.defer_fn(function() vim.notify(msg) end, 10)
end

---Format a single item for nvim-cmp
---@param edge Edge
---@return lsp.CompletionResponse
local function format_item(edge)
  local member = edge.node
  local label = member.name or ''
  if label == '' then
    label = '@' .. member.login
  else
    label = label .. ' (@' .. member.login .. ')'
  end
  local role = edge.role:sub(1, 1) .. edge.role:sub(2):lower()
  local documentation = role
  if member.location ~= nil then
    documentation = documentation .. ', located in ' .. member.location
  end
  if member.bio ~= nil then
    documentation = documentation .. '\n\n' .. member.bio
  end
  return {
    label = label,
    insertText = '@' .. member.login,
    documentation = {
      kind = 'markdown',
      value = documentation,
    },
    cmp = {
      kind_hl_group = 'CmpItemKindUser',
      kind_text = 'User',
    },
    dup = 1,
  }
end

function source.new()
  local self = setmetatable({ cache = {} }, { __index = source })
  return self
end

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  return true
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
  return 'GitHub users'
end

---Return LSP's PositionEncodingKind.
---@NOTE: If this method is ommited, the default value will be `utf-16`.
---@return lsp.PositionEncodingKind
function source:get_position_encoding_kind()
  return 'utf-16'
end

---Return the keyword pattern for triggering completion (optional).
---If this is ommited, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@return string
function source:get_keyword_pattern()
  return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
  return { '@' }
end

---Invoke completion (required).
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(_, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  if self.cache[bufnr] == nil then
    local job = Job:new({
      'gh',
      'api',
      '--paginate',
      'graphql',
      '-F',
      'org={owner}',
      '-f',
      'query=' .. graphql_query,
      on_exit = function(job)
        ---@type lsp.CompletionResponse
        local result = { items = {}, isIncomplete = false }
        self.cache[bufnr] = result
        local ok, parsed = pcall(
          vim.json.decode,
          job:result()[1],
          { luanil = { object = true, array = true } }
        )
        if not ok then
          log('Failed to parse JSON result from gh api command')
        elseif ok and parsed and parsed.data.organization then
          local edges = parsed.data.organization.membersWithRole.edges
          for _, edge in ipairs(edges) do
            table.insert(result.items, format_item(edge))
          end
        else
          log('Failed to parse JSON result from gh api command')
        end
        callback(result)
      end,
    })
    job:start()
  else
    callback(self.cache[bufnr])
  end
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  callback(completion_item)
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

return source
