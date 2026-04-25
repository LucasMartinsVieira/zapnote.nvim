local M = {}

local defaults = {
  zn_cmd = 'zn',
  ui = {
    select = nil,
    input = nil,
  },
  link = {
    enabled = true,
    format = '[[%s]]',
  },
  open = {
    cmd = 'edit',
  },
}

local state = vim.deepcopy(defaults)

function M.setup(opts)
  state = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
  return state
end

function M.get()
  return state
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M

