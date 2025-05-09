local function spinner()
  local M = {
    ---@type boolean
    processing = false,
    ---@type integer
    spinner_index = 1,
    ---@type integer?
    namespace_id = nil,
    ---@type uv.uv_timer_t?
    timer = nil,
    ---@type string[]
    spinner_symbols = {
      "⠋",
      "⠙",
      "⠹",
      "⠸",
      "⠼",
      "⠴",
      "⠦",
      "⠧",
      "⠇",
      "⠏",
    },
    ---@type string
    filetype = "codecompanion",
  }

  function M:get_buf(filetype)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == filetype then
        return buf
      end
    end
    return nil
  end

  function M:update_spinner()
    if not self.processing then
      self:stop_spinner()
      return
    end

    self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1

    local buf = self:get_buf(self.filetype)
    if buf == nil then
      return
    end

    -- Clear previous virtual text
    vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)

    local last_line = vim.api.nvim_buf_line_count(buf) - 1
    vim.api.nvim_buf_set_extmark(buf, self.namespace_id, last_line, 0, {
      virt_lines = { { { self.spinner_symbols[self.spinner_index] .. " Processing...", "Comment" } } },
      virt_lines_above = false, -- false means below the line
    })
  end

  function M:start_spinner()
    self.processing = true
    self.spinner_index = 0

    if self.timer then
      self.timer:stop()
      self.timer:close()
      self.timer = nil
    end

    self.timer = vim.uv.new_timer()
    self.timer:start(
      0,
      100,
      vim.schedule_wrap(function()
        self:update_spinner()
      end)
    )
  end

  function M:stop_spinner()
    self.processing = false

    if self.timer then
      self.timer:stop()
      self.timer:close()
      self.timer = nil
    end

    local buf = self:get_buf(self.filetype)
    if buf == nil then
      return
    end

    vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
  end

  function M:init()
    -- Create namespace for virtual text
    self.namespace_id = vim.api.nvim_create_namespace("CodeCompanionSpinner")

    vim.api.nvim_create_augroup("CodeCompanionHooks", { clear = true })
    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionRequest*",
      group = group,
      callback = function(request)
        if request.match == "CodeCompanionRequestStarted" then
          self:start_spinner()
        elseif request.match == "CodeCompanionRequestFinished" then
          self:stop_spinner()
        end
      end,
    })
  end

  return M
end

---@type LazyPluginSpec
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
          clear = {
            modes = {},
          },
          send = {
            modes = { i = "<C-CR>" }
          },
        },
        role = {
          user = "Fred",
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
      ["Fix go linting errors"] = {
        strategy = "chat",
        description = "Fix go linting errors",
        opts = {
          is_slash_cmd = true,
          auto_submit = false,
          short_name = "golang_lint",
        },
        prompts = {
          {
            role = "user",
            content =
            [[I want you to fix the linting errors in this project. @full_stack_dev start by running `make lint` and based on the linting errors:

1. Fix the first error by modifying the file, to do so:
  1.1. Read the around the lines where the error is (+- 5 lines), to get the context of the code
  1.2. Fix the error
  1.3. When updating the file, make sure to only update the lines that you read, don't overwrite the file with only the changes.
2. Rerun `make lint` to make sure the error was fixed
3. Repeat until all linting errors are fixed.]]
          },

        },
      },
    },
  },
  config = function(_, opts)
    spinner():init()
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
  dependencies = {
    "folke/snacks.nvim",
    "j-hui/fidget.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
