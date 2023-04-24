local M = {}

-- Get the treesitter tree for the buffer bufnr.
--- @param bufnr number: Buffer handle, defaults to current
--- @return TSTree
local function get_tree(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, 'markdown')
  return parser:parse()[1]
end

-- Get a treesitter query to find mermaid diagrams in markdown.
--- @return Query
local function get_query()
  return vim.treesitter.query.parse('markdown', [[
    (fenced_code_block
      ((info_string (language) @lang (#eq? @lang "mermaid")))
      (code_fence_content) @content)
  ]])
end

-- Get the mermaid diagrams in the buffer bufnr.
--- @param bufnr number: Buffer handle, defaults to current
--- @return table<string>: List of mermaid diagrams
local function find_mermaid_diagrams(bufnr)
  local tree = get_tree(bufnr)
  local query = get_query()
  local mermaid_diagrams = {}
  for capture_id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[capture_id] == 'content' then
      table.insert(mermaid_diagrams, vim.treesitter.get_node_text(node, bufnr))
    end
  end
  return mermaid_diagrams
end

-- Create an html file with the mermaid diagrams.
--- @param divs table<string>: List of mermaid diagram divs
--- @return string: Html file
local function create_html(divs)
  local html_template = [[
<!DOCTYPE html>
<html>
<style>
div.mermaid {
  visibility: hidden;
}
div.mermaid[data-processed="true"] {
  visibility: visible;
}
</style>
<body>
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
    mermaid.initialize({ startOnLoad: true });
  </script>
%s
</body>
</html>
]]
  return string.format(html_template, table.concat(divs, '\n'))
end

-- Create an html div for each mermaid diagram.
--- @param mermaid_diagrams table<string>: List of mermaid diagram divs
local function create_divs(mermaid_diagrams)
  local divs = {}
  for _, diagram in ipairs(mermaid_diagrams) do
    local div = string.format([[
    <div class="mermaid">
    %s
    </div>
    ]], diagram)
    table.insert(divs, div)
  end
  return divs
end

-- Preview the mermaid diagrams in the current buffer. Creates a new html file.
--- @param bufnr number: Buffer handle, defaults to current
--- @return nil
function M.preview(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local mermaid_diagrams = find_mermaid_diagrams(bufnr)
  local divs = create_divs(mermaid_diagrams)
  local html = create_html(divs)
  local lines = vim.split(html, '\n')
  local html_filename = vim.fn.expand('~/Downloads/mermaid.html')
  local html_bufid = vim.fn.bufadd(html_filename)
  vim.fn.bufload(html_bufid)
  vim.api.nvim_buf_set_lines(html_bufid, 0, -1, false, lines)
  print('Mermaid preview: ' .. html_filename)
  -- save the html file
  local cur_bufnr = vim.fn.bufnr()
  vim.cmd(html_bufid .. 'buffer')
  vim.cmd('silent write')
  vim.cmd(cur_bufnr .. 'buffer')
end

return M
