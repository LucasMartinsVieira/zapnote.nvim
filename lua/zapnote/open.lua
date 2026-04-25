local config = require('zapnote.config')

local M = {}

---@param path string|nil
---@return string|nil
function M.normalize_path(path)
  if not path or path == '' then
    return nil
  end

  if vim.fs and vim.fs.normalize then
    if vim.fn.fnamemodify(path, ':p') == path then
      return vim.fs.normalize(path)
    end

    return vim.fs.normalize(vim.fs.joinpath(vim.uv.cwd(), path))
  end

  return vim.fn.fnamemodify(path, ':p')
end

---@param path string
---@return string|nil, string|nil
function M.edit(path)
  local normalized = M.normalize_path(path)
  if not normalized then
    return nil, 'missing file path from zn output'
  end

  local open_cmd = config.get().open.cmd or 'edit'
  vim.cmd(string.format('%s %s', open_cmd, vim.fn.fnameescape(normalized)))
  return normalized
end

return M
