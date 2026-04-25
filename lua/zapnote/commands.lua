local M = {}

---@param values string[]|nil
---@param target string
---@return boolean
local function contains(values, target)
  for _, value in ipairs(values or {}) do
    if value == target then
      return true
    end
  end

  return false
end

---@param fargs string[]
---@param templates string[]|nil
---@return ZapnoteNoteParseResult
---@return ZapnoteNoteParseResult
function M.parse_note_fargs(fargs, templates)
  if #fargs == 0 then
    return {
      template = nil,
      title = nil,
    }
  end

  if contains(templates, fargs[1]) then
    return {
      template = fargs[1],
      title = #fargs > 1 and table.concat(vim.list_slice(fargs, 2), ' ') or nil,
    }
  end

  if (not templates or vim.tbl_isempty(templates)) and #fargs > 1 then
    return {
      template = fargs[1],
      title = table.concat(vim.list_slice(fargs, 2), ' '),
    }
  end

  return {
    template = nil,
    title = table.concat(fargs, ' '),
  }
end

---@param fargs string[]
---@return ZapnoteJournalParseResult|nil, string|nil
---@return ZapnoteJournalParseResult|nil, string|nil
function M.parse_journal_fargs(fargs)
  local parsed = {
    name = nil,
    date = nil,
    offset = nil,
  }

  local index = 1
  if fargs[1] and not vim.startswith(fargs[1], '--') then
    parsed.name = fargs[1]
    index = 2
  end

  while index <= #fargs do
    local arg = fargs[index]

    if arg == '--date' then
      parsed.date = fargs[index + 1]
      index = index + 2
    elseif vim.startswith(arg, '--date=') then
      parsed.date = arg:sub(#'--date=' + 1)
      index = index + 1
    elseif arg == '--offset' then
      local parts = {}
      local next_index = index + 1

      while next_index <= #fargs and not vim.startswith(fargs[next_index], '--') and #parts < 2 do
        table.insert(parts, fargs[next_index])
        next_index = next_index + 1
      end

      if #parts == 0 then
        return nil, 'missing value for --offset'
      end

      parsed.offset = table.concat(parts, ' ')
      index = next_index
    elseif vim.startswith(arg, '--offset=') then
      parsed.offset = arg:sub(#'--offset=' + 1)
      index = index + 1
    else
      return nil, string.format('unsupported argument: %s', arg)
    end
  end

  if parsed.date == '' then
    return nil, 'missing value for --date'
  end

  return parsed
end

function M.register()
  ---@param opts ZapnoteCommandOpts
  vim.api.nvim_create_user_command('ZnNote', function(opts)
    require('zapnote').note({
      cmd = opts,
    })
  end, {
    nargs = '*',
    range = true,
    desc = 'Create or open Zapnote note',
  })

  ---@param opts ZapnoteCommandOpts
  vim.api.nvim_create_user_command('ZnJournal', function(opts)
    require('zapnote').journal({
      cmd = opts,
    })
  end, {
    nargs = '*',
    range = true,
    desc = 'Create or open Zapnote journal',
  })
end

return M
