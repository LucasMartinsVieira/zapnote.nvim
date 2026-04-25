local config = require('zapnote.config')

local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, {
    title = 'zapnote.nvim',
  })
end

local function system(args, on_done)
  if not vim.system then
    on_done({
      ok = false,
      error = 'vim.system unavailable; Neovim 0.10+ required',
    })
    return
  end

  vim.system(args, {
    text = true,
  }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      on_done({
        ok = false,
        code = result.code,
        stdout = result.stdout or '',
        stderr = vim.trim(result.stderr or ''),
        error = vim.trim(result.stderr or '') ~= '' and vim.trim(result.stderr or '')
          or string.format('%s exited with code %d', args[1], result.code),
      })
      return
    end

    on_done({
      ok = true,
      code = result.code,
      stdout = result.stdout or '',
      stderr = result.stderr or '',
    })
  end))
end

function M.extract_path(stdout)
  local path = vim.trim(stdout or '')
  if path == '' then
    return nil, 'missing file path from zn output'
  end

  return path
end

function M.list_templates(on_done)
  local cmd = config.get().zn_cmd or 'zn'
  system({ cmd, 'list', 'templates', '--json' }, function(result)
    if not result.ok then
      on_done(result.error, nil)
      return
    end

    local ok, decoded = pcall(vim.json.decode, result.stdout)
    if not ok then
      on_done('failed to decode template list from zn', nil)
      return
    end

    on_done(nil, decoded)
  end)
end

function M.list_journals(on_done)
  local cmd = config.get().zn_cmd or 'zn'
  system({ cmd, 'list', 'journals', '--json' }, function(result)
    if not result.ok then
      on_done(result.error, nil)
      return
    end

    local ok, decoded = pcall(vim.json.decode, result.stdout)
    if not ok then
      on_done('failed to decode journal list from zn', nil)
      return
    end

    on_done(nil, decoded)
  end)
end

function M.run_note(template, title, on_done)
  local cmd = config.get().zn_cmd or 'zn'
  system({ cmd, '--no-editor', 'note', template, title }, function(result)
    if not result.ok then
      notify(result.error, vim.log.levels.ERROR)
      on_done(result.error, nil)
      return
    end

    local path, err = M.extract_path(result.stdout)
    if not path then
      notify(err, vim.log.levels.ERROR)
      on_done(err, nil)
      return
    end

    on_done(nil, path)
  end)
end

function M.run_journal(name, opts, on_done)
  local cmd = config.get().zn_cmd or 'zn'
  local args = { cmd, '--no-editor', 'journal', name }

  if opts and opts.date then
    table.insert(args, '--date')
    table.insert(args, opts.date)
  end

  if opts and opts.offset then
    table.insert(args, '--offset')
    for _, part in ipairs(vim.split(opts.offset, ' ', {
      trimempty = true,
    })) do
      table.insert(args, part)
    end
  end

  system(args, function(result)
    if not result.ok then
      notify(result.error, vim.log.levels.ERROR)
      on_done(result.error, nil)
      return
    end

    local path, err = M.extract_path(result.stdout)
    if not path then
      notify(err, vim.log.levels.ERROR)
      on_done(err, nil)
      return
    end

    on_done(nil, path)
  end)
end

return M

