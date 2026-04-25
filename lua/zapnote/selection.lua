local M = {}

local function trim(text)
  return text:match('^%s*(.-)%s*$') or ''
end

---@param text string
---@return string
function M.normalize_text(text)
  local normalized = text:gsub('\r', ''):gsub('\n+', ' ')
  return trim(normalized)
end

---@param bufnr integer
---@param start_row integer
---@param end_row integer
---@return ZapnoteVisualSelection|nil
local function linewise_range(bufnr, start_row, end_row)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  local text = M.normalize_text(table.concat(lines, '\n'))

  return {
    bufnr = bufnr,
    mode = 'V',
    text = text,
    start_row = start_row,
    start_col = 0,
    end_row = end_row,
    end_col = #(lines[#lines] or ''),
  }
end

---@param bufnr integer
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@return ZapnoteVisualSelection|nil
local function charwise_range(bufnr, start_row, start_col, end_row, end_col)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  if #lines == 0 then
    return nil
  end

  lines[1] = string.sub(lines[1], start_col + 1)
  lines[#lines] = string.sub(lines[#lines], 1, end_col + 1)

  local text = M.normalize_text(table.concat(lines, '\n'))

  return {
    bufnr = bufnr,
    mode = 'v',
    text = text,
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col + 1,
  }
end

---@return ZapnoteVisualSelection|nil, string|nil
function M.get_last_visual_selection()
  local mode = vim.fn.visualmode()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  return M.from_marks(bufnr, mode, start_pos, end_pos)
end

---@param bufnr integer
---@param mode string
---@param start_pos integer[]
---@param end_pos integer[]
---@return ZapnoteVisualSelection|nil, string|nil
function M.from_marks(bufnr, mode, start_pos, end_pos)
  if mode == '' then
    return nil
  end

  if mode == '\022' then
    return nil, 'blockwise visual selection not supported'
  end

  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3] - 1

  if start_row < 0 or end_row < 0 then
    return nil
  end

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  local selection
  if mode == 'V' then
    selection = linewise_range(bufnr, start_row, end_row)
  else
    selection = charwise_range(bufnr, start_row, start_col, end_row, end_col)
  end

  if not selection then
    return nil
  end

  if selection.text == '' then
    return nil, 'empty visual selection'
  end

  return selection
end

return M
