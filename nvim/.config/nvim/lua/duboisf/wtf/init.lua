local api = vim.api
local co = coroutine
local uv = vim.uv
local Spinner = require("duboisf.wtf.spinner")

local function set_buf_opt(buf, name, value)
  local opts = { buf = buf }
  api.nvim_set_option_value(name, value, opts)
end

local function set_local_opt(name, value)
  local opts = { scope = 'local' }
  api.nvim_set_option_value(name, value, opts)
end

local function set_options(buf)
  set_buf_opt(buf, 'bufhidden', 'wipe')
  set_buf_opt(buf, 'buftype', 'nofile')
  set_buf_opt(buf, 'filetype', 'markdown')
  set_buf_opt(buf, 'modified', false)
  set_buf_opt(buf, 'swapfile', false)

  api.nvim_buf_set_var(buf, 'disable_jump_to_last_position', true)

  set_local_opt('cmdheight', 0)
  set_local_opt('concealcursor', 'n')
  set_local_opt('fillchars', 'eob: ')
  set_local_opt('hidden', true)
  set_local_opt('number', false)
  set_local_opt('relativenumber', false)
  set_local_opt('showtabline', 0)
  set_local_opt('signcolumn', 'yes:1')
  set_local_opt('wrap', true)
  set_local_opt('laststatus', 0)
end

---@class Buffer
---@field private get_buf fun(): number
---@field private get_win fun(): number
---@field private lines string[]
---@field private spinner Spinner?
local Buffer = {
  lines = {},
  spinner = nil,
}

function Buffer.new()
  local self = setmetatable({}, { __index = Buffer })

  local buf = api.nvim_get_current_buf()
  local win = api.nvim_get_current_win()

  self.get_buf = function()
    return buf
  end

  self.get_win = function()
    return win
  end

  set_options(buf)

  api.nvim_buf_set_lines(buf, 0, -1, false, {})
  api.nvim_win_set_cursor(win, { 1, 0 })

  self.spinner = Spinner.new(buf)

  self:append("\n")

  self.spinner:start("Thinking")

  self:modifiable(false)

  api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>qa!<CR>", { nowait = true, noremap = true, silent = true })

  -- Exit nvim when this buffer is gone
  api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeout" }, {
    buffer = buf,
    callback = function()
      vim.cmd("qa!")
    end,
  })

  return self
end

function Buffer:modifiable(b)
  ---@type vim.api.keyset.option
  local opts = { buf = self.get_buf() }
  api.nvim_set_option_value('modifiable', b, opts)
  api.nvim_set_option_value('readonly', not b, opts)
end

--- Get the end position of the buffer
--- @return number row
--- @return number col
function Buffer:get_end_pos()
  local buf = self.get_buf()
  local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1]
  local row = vim.api.nvim_buf_line_count(buf) - 1 -- 0-based index for row
  local col = #last_line                           -- Length of the last line for column
  return row, col
end

function Buffer:append(text)
  self:modifiable(true)

  if self.spinner then
    self.spinner:stop()
  end

  local buf = self.get_buf()

  local row, col = self:get_end_pos()

  local ok, err = pcall(vim.api.nvim_buf_set_text, buf, row, col, row, col, vim.split(text, "\n"))
  if not ok then
    error("Error appending text to buffer " .. buf .. ": " .. err)
  end

  -- Make the cursor follow the text
  local current_win = api.nvim_get_current_win()
  if current_win == self.get_win() then
    api.nvim_win_set_cursor(current_win, { row + 1, col + 1 })
  end

  self:modifiable(false)
end

return function(wft_file)
  local thread

  thread = coroutine.create(function()
    vim.cmd.file({ "wtf://" .. vim.fn.getcwd(), mods = { silent = true } })

    local buffer = Buffer.new()

    local wtf_fd = assert(uv.fs_open(wft_file, 'r', 438))
    local stat = assert(uv.fs_fstat(wtf_fd))

    uv.fs_read(wtf_fd, stat.size, 0, function(err, data)
      if err then
        error("fs_read error: " .. err)
      end
      if data then
        co.resume(thread, data)
      end
    end)

    ---@type string
    local wtf_data = co.yield()

    assert(uv.fs_close(wtf_fd))

    vim.system(
      { "sonder", "chat", "--system", "You are a command line expert, explain the problem with this command" },
      {
        text = true,
        clear_env = false,
        stdin = wtf_data,
        stdout = function(err, data)
          if err then
            error("Error: " .. err)
          end
          if data then
            vim.schedule(function() buffer:append(data) end)
          end
        end
      }, vim.schedule_wrap(function(out)
        if out.code ~= 0 then
          error("Error: " .. out.stderr)
        end
        co.resume(thread)
      end))

    co.yield()

    buffer:append("*(Done, press q to quit)*")
  end)

  local ok, err = co.resume(thread)
  if not ok then
    error(err)
  end
end
