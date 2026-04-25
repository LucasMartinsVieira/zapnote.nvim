local M = {}

local SECONDS_PER_DAY = 86400

---@param year integer
---@param month integer
---@return integer
local function days_in_month(year, month)
  return os.date('*t', os.time({
    year = year,
    month = month + 1,
    day = 0,
    hour = 12,
  })).day
end

---@param year integer
---@param month integer
---@param day integer
---@return integer, integer, integer
local function normalize_ymd(year, month, day)
  local total_months = (year * 12) + (month - 1)
  local normalized_year = math.floor(total_months / 12)
  local normalized_month = (total_months % 12) + 1
  local normalized_day = math.min(day, days_in_month(normalized_year, normalized_month))
  return normalized_year, normalized_month, normalized_day
end

---@param year integer
---@param week integer
---@return integer, integer, integer
local function iso_week_monday(year, week)
  local jan4 = os.time({
    year = year,
    month = 1,
    day = 4,
    hour = 12,
  })
  local jan4_date = os.date('*t', jan4)
  local days_since_monday = (jan4_date.wday + 5) % 7
  local week1_monday = jan4 - (days_since_monday * SECONDS_PER_DAY)
  local target = week1_monday + ((week - 1) * 7 * SECONDS_PER_DAY)
  local date = os.date('*t', target)
  return date.year, date.month, date.day
end

---@param anchor string
---@return integer|nil, integer|nil, integer|nil
function M.anchor_to_date(anchor)
  local year, month, day = anchor:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
  if year then
    return tonumber(year), tonumber(month), tonumber(day)
  end

  local iso_year, iso_week = anchor:match('^(%d%d%d%d)%-W(%d%d?)$')
  if iso_year then
    return iso_week_monday(tonumber(iso_year), tonumber(iso_week))
  end

  local quarter_year, quarter = anchor:match('^(%d%d%d%d)%-Q([1-4])$')
  if quarter_year then
    return tonumber(quarter_year), ((tonumber(quarter) - 1) * 3) + 1, 1
  end

  year, month = anchor:match('^(%d%d%d%d)%-(%d%d)$')
  if year then
    return tonumber(year), tonumber(month), 1
  end

  year = anchor:match('^(%d%d%d%d)$')
  if year then
    return tonumber(year), 1, 1
  end

  return nil
end

---@param year integer
---@param month integer
---@param day integer
---@param amount integer
---@return integer, integer, integer
local function add_days(year, month, day, amount)
  local ts = os.time({
    year = year,
    month = month,
    day = day,
    hour = 12,
  })
  local date = os.date('*t', ts + (amount * SECONDS_PER_DAY))
  return date.year, date.month, date.day
end

---@param year integer
---@param month integer
---@param day integer
---@param amount integer
---@return integer, integer, integer
local function add_months(year, month, day, amount)
  return normalize_ymd(year, month + amount, day)
end

---@param anchor string
---@param offset string
---@return integer|nil, integer|nil, integer|nil, string|nil
function M.offset_anchor(anchor, offset)
  local amount, unit = offset:match('^([+-]?%d+)%s*(%a+)$')
  if not amount then
    return nil, nil, nil, string.format("unsupported offset '%s'", offset)
  end

  local year, month, day = M.anchor_to_date(anchor)
  if not year then
    return nil, nil, nil, string.format("unsupported anchor '%s'", anchor)
  end

  amount = tonumber(amount)
  unit = unit:lower()

  if unit == 'day' or unit == 'days' then
    return add_days(year, month, day, amount)
  end

  if unit == 'week' or unit == 'weeks' then
    return add_days(year, month, day, amount * 7)
  end

  if unit == 'month' or unit == 'months' then
    return add_months(year, month, day, amount)
  end

  if unit == 'quarter' or unit == 'quarters' then
    return add_months(year, month, day, amount * 3)
  end

  if unit == 'year' or unit == 'years' then
    return add_months(year, month, day, amount * 12)
  end

  return nil, nil, nil, string.format("unsupported offset '%s'", offset)
end

---@param year integer
---@param month integer
---@param day integer
---@return integer
local function to_timestamp(year, month, day)
  return os.time({
    year = year,
    month = month,
    day = day,
    hour = 12,
  })
end

---@param format string
---@param year integer
---@param month integer
---@param day integer
---@return string
function M.format_date(format, year, month, day)
  if format == '%Y-%m-%d' then
    return string.format('%04d-%02d-%02d', year, month, day)
  end

  if format == '%Y-%m' then
    return string.format('%04d-%02d', year, month)
  end

  if format == '%Y' then
    return string.format('%04d', year)
  end

  if format == '%Y-Q%Q' then
    local quarter = math.floor((month - 1) / 3) + 1
    return string.format('%04d-Q%d', year, quarter)
  end

  if format == '%G-W%V' then
    local ts = to_timestamp(year, month, day)
    local iso_year = tonumber(vim.fn.strftime('%G', ts))
    local iso_week = tonumber(vim.fn.strftime('%V', ts))
    return string.format('%04d-W%02d', iso_year, iso_week)
  end

  return os.date(format, to_timestamp(year, month, day))
end

---@param anchor string
---@param offset string|nil
---@param format string
---@return string|nil, string|nil
function M.resolve_target(anchor, offset, format)
  local year, month, day, err

  if offset and offset ~= '' then
    year, month, day, err = M.offset_anchor(anchor, offset)
  else
    year, month, day = M.anchor_to_date(anchor)
  end

  if not year then
    return nil, err or string.format("unsupported anchor '%s'", anchor)
  end

  return M.format_date(format, year, month, day), nil
end

return M
