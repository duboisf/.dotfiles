vim.opt.hidden = true
vim.opt.updatetime = 50
vim.opt.clipboard = 'unnamed'
-- Enable 24-bit RGB color in the Terminal UI
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.textwidth = 0
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.encoding = 'utf-8'
vim.opt.list = false
-- Open vsplit to the right
vim.opt.splitright = true
vim.opt.splitbelow = true
-- specify the characters to use for tabs and trailing spaces
vim.opt.listchars = [[tab:→\ ,trail:·]]
vim.opt.wildignore:append { '*/.git/*', '*/.hg/*', '*/.svn/*' }
vim.opt.dictionary:append('/usr/share/dict/american-english')
-- Remove = from isfname so that completing a filename with <C-x><C-f>
-- works even in an assignment like SOME_VAR=/foo/bar. The side effect of this
-- will be that gf won't work with filenames with = in them... I don't think
-- this will cause a lot of problems...
vim.opt.isfname:remove('=')
-- Don't show the current mode (insert, visual, etc.)
vim.opt.showmode = false
-- Do not use swapfiles
vim.opt.swapfile = false
-- Better display for messages
vim.opt.cmdheight = 1
-- Smaller updatetime for CursorHold & CursorHoldI
vim.opt.updatetime = 100
-- Set _almost_ all shortmess goions
vim.opt.shortmess = 'filnxtoOsTWAIcCF'
-- always show signcolumns
vim.opt.signcolumn = 'yes:2'
-- show interactive substitute
vim.opt.inccommand = 'nosplit'
-- Prevent long, single lines from slowing down the redraw speed. In my case
-- this often happens when viewing kubernetes resources as the
-- kubectl.kubernetes.io/last-applied-configuration is a single line that
-- contains the whole previous version of the resource.
vim.opt.synmaxcol = 300
-- highlight lua code in .vim files
-- let g:vimsyn_embed = 'l'
-- Don't show the last command in the last line
vim.opt.showcmd = false
-- use only 1 status line for all open windows
vim.opt.laststatus = 3
-- Set the title of the terminal window
vim.opt.title = true
vim.opt.titlelen = 30
vim.opt.scrolloff = 3
