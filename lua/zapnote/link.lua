local M = {}

---@param message string
---@param level integer|nil
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, {
    title = 'zapnote.nvim',
  })
end

---@param title string
---@param fmt string|nil
---@return string
function M.render_link(title, fmt)
  return string.format(fmt or '[[%s]]', title)
end

---@param selection ZapnoteVisualSelection|nil
---@param replacement string
---@return boolean|nil, string|nil
function M.replace_selection(selection, replacement)
  if not selection then
    return nil, 'missing selection'
  end

  if selection.mode ~= 'v' and selection.mode ~= 'V' then
    return nil, 'unsupported selection mode'
  end

  vim.api.nvim_buf_set_text(
    selection.bufnr,
    selection.start_row,
    selection.start_col,
    selection.end_row,
    selection.end_col,
    { replacement }
  )

  return true
end

---@param selection ZapnoteVisualSelection|nil
---@param title string
---@param fmt string|nil
---@return boolean
function M.replace_with_link(selection, title, fmt)
  local link = M.render_link(title, fmt)
  local ok, err = M.replace_selection(selection, link)

  if not ok and err then
    notify(err, vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
