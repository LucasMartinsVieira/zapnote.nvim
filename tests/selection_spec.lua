local t = require('tests.minitest')
local selection = require('zapnote.selection')

t.test('normalize_text trims edges and collapses newlines', function()
  t.eq(selection.normalize_text('  hello\nworld  '), 'hello world')
end)

t.test('get_last_visual_selection returns charwise text', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    'alpha beta',
    'gamma',
  })

  local got = selection.from_marks(bufnr, 'v', { 0, 1, 3, 0 }, { 0, 2, 3, 0 })
  t.eq(got.text, 'pha beta gam')
end)

t.test('get_last_visual_selection returns nil for empty text', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '   ' })

  local got, err = selection.from_marks(bufnr, 'v', { 0, 1, 1, 0 }, { 0, 1, 3, 0 })
  t.eq(got, nil)
  t.eq(err, 'empty visual selection')
end)
