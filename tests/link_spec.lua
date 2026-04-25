local t = require('tests.minitest')
local link = require('zapnote.link')

t.test('replace_selection swaps charwise range', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'hello world' })

  local ok = link.replace_selection({
    bufnr = bufnr,
    mode = 'v',
    start_row = 0,
    start_col = 0,
    end_row = 0,
    end_col = 5,
  }, '[[hello]]')

  t.ok(ok)
  t.eq(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), { '[[hello]] world' })
end)

t.test('render_link uses configured format', function()
  t.eq(link.render_link('daily', '[[%s]]'), '[[daily]]')
end)

