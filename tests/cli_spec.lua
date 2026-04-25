local t = require('tests.minitest')
local cli = require('zapnote.cli')

t.test('extract_path trims stdout', function()
  local path = cli.extract_path('  notes/test.md \n')
  t.eq(path, 'notes/test.md')
end)

t.test('extract_path rejects empty stdout', function()
  local path, err = cli.extract_path('\n')
  t.eq(path, nil)
  t.eq(err, 'missing file path from zn output')
end)

