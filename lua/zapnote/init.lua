local cli = require('zapnote.cli')
local commands = require('zapnote.commands')
local config = require('zapnote.config')
local link = require('zapnote.link')
local open = require('zapnote.open')
local selection = require('zapnote.selection')
local ui = require('zapnote.ui')

local M = {}

local registered = false

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, {
    title = 'zapnote.nvim',
  })
end

local function template_names(templates)
  local names = {}
  for _, template in ipairs(templates or {}) do
    table.insert(names, template.name)
  end
  return names
end

local function open_path(path)
  local normalized, err = open.edit(path)
  if not normalized then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  return normalized
end

local function resolve_visual_selection(cmd_opts)
  if not cmd_opts or cmd_opts.range == 0 then
    return nil
  end

  local visual, err = selection.get_last_visual_selection()
  if not visual then
    if err then
      notify(err, vim.log.levels.ERROR)
    end
    return nil
  end

  return visual
end

local function resolve_title(explicit_title, visual, on_done)
  if explicit_title and explicit_title ~= '' then
    on_done(explicit_title, 'arg')
    return
  end

  if visual and visual.text ~= '' then
    on_done(visual.text, 'selection')
    return
  end

  ui.input({
    prompt = 'Note title: ',
  }, function(value)
    local title = vim.trim(value or '')
    if title == '' then
      notify('note title required', vim.log.levels.ERROR)
      on_done(nil, nil)
      return
    end

    on_done(title, 'prompt')
  end)
end

local function resolve_template(explicit_template, templates, on_done)
  if explicit_template and explicit_template ~= '' then
    on_done(explicit_template)
    return
  end

  if templates and not vim.tbl_isempty(templates) then
    ui.select_name('template', templates, function(choice)
      if not choice or not choice.name or choice.name == '' then
        notify('template required', vim.log.levels.ERROR)
        on_done(nil)
        return
      end

      on_done(choice.name)
    end)
    return
  end

  ui.input({
    prompt = 'Template: ',
  }, function(value)
    local template = vim.trim(value or '')
    if template == '' then
      notify('template required', vim.log.levels.ERROR)
      on_done(nil)
      return
    end

    on_done(template)
  end)
end

local function resolve_journal_name(explicit_name, journals, on_done)
  if explicit_name and explicit_name ~= '' then
    on_done(explicit_name)
    return
  end

  if journals and not vim.tbl_isempty(journals) then
    ui.select_name('journal', journals, function(choice)
      if not choice or not choice.name or choice.name == '' then
        notify('journal name required', vim.log.levels.ERROR)
        on_done(nil)
        return
      end

      on_done(choice.name)
    end)
    return
  end

  ui.input({
    prompt = 'Journal: ',
  }, function(value)
    local name = vim.trim(value or '')
    if name == '' then
      notify('journal name required', vim.log.levels.ERROR)
      on_done(nil)
      return
    end

    on_done(name)
  end)
end

function M.setup(opts)
  config.setup(opts)

  if not registered then
    commands.register()
    registered = true
  end
end

function M.note(opts)
  opts = opts or {}

  local visual = resolve_visual_selection(opts.cmd)

  cli.list_templates(function(err, templates)
    if err then
      notify(err, vim.log.levels.WARN)
      templates = {}
    end

    local parsed = commands.parse_note_fargs(opts.cmd and opts.cmd.fargs or {}, template_names(templates))

    resolve_title(opts.title or parsed.title, visual, function(title, title_source)
      if not title then
        return
      end

      resolve_template(opts.template or parsed.template, templates, function(template)
        if not template then
          return
        end

        cli.run_note(template, title, function(run_err, path)
          if run_err then
            return
          end

          if visual and title_source == 'selection' and config.get().link.enabled then
            link.replace_with_link(visual, title, config.get().link.format)
          end

          if not open_path(path) then
            return
          end
        end)
      end)
    end)
  end)
end

function M.journal(opts)
  opts = opts or {}

  local parsed, err = commands.parse_journal_fargs(opts.cmd and opts.cmd.fargs or {})
  if not parsed then
    notify(err, vim.log.levels.ERROR)
    return
  end

  cli.list_journals(function(list_err, journals)
    if list_err then
      notify(list_err, vim.log.levels.WARN)
      journals = {}
    end

    resolve_journal_name(opts.name or parsed.name, journals, function(name)
      if not name then
        return
      end

      cli.run_journal(name, {
        date = opts.date or parsed.date,
        offset = opts.offset or parsed.offset,
      }, function(run_err, path)
        if run_err then
          return
        end

        open_path(path)
      end)
    end)
  end)
end

return M
