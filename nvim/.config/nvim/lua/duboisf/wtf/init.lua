local api = vim.api
local co = coroutine
local uv = vim.uv
local Spinner = require("duboisf.wtf.spinner")

local function set_options()
  vim.bo.bufhidden = 'wipe'
  vim.bo.buftype = 'nofile'
  vim.bo.filetype = 'markdown'
  vim.bo.modified = false
  vim.bo.swapfile = false

  vim.b.disable_jump_to_last_position = true

  vim.o.cmdheight = 0
  vim.o.concealcursor = 'n'
  vim.o.number = false
  vim.o.relativenumber = false
  vim.o.showtabline = 0
  vim.o.signcolumn = 'yes:1'
  vim.o.wrap = true
  vim.o.fillchars = 'eob: '
end

---@class Buffer
---@field private get_buf fun(): number
---@field private lines string[]
---@field private spinner Spinner?
local Buffer = {
  lines = {},
  spinner = nil,
}

function Buffer.new()
  local self = setmetatable({}, { __index = Buffer })

  local buf = api.nvim_get_current_buf()

  self.get_buf = function()
    return buf
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, {})
  api.nvim_win_set_cursor(0, { 1, 0 })

  self.spinner = Spinner.new(buf)

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
  vim.bo.modifiable = b
  vim.bo.readonly = not b
end

--- Append lines at the end of the buffer
---@param lines string[]
function Buffer:write(lines)
  -- if this is the first write, we need to insert instead of append
  local append = #self.lines > 0

  vim.list_extend(self.lines, lines)
  self:modifiable(true)
  api.nvim_buf_set_lines(self.get_buf(), append and -1 or 0, -1, false, lines)
  self:modifiable(false)
end

function Buffer:append(text)
  self:modifiable(true)

  if self.spinner then
    self.spinner:stop()
  end

  local buf = self.get_buf()

  local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1]
  local row = vim.api.nvim_buf_line_count(buf) - 1 -- 0-based index for row
  local col = #last_line                           -- Length of the last line for column

  local ok, err = pcall(vim.api.nvim_buf_set_text, buf, row, col, row, col, vim.split(text, "\n"))
  if not ok then
    error("Error appending text to buffer " .. buf .. ": " .. err)
  end
  self:modifiable(false)
end

return function(wft_file)
  local thread

  thread = coroutine.create(function()
    set_options()

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
