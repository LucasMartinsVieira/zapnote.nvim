local config = require('zapnote.config')

local M = {}

---@param default_fn function
---@param configured function|nil
---@return function
local function adapter_or(default_fn, configured)
  if type(configured) == 'function' then
    return configured
  end

  return default_fn
end

---@param opts table
---@param on_done fun(value: string|nil)
function M.input(opts, on_done)
  local input = adapter_or(function(input_opts, callback)
    vim.ui.input(input_opts, callback)
  end, config.get().ui.input)

  input(opts, function(value)
    on_done(value)
  end)
end

---@param items any[]
---@param opts table
---@param on_done fun(choice: any|nil)
function M.select(items, opts, on_done)
  local select = adapter_or(function(select_items, select_opts, callback)
    vim.ui.select(select_items, select_opts, callback)
  end, config.get().ui.select)

  local ok, err = pcall(select, items, opts, function(choice)
    on_done(choice)
  end)

  if not ok then
    return nil, err
  end

  return true
end

---@param kind string
---@param items {name:string}[]
---@param on_done fun(choice: {name:string}|nil)
function M.select_name(kind, items, on_done)
  local ok, err = M.select(items, {
    prompt = string.format('Select %s', kind),
    format_item = function(item)
      return item.name
    end,
  }, on_done)

  if ok then
    return
  end

  M.input({
    prompt = string.format('%s: ', kind),
  }, function(value)
    if not value or value == '' then
      on_done(nil)
      return
    end

    on_done({
      name = value,
    })
  end)

  return err
end

return M
