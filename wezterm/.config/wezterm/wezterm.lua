local wezterm = require 'wezterm'
local colors = require 'colors'

return {
  colors = colors,
  -- use font to render block fonts, otherwise powerline symbols look different
  custom_block_glyphs = false,
  enable_wayland = false,
  font_size = 16.0,
  font = wezterm.font_with_fallback({
    {
      family = 'Cascadia Code PL',
      harfbuzz_features = { 'calt', 'ss01', 'ss02', 'ss19', 'zero', 'onum' },
    },
    'Symbols Nerd Font',
  }),
  hide_tab_bar_if_only_one_tab = true,
  -- keys = {
  --   { key = 'a', 'CTRL', action = wezterm.action.ActivateCommandPalette }
  -- },
  keys = {
    {
      key = 'e',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.QuickSelectArgs {
        alphabet = '1234567890',
        label = 'open url',
        patterns = {
          'https?://\\S+',
        },
        action = wezterm.action_callback(function(window, pane)
          local url = window:get_selection_text_for_pane(pane)
          wezterm.log_info('opening: ' .. url)
          wezterm.open_with(url)
        end),
      },
    },
    {
      key = 'Enter',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    }
  },

  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  window_padding = {
    left = '0',
    right = '0',
    top = '0',
    bottom = '0',
  },
}
