local function config()
  local ls = require 'luasnip'
  local select_choice = require('luasnip.extras.select_choice')
  local types = require 'luasnip.util.types'
  local utils = require 'core.utils'
  local head = utils.head
  local tail = utils.tail

  local higroup = vim.api.nvim_create_augroup('cfg#plugins#luasnip', { clear = true })

  local function setup_highlights()
    vim.cmd [[
        hi LuaSnipChoiceNode guifg=#d65d0e
        hi LuaSnipInsertNode guifg=#fabd2f
      ]]
  end

  vim.api.nvim_create_autocmd('ColorScheme', {
      group = higroup,
      pattern = "*",
      callback = setup_highlights,
  })

  setup_highlights()

  ls.config.setup({
      -- allow jumping back into a snippet if you moved outside of it
      history = true,
      -- since history is on, we need to sometimes remove snippets from the history
      -- that were expanded in the curent session but were subsequently deleted
      delete_check_events = 'TextChanged',
      store_selection_keys = '<TAB>',
      -- show updates to all types of dynamic nodes as you type
      update_events = { 'TextChanged', 'TextChangedI' },
      ext_opts = {
          [types.choiceNode] = {
              active = {
                  virt_text = { { '<- Choose', 'LuaSnipChoiceNode' } }
              },
          },
          [types.insertNode] = {
              active = {
                  virt_text = { { '<- Write', 'LuaSnipInsertNode' } }
              }
          }
      }
  })

  local s = ls.snippet
  local sn = ls.snippet_node
  local t = ls.text_node
  local i = ls.insert_node
  local f = ls.function_node
  local c = ls.choice_node
  local d = ls.dynamic_node
  local fmt = require("luasnip.extras.fmt").fmt
  local fmta = require("luasnip.extras.fmt").fmta


  local function reload_luasnip()
    ls.cleanup()
    require('core.utils').reload_module 'cfg.plugins.packer.luasnip'
  end

  local function setup_keymaps()
    -- set keybinds for both INSERT and VISUAL.
    vim.keymap.set('i', '<C-l>', function() ls.change_choice(1) end, {})
    vim.keymap.set('s', '<C-l>', function() ls.change_choice(1) end, {})
    vim.keymap.set('i', '<C-u>', select_choice, {})
  end

  vim.api.nvim_create_user_command('ReloadSnippets', reload_luasnip, {})

  setup_keymaps()

  -- Load vscode snipperts from other plugins
  -- require('luasnip.loaders.from_vscode').lazy_load()

  local function define_lua_snippets()
    ls.add_snippets('lua', {
        s(
            { trig = 'lv', name = 'Local variable', dscr = 'Defina a local variable' },
            fmt([[local {} = {}]], { i(1), i(2) })
        ),
        s(
            { trig = 'fl', name = 'Local function', dscr = 'Define a local function' },
            fmt([[
              local function {}({})
                {}
              end
            ]], { i(1), i(2), i(0) })),
        s(
            { trig = 'fi', name = 'Inline function' },
            fmt([[function() {} end]], { i(1) })),
        s(
            { trig = 'req', name = 'Require a module', dscr = 'Names the module variable with the name of the last dot-separated section of the module' },
            fmt([[local {} = require '{}']], {
                f(function(args)
                  if args then
                    local module = args[1][1]
                    if module == '' then
                      return ''
                    end
                    local parts = vim.split(module, '.', { plain = true })
                    return string.gsub(parts[#parts], '-', '_')
                  else
                    return ''
                  end
                end, { 1 }),
                i(1)
            })),
        s('aug', fmta([[local group = vim.api.nvim_create_augroup('<>', { clear = true })]], { i(1) })),
        s('au', fmt([[
            vim.api.nvim_create_autocmd({{ '{}' }}, {{
              group = group,
              pattern = '{}',
              {},
              desc = '{}',
            }})
          ]], {
            i(1),
            i(2),
            c(3, {
                sn(nil, fmt([[callback = {}]], { i(1, 'func') })),
                sn(nil, fmt([[command = '{}']], { i(1) })),
            }),
            i(4),
        }))
    })
  end

  define_lua_snippets()

  local function space_if_node_not_empty(node)
    return f(function(args) return args[1][1] == '' and '' or ' ' end, { node })
  end

  local function define_go_snippets()
    ls.add_snippets('go', {
        s("fe", fmt([[fmt.Errorf("{}: %w", {})]], { i(1, ""), i(2, "err") })),
        s("fun", fmta([[
            func <>(<>) <><>{
              <>
            }
          ]], {
            i(1),
            i(2),
            i(3),
            space_if_node_not_empty(3),
            i(0),
        })),
        s("meth", fmta([[
            func (<><>) <>(<>) <><>{
              <>
            }
          ]], {
            f(function(args)
              local struct_name = args[1][1]
              if struct_name == '' then
                return ''
              end
              local receiver_name = head(struct_name)
              if receiver_name == '*' then
                receiver_name = head(tail(struct_name))
                if receiver_name == '' then
                  return ''
                end
              end
              return string.lower(receiver_name) .. ' '
            end, { 1 }
            ),
            i(1),
            i(2),
            i(3),
            i(4),
            space_if_node_not_empty(4),
            i(0),
        })),
    })
  end

  define_go_snippets()

  local function asana_task()
    return s('at', {
            t("["),
            c(1, {
                t("Asana Task"),
                t("Change Management Task"),
                i(nil, ""),
            }),
            t("]("),
            f(function() return vim.fn.getreg('+') end, {}),
            t(")")
        })
  end

  local function markdown_link()
    return s('lk', fmt('[{}]({})', {
            d(1, function(_, parent)
              if parent.env and parent.env.SELECT_RAW then
                return sn(nil, { t(parent.env.SELECT_RAW) })
              end
              return sn(nil, { i(1) })
            end),
            d(2, function()
              return sn(nil, { i(1, vim.fn.getreg('+')) })
            end)
        }))
  end

  local markdown_snippets = {
      asana_task(),
      markdown_link(),
  }
  ls.add_snippets('markdown', markdown_snippets)
  ls.add_snippets('gitcommit', markdown_snippets)
end

return {
  'L3MON4D3/LuaSnip',
  config = config,
}
