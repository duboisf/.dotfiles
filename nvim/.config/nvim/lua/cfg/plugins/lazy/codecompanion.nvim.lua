local function fidget_progress()
  local progress = require("fidget.progress")

  local M = {}

  function M:init()
    local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionRequestStarted",
      group = group,
      callback = function(request)
        local handle = M:create_progress_handle(request)
        M:store_progress_handle(request.data.id, handle)
      end,
    })

    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionRequestFinished",
      group = group,
      callback = function(request)
        local handle = M:pop_progress_handle(request.data.id)
        if handle then
          M:report_exit_status(handle, request)
          handle:finish()
        end
      end,
    })
  end

  M.handles = {}

  function M:store_progress_handle(id, handle)
    M.handles[id] = handle
  end

  function M:pop_progress_handle(id)
    local handle = M.handles[id]
    M.handles[id] = nil
    return handle
  end

  function M:create_progress_handle(request)
    return progress.handle.create({
      title = " Requesting assistance (" .. request.data.strategy .. ")",
      message = "In progress...",
      lsp_client = {
        name = M:llm_role_title(request.data.adapter),
      },
    })
  end

  function M:llm_role_title(adapter)
    local parts = {}
    table.insert(parts, adapter.formatted_name)
    if adapter.model and adapter.model ~= "" then
      table.insert(parts, "(" .. adapter.model .. ")")
    end
    return table.concat(parts, " ")
  end

  function M:report_exit_status(handle, request)
    if request.data.status == "success" then
      handle.message = "Completed"
    elseif request.data.status == "error" then
      handle.message = " Error"
    else
      handle.message = "󰜺 Cancelled"
    end
  end

  return M
end

---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  version = "v15.*",
  opts = {
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "gpt-4.1"
            },
          },
        })
      end
    },
    strategies = {
      chat = {
        keymaps = {
          send = {
            modes = { i = "<C-CR>" }
          },
        },
      },
    },
    prompt_library = {
      ["WriteGoTests"] = {
        strategy = "chat",
        description = "Write Go tests for a file",
        opts = {
          is_slash_cmd = false,
          auto_submit = false,
          short_name = "golang_tests",
        },
        prompts = {
          {
            role = "user",
            content =
            [[#buffer Write BDD-style unit tests for this file. Add the _test suffix to the package name to avoid having access to internals. Wrap group the unit tests that test the same method togeter in the same function, use t.Run and t.Parallel. So for method Foo.Call, create a function TestFoo_Call(t *testing.T) that has several tests for Foo.Call inside. For the t.Run description, use spaces between words for the description.]]
          },
        },
      },
    },
  },
  config = function(_, opts)
    local cc = require('codecompanion')
    cc.setup(opts)
    vim.keymap.set('n',
      '<leader>c',
      ':CodeCompanionChat Toggle<CR>',
      { desc = "Toggle CodeCompanionChat", nowait = true }
    )
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "codecompanion",
    --   callback = function()
    --     print("hi")
    --     vim.o.number = false
    --     vim.o.relativenumber = false
    --   end
    -- })
  end,
  init = function()
    fidget_progress():init()
  end,
  dependencies = {
    "j-hui/fidget.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
