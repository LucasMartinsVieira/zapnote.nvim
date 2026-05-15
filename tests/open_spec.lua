local t = require('tests.minitest')
local open = require('zapnote.open')

t.test('edit skips reopening current buffer path', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/2026-05-15.md')

  local calls = {}
  local original_cmd = vim.cmd
  vim.cmd = function(cmd)
    table.insert(calls, cmd)
  end

  local ok, err = pcall(function()
    local path = open.edit('/tmp/2026-05-15.md')
    t.eq(path, '/tmp/2026-05-15.md')
  end)

  vim.cmd = original_cmd

  if not ok then
    error(err)
  end

  t.eq(calls, {})
end)

t.test('edit opens a different path', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/2026-05-15.md')

  local calls = {}
  local original_cmd = vim.cmd
  vim.cmd = function(cmd)
    table.insert(calls, cmd)
  end

  local ok, err = pcall(function()
    local path = open.edit('/tmp/2026-05-16.md')
    t.eq(path, '/tmp/2026-05-16.md')
  end)

  vim.cmd = original_cmd

  if not ok then
    error(err)
  end

  t.eq(calls, { 'edit /tmp/2026-05-16.md' })
end)
