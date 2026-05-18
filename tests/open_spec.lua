local t = require('tests.minitest')
local open = require('zapnote.open')

t.test('edit skips reopening current buffer path', function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, '/tmp/zapnote-open-current.md')

  local calls = {}
  local original_cmd = vim.cmd
  vim.cmd = function(cmd)
    table.insert(calls, cmd)
  end

  local ok, err = pcall(function()
    local path = open.edit('/tmp/zapnote-open-current.md')
    t.eq(path, '/tmp/zapnote-open-current.md')
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
  vim.api.nvim_buf_set_name(bufnr, '/tmp/zapnote-open-source.md')

  local calls = {}
  local original_cmd = vim.cmd
  vim.cmd = function(cmd)
    table.insert(calls, cmd)
  end

  local ok, err = pcall(function()
    local path = open.edit('/tmp/zapnote-open-target.md')
    t.eq(path, '/tmp/zapnote-open-target.md')
  end)

  vim.cmd = original_cmd

  if not ok then
    error(err)
  end

  t.eq(calls, { 'edit /tmp/zapnote-open-target.md' })
end)
