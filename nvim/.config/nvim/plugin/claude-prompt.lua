-- When Claude Code opens a prompt file in nvim via $EDITOR (Ctrl-G in the
-- Claude prompt), the last agent response above the reply marker is
-- commented out with `# ` prefixes. This strips those prefixes on BufRead
-- so the response is readable as markdown, then places the cursor at the
-- end of the buffer ready to continue typing.

local utils = require("core.utils")
local autocmd = utils.autogroup('duboisf.claude_prompt', true)

local marker_prefix = '# ─── Write your reply below this line'

autocmd(
  'BufRead',
  '/tmp/claude-prompt-*.md',
  function(args)
    local bufnr = args.buf
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local new_lines = {}
    local reached_marker = false
    for _, line in ipairs(lines) do
      if not reached_marker and vim.startswith(line, marker_prefix) then
        reached_marker = true
      end
      if reached_marker then
        table.insert(new_lines, line)
      else
        table.insert(new_lines, (line:gsub('^# ?', '')))
      end
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    vim.bo[bufnr].modified = false
    vim.b[bufnr].disable_jump_to_last_position = true
    vim.api.nvim_win_set_cursor(0, { #new_lines, #(new_lines[#new_lines] or '') })
  end,
  'Uncomment Claude prompt reference section for readability'
)
