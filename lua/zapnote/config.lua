---@class ZapnoteConfig
local M = {}

---@type ZapnoteConfig
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

---@type ZapnoteConfig
local state = vim.deepcopy(defaults)

---@param opts Partial<ZapnoteConfig>|nil
---@return ZapnoteConfig
function M.setup(opts)
  state = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
  return state
end

---@return ZapnoteConfig
function M.get()
  return state
end

---@return ZapnoteConfig
function M.defaults()
  return vim.deepcopy(defaults)
end

return M
