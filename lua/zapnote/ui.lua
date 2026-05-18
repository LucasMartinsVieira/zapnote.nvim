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

---@param items any[]
---@param opts table
---@param on_done fun(choice: any|nil)
local function native_select(items, opts, on_done)
  vim.ui.select(items, opts, on_done)
end

---@param items any[]
---@param opts table
---@param on_done fun(choice: any|nil)
local function telescope_select(items, opts, on_done)
  local ok_pickers, pickers = pcall(require, 'telescope.pickers')
  local ok_finders, finders = pcall(require, 'telescope.finders')
  local ok_config, telescope_config = pcall(require, 'telescope.config')
  local ok_actions, actions = pcall(require, 'telescope.actions')
  local ok_state, action_state = pcall(require, 'telescope.actions.state')

  if not (ok_pickers and ok_finders and ok_config and ok_actions and ok_state) then
    return native_select(items, opts, on_done)
  end

  local values = telescope_config.values
  local picker_opts = {
    prompt_title = opts.prompt or 'Select',
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        local label = opts.format_item and opts.format_item(item) or tostring(item)
        return {
          value = item,
          display = label,
          ordinal = label,
        }
      end,
    }),
    sorter = values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        on_done(selection and selection.value or nil)
      end)

      return true
    end,
  }

  pickers.new({}, picker_opts):find()
end

---@param items any[]
---@param opts table
---@param on_done fun(choice: any|nil)
local function snacks_select(items, opts, on_done)
  local ok, snacks = pcall(require, 'snacks')
  local picker = ok and snacks and snacks.picker

  if not (picker and picker.select) then
    return native_select(items, opts, on_done)
  end

  return picker.select(items, opts, on_done)
end

---@return ZapnoteSelectFn
local function configured_select()
  local ui_config = config.get().ui or {}
  if type(ui_config.select) == 'function' then
    return ui_config.select
  end

  if ui_config.picker == 'telescope' then
    return telescope_select
  end

  if ui_config.picker == 'snacks' then
    return snacks_select
  end

  return native_select
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
  local select = configured_select()

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
