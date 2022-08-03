local getftime = vim.fn.getftime
local glob = vim.fn.glob
local filereadable = vim.fn.filereadable

-- Regenerate the *.add.spl file if it's outdated because we pulled changes to
-- one of the *.add files
for _, file in ipairs(glob(vim.fn.stdpath('config') .. '/spell/*.add', 1, 1)) do
  local spell_file = file .. '.spl'
  if filereadable(file) and (not filereadable(spell_file) or getftime(file) > getftime(spell_file)) then
    local ok, output = pcall(vim.cmd, 'silent mkspell! ' .. vim.fn.fnameescape(file), false)
    if ok then
      vim.notify(' ' .. file, vim.log.levels.INFO, { title = 'Regenerated .spl file' })
    else
      vim.notify(' ' .. output, vim.log.levels.ERROR, { title = 'Could not regenerate .spl file' })
    end
  end
end
