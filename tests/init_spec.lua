local t = require('tests.minitest')
local zapnote = require('zapnote')

t.test('current_buffer_anchor reads daily file stem', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/2025-04-24.md')

  t.eq(zapnote.current_buffer_anchor(), '2025-04-24')
end)

t.test('current_buffer_anchor ignores non journal files', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/notes.md')

  t.eq(zapnote.current_buffer_anchor(), nil)
end)

t.test('current_buffer_anchor reads weekly file stem', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/2026-W17.md')

  t.eq(zapnote.current_buffer_anchor(), '2026-W17')
end)

t.test('current_buffer_anchor reads quarterly file stem', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/2026-Q2.md')

  t.eq(zapnote.current_buffer_anchor(), '2026-Q2')
end)
