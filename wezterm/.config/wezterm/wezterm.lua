local wezterm = require 'wezterm'
local colors = require 'colors'
local act = wezterm.action

--local selected_theme = 'Solarized Dark (base16)'
local selected_theme = 'Solar Flare (base16)'
print(wezterm.color.get_builtin_schemes()[selected_theme])

wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    { Attribute = { Italic = true } },
    { Text = date },
  })
end)

return {
  -- colors = colors,
  --color_scheme = "Solarized Dark Higher Contrast",
  color_scheme = selected_theme,
  --color_scheme = "OceanicMaterial",
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
  inactive_pane_hsb = {
    saturation = 0.2,
    brightness = 0.5,
  },
  keys = {
    {
      key = 'e',
      mods = 'CTRL|SHIFT',
      action = act.QuickSelectArgs {
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
    { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Down', size = { Percent = 50 } } },
    { key = '|', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Right', size = { Percent = 50 } } },
    { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Next' },
    { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Prev' },
    { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
    { key = '}', mods = 'CTRL|SHIFT', action = act.RotatePanes 'Clockwise' },
    { key = '{', mods = 'CTRL|SHIFT', action = act.RotatePanes 'CounterClockwise' },
    -- the 2 following bindings need semantic prompt escapes
    { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
    { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
  },
  mouse_bindings = {
    {
      event = { Down = { streak = 3, button = 'Left' } },
      action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
      mods = 'NONE',
    },
  },
  scrollback_lines = 10000,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = false,
  window_decorations = 'NONE',
  window_padding = {
    left = '0',
    right = '0',
    top = '0',
    bottom = '0',
  },
}
