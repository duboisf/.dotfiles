local o = vim.o
-- vim.opt is different than vim.o, it allows access options as tables and adds extra methods
local opt = vim.opt

-- Better display for messages
o.cmdheight = 1
o.concealcursor = 'nc'
o.conceallevel = 2
opt.dictionary:append('/usr/share/dict/american-english')
o.encoding = 'utf-8'
o.expandtab = true
o.hidden = true
o.inccommand = 'nosplit'
-- Remove = from isfname so that completing a filename with <C-x><C-f>
-- works even in an assignment like SOME_VAR=/foo/bar. The side effect of this
-- will be that gf won't work with filenames with = in them... I don't think
-- this will cause a lot of problems...
opt.isfname:remove('=')
-- use only 1 status line for all open windows
o.laststatus = 3
o.list = false
-- Specify the characters to use for tabs and trailing spaces
-- Depends on the list option being true
o.listchars = [[tab:→\ ,trail:·]]
o.mouse = 'a'
o.number = true
o.relativenumber = true
o.scrolloff = 3
o.shiftwidth = 4
-- Set _almost_ all shortmess goions
o.shortmess = 'filnxtoOsTWAIcCF'
-- highlight lua code in .vim files
-- let g:vimsyn_embed = 'l'
-- Don't show the last command in the last line
o.showcmd = false
-- Don't show the current mode (insert, visual, etc.)
o.showmode = false
-- always show signcolumns
o.signcolumn = 'yes:2'
o.splitbelow = true
-- Open vsplit to the right
o.splitright = true
o.softtabstop = 4
-- Do not use swapfiles
o.swapfile = false
-- Prevent long, single lines from slowing down the redraw speed. In my case
-- this often happens when viewing kubernetes resources as the
-- kubectl.kubernetes.io/last-applied-configuration is a single line that
-- contains the whole previous version of the resource.
o.synmaxcol = 300
o.tabstop = 4
-- Enable 24-bit RGB color in the Terminal UI
o.termguicolors = true
o.textwidth = 0
-- Set the title of the terminal window
o.title = true
o.titlelen = 30
-- Smaller updatetime for CursorHold & CursorHoldI
o.updatetime = 500
opt.wildignore:append { '*/.git/*', '*/.hg/*', '*/.svn/*' }
o.wrap = false
