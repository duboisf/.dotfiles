-- Copied from CopilotChat.nvim

local spinner_frames = {
  '⠋',
  '⠙',
  '⠹',
  '⠸',
  '⠼',
  '⠴',
  '⠦',
  '⠧',
  '⠇',
  '⠏',
}

---Create a new spinner
---@param bufnr number
---@return Spinner
local function new(bufnr)
  local ns = vim.api.nvim_create_namespace('duboisf.wtf')

  ---@type uv.uv_timer_t?
  local timer = nil

  local index = 1

  ---@class (exact) Spinner
  ---@field start fun(self: Spinner, status: string?): nil
  ---@field stop fun(self: Spinner): nil
  return {

    --- Start the spinner
    --- @param self Spinner
    --- @param status string? Optional status to display
    start = function(self, status)
      if timer then
        return
      end

      timer = assert(vim.uv.new_timer())

      timer:start(
        0,
        100,
        vim.schedule_wrap(function()
          if not timer then
            self:stop()
            return
          end

          local frame = spinner_frames[index]

          if status then
            frame = status .. ' ' .. frame
          end

          vim.api.nvim_buf_set_extmark(bufnr, ns, math.max(0, vim.api.nvim_buf_line_count(bufnr) - 1), 0,
            {
              id = 1,
              hl_mode = 'combine',
              priority = 100,
              virt_text = {
                { frame, 'Comment' },
              },
            })

          index = index % #spinner_frames + 1
        end)
      )
    end,

    --- Stop the spinner
    --- @param _ Spinner
    stop = function(_)
      if not timer then
        return
      end

      timer:stop()
      timer:close()

      timer = nil

      vim.api.nvim_buf_del_extmark(bufnr, ns, 1)
    end,
  }
end

return {
  new = new,
}
