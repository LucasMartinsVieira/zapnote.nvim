local t = require('tests.minitest')
local config = require('zapnote.config')
local ui = require('zapnote.ui')

t.test('select uses native picker by default', function()
  config.setup()

  local calls = {}
  local original = vim.ui.select
  vim.ui.select = function(items, opts, on_done)
    table.insert(calls, {
      items = items,
      prompt = opts.prompt,
    })
    on_done(items[2])
  end

  local choice
  local ok, err = pcall(function()
    ui.select({ 'day', 'week' }, { prompt = 'Select journal' }, function(item)
      choice = item
    end)
  end)

  vim.ui.select = original

  if not ok then
    error(err)
  end

  t.eq(choice, 'week')
  t.eq(#calls, 1)
  t.eq(calls[1].prompt, 'Select journal')
end)

t.test('select falls back to native when telescope missing', function()
  config.setup({
    ui = {
      picker = 'telescope',
    },
  })

  local original_require = require
  _G.require = function(name)
    if vim.startswith(name, 'telescope') then
      error('module not found: ' .. name)
    end

    return original_require(name)
  end

  local calls = {}
  local original = vim.ui.select
  vim.ui.select = function(items, _, on_done)
    table.insert(calls, items)
    on_done(items[1])
  end

  local choice
  local ok, err = pcall(function()
    ui.select({ 'day' }, {}, function(item)
      choice = item
    end)
  end)

  vim.ui.select = original
  _G.require = original_require

  if not ok then
    error(err)
  end

  t.eq(choice, 'day')
  t.eq(#calls, 1)
end)

t.test('select uses telescope picker when configured', function()
  config.setup({
    ui = {
      picker = 'telescope',
    },
  })

  local original_require = require
  local calls = {}
  local replaced

  _G.require = function(name)
    if name == 'telescope.pickers' then
      return {
        new = function(_, picker_opts)
          table.insert(calls, {
            prompt_title = picker_opts.prompt_title,
            first = picker_opts.finder.results[1],
          })

          return {
            find = function()
              picker_opts.attach_mappings(17)
              replaced()
            end,
          }
        end,
      }
    end

    if name == 'telescope.finders' then
      return {
        new_table = function(opts)
          return opts
        end,
      }
    end

    if name == 'telescope.config' then
      return {
        values = {
          generic_sorter = function()
            return function() end
          end,
        },
      }
    end

    if name == 'telescope.actions' then
      return {
        close = function() end,
        select_default = {
          replace = function(_, fn)
            replaced = fn
          end,
        },
      }
    end

    if name == 'telescope.actions.state' then
      return {
        get_selected_entry = function()
          return {
            value = 'week',
          }
        end,
      }
    end

    return original_require(name)
  end

  local choice
  local selected_ok
  local ok, err = pcall(function()
    selected_ok = ui.select({ 'day', 'week' }, { prompt = 'Select journal' }, function(item)
      choice = item
    end)
  end)

  _G.require = original_require

  if not ok then
    error(err)
  end

  t.eq(choice, 'week')
  t.eq(selected_ok, true)
  t.eq(#calls, 1)
  t.eq(calls[1].prompt_title, 'Select journal')
end)

t.test('select uses snacks picker when configured', function()
  config.setup({
    ui = {
      picker = 'snacks',
    },
  })

  local saved = package.loaded['snacks']
  local calls = {}
  package.loaded['snacks'] = {
    picker = {
      select = function(items, opts, on_done)
        table.insert(calls, {
          items = items,
          prompt = opts.prompt,
          rendered = opts.format_item(items[1]),
        })
        on_done(items[1])
      end,
    },
  }

  local choice
  local ok, err = pcall(function()
    ui.select({ { name = 'day' } }, {
      prompt = 'Select journal',
      format_item = function(item)
        return item.name
      end,
    }, function(item)
      choice = item
    end)
  end)

  package.loaded['snacks'] = saved

  if not ok then
    error(err)
  end

  t.eq(choice.name, 'day')
  t.eq(#calls, 1)
  t.eq(calls[1].prompt, 'Select journal')
  t.eq(calls[1].rendered, 'day')
end)
