M = {}

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

M.set_alternate_file = function()
   local rel_file_no_ext = vim.fn.expand('%:r')
   if ends_with(rel_file_no_ext, '_test') then
     vim.nvim_command('let @# = "' .. rel_file_no_ext:sub(1, rel_file_no_ext:len() - '_test':len()) .. '.go"')
   else
     vim.nvim_command('let @# = "' .. rel_file_no_ext .. '_test.go"')
   end
end

return M
