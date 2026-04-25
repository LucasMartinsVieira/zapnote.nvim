local M = {}

local tests = {}

function M.test(name, fn)
  table.insert(tests, {
    name = name,
    fn = fn,
  })
end

function M.eq(actual, expected)
  if not vim.deep_equal(actual, expected) then
    error(string.format('expected %s, got %s', vim.inspect(expected), vim.inspect(actual)))
  end
end

function M.ok(value, message)
  if not value then
    error(message or 'assertion failed')
  end
end

function M.run()
  local failures = {}

  for _, test in ipairs(tests) do
    local ok, err = pcall(test.fn)
    if not ok then
      table.insert(failures, string.format('%s: %s', test.name, err))
    end
  end

  if #failures > 0 then
    error(table.concat(failures, '\n'))
  end
end

return M

