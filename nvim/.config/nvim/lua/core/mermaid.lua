local parser = vim.treesitter.get_parser(12)
local tree = parser:parse()[1]

local query = vim.treesitter.query.parse('markdown', [[
(fenced_code_block
  ((info_string (language) @_lang (#eq? @_lang "mermaid")))
  (code_fence_content) @content)
]])

local mermaid_diagrams = {}

for capture_id, node, _ in query:iter_captures(tree:root(), 12, 0, -1) do
  if query.captures[capture_id] == 'content' then
    table.insert(mermaid_diagrams, vim.treesitter.get_node_text(node, 12))
  end
end

local lines = {
  '<!DOCTYPE html>',
  '<html>',
  '<head>',
  '<script type="module">',
  "import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';",
  'mermaid.initialize({ startOnLoad: true });',
  '</script>',
  '</head>',
  '<body>',
}

for _, diagram in ipairs(mermaid_diagrams) do
  table.insert(lines, '<div class="mermaid">')
  for _, s in ipairs(vim.split(diagram, "\n")) do
    table.insert(lines, s)
  end
  table.insert(lines, '</div>')
end

table.insert(lines, '</body>')
table.insert(lines, '</html>')

local html_bufid = vim.fn.bufadd('~/Downloads/mermaid.html')
vim.fn.bufload(html_bufid)

vim.api.nvim_buf_set_lines(html_bufid, 0, -1, false, lines)
