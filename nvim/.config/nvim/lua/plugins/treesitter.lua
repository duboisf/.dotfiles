local function setup_incremental_selection()
  local nodes = {}
  local function select_node(node)
    local sr, sc, er, ec = node:range()
    if vim.fn.mode():match('[vV]') then
      vim.cmd('normal! \27')
    end
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd('normal! v')
    if ec == 0 then
      vim.api.nvim_win_set_cursor(0, { er, vim.v.maxcol })
    else
      vim.api.nvim_win_set_cursor(0, { er + 1, ec - 1 })
    end
  end
  vim.keymap.set('n', 'gs', function()
    local node = vim.treesitter.get_node()
    if not node then return end
    nodes = { node }
    select_node(node)
  end)
  local function same_range(a, b)
    local a1, a2, a3, a4 = a:range()
    local b1, b2, b3, b4 = b:range()
    return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
  end
  vim.keymap.set('x', '<C-Down>', function()
    local cur = nodes[#nodes]
    if not cur then return end
    local parent = cur:parent()
    while parent and same_range(parent, cur) do
      parent = parent:parent()
    end
    if not parent then return end
    table.insert(nodes, parent)
    select_node(parent)
  end)
  vim.keymap.set('x', '<C-Up>', function()
    if #nodes <= 1 then return end
    table.remove(nodes)
    select_node(nodes[#nodes])
  end)
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'bash',
        'comment',
        'diff',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'mermaid',
        'query',
        'regex',
        'ruby',
        'terraform',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      }
      require('nvim-treesitter').install(parsers)
      setup_incremental_selection()

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if not pcall(vim.treesitter.start) then return end
          if vim.bo[args.buf].filetype ~= 'yaml' then
            vim.bo[args.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')

      local select_keymaps = {
        -- custom captures
        al = '@list.outer',
        il = '@list.inner',
        ak = '@key.outer',
        ik = '@key.inner',

        -- the queries are in textobjects.scm
        aa = '@assignment.outer',
        ia = '@assignment.inner',
        af = '@function.outer',
        ['if'] = '@function.inner',
        ap = '@parameter.outer',
        ip = '@parameter.inner',
        aC = '@class.outer',
        iC = '@class.inner',
        ac = '@conditional.outer',
        ic = '@conditional.inner',
        ab = '@block.outer',
        ib = '@block.inner',
        aL = '@loop.outer',
        iL = '@loop.inner',
        ['is'] = '@statement.inner',
        as = '@statement.outer',
        ad = '@comment.outer',
        am = '@call.outer',
        im = '@call.inner',
      }
      for lhs, capture in pairs(select_keymaps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(capture, 'textobjects')
        end)
      end

      local move_keymaps = {
        goto_next_start = {
          [']F'] = '@function.outer',
          ['<C-j>'] = '@parameter.inner',
        },
        goto_previous_start = {
          ['[F'] = '@function.outer',
          ['<C-k>'] = '@parameter.inner',
        },
      }
      for fn, maps in pairs(move_keymaps) do
        for lhs, capture in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            move[fn](capture, 'textobjects')
          end)
        end
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,
      separator = '─',
    },
  }
}
