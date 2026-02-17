--- Custom blink.cmp source for fuzzy path completion across segments.
--- Typing ~/.dot/n/n completes to ~/.dotfiles/nvim/.config/nvim
--- Each segment is resolved iteratively: direct children first, then
--- fd --hidden for recursive search (traverses hidden dirs like .config/).

local source = {}

local fd_path = vim.fn.exepath('fd')

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_trigger_characters()
  return { '/' }
end

--- Find entries matching a segment prefix within base_dirs.
--- For each dir individually: tries direct glob first (fast, no subprocess),
--- falls back to fd for that specific dir. Per-dir fallback ensures we don't
--- miss recursive matches in one dir just because another had direct matches.
--- @param base_dirs string[]
--- @param seg string  typed segment prefix, e.g. "n" or ".con"
--- @param dirs_only boolean
--- @return string[]
local function find_segment_matches(base_dirs, seg, dirs_only)
  local results = {}
  local need_deep = {}

  for _, dir in ipairs(base_dirs) do
    local entries = vim.fn.glob(dir .. '/' .. seg .. '*', false, true)
    local found_any = false
    for _, entry in ipairs(entries) do
      if not dirs_only or vim.fn.isdirectory(entry) == 1 then
        results[#results + 1] = entry
        found_any = true
      end
    end
    if not found_any then
      need_deep[#need_deep + 1] = dir
    end
  end

  -- For dirs without direct matches, use fd (handles hidden dirs unlike glob **)
  if #need_deep > 0 and fd_path ~= '' then
    local cmd = { fd_path, '--hidden', '--no-ignore', '--max-depth', '4', '--glob', seg .. '*' }
    if dirs_only then
      vim.list_extend(cmd, { '--type', 'd' })
    end
    vim.list_extend(cmd, need_deep)
    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
      for _, line in ipairs(output) do
        if line ~= '' then
          -- fd outputs trailing / for dirs — strip it (we add our own later)
          results[#results + 1] = line:gsub('/$', '')
        end
      end
    end
  end

  return results
end

function source:get_completions(ctx, callback)
  local cursor_col = ctx.cursor[2]
  local before_cursor = ctx.line:sub(1, cursor_col)

  -- Scan backwards to find the start of the path text
  local path_start = nil
  for i = #before_cursor, 1, -1 do
    local char = before_cursor:sub(i, i)
    if char:match('[%s,;:=<>|&{}%[%]%(%)\'"`]') then
      break
    end
    path_start = i
  end

  if not path_start then
    return callback({ items = {} })
  end

  local path_text = before_cursor:sub(path_start)

  -- Must start with a path anchor: ~/ ./ ../ or /
  if not (path_text:match('^~/') or path_text:match('^%./') or path_text:match('^%.%./') or path_text:match('^/')) then
    return callback({ items = {} })
  end

  local trailing_slash = path_text:sub(-1) == '/'
  local segments = vim.split(path_text, '/')

  if trailing_slash and segments[#segments] == '' then
    table.remove(segments)
  end

  -- Resolve the anchor to concrete base directories
  local anchor = table.remove(segments, 1)
  local base_dirs
  if anchor == '~' then
    base_dirs = { vim.fn.expand('~') }
  elseif anchor == '.' then
    base_dirs = { '.' }
  elseif anchor == '..' then
    base_dirs = { '..' }
  elseif anchor == '' then
    base_dirs = { '' }
  else
    return callback({ items = {} })
  end

  segments = vim.tbl_filter(function(s) return s ~= '' end, segments)
  if #segments == 0 then
    return callback({ items = {} })
  end

  -- Resolve each typed segment iteratively
  for i, seg in ipairs(segments) do
    local is_last = i == #segments
    local dirs_only = not is_last or trailing_slash
    base_dirs = find_segment_matches(base_dirs, seg, dirs_only)

    if #base_dirs == 0 then
      return callback({ items = {} })
    end
  end

  -- Trailing slash: list contents of matched directories
  if trailing_slash then
    local contents = {}
    for _, dir in ipairs(base_dirs) do
      vim.list_extend(contents, vim.fn.glob(dir .. '/*', false, true))
      for _, entry in ipairs(vim.fn.glob(dir .. '/.*', false, true)) do
        local name = entry:match('[^/]+$')
        if name ~= '.' and name ~= '..' then
          contents[#contents + 1] = entry
        end
      end
    end
    base_dirs = contents
  end

  if #base_dirs > 100 then
    base_dirs = vim.list_slice(base_dirs, 1, 100)
  end

  local items = {}
  local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
  local use_tilde = path_text:match('^~/')
  local home = vim.fn.expand('~')

  for _, match in ipairs(base_dirs) do
    local is_dir = vim.fn.isdirectory(match) == 1
    local display = match

    if use_tilde and match:sub(1, #home) == home then
      display = '~' .. match:sub(#home + 1)
    end

    if is_dir then
      display = display .. '/'
    end

    local last_seg = match:match('[^/]+$') or match

    items[#items + 1] = {
      label = display,
      kind = is_dir and CompletionItemKind.Folder or CompletionItemKind.File,
      filterText = last_seg,
      -- Shorter paths first (better match), dirs before files, then alphabetical
      sortText = string.format('%s%04d_%s', is_dir and '0' or '1', #display, display:lower()),
      textEdit = {
        newText = display,
        range = {
          start = { line = ctx.cursor[1] - 1, character = path_start - 1 },
          ['end'] = { line = ctx.cursor[1] - 1, character = cursor_col },
        },
      },
    }
  end

  callback({
    items = items,
    is_incomplete_forward = true,
    is_incomplete_backward = true,
  })
end

return source
