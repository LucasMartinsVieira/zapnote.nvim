local t = require('tests.minitest')
local commands = require('zapnote.commands')

t.test('parse_note_fargs uses known template', function()
  local parsed = commands.parse_note_fargs({ 'meeting', 'Project', 'Kickoff' }, { 'meeting' })
  t.eq(parsed, {
    template = 'meeting',
    title = 'Project Kickoff',
  })
end)

t.test('parse_note_fargs falls back to title only', function()
  local parsed = commands.parse_note_fargs({ 'Project', 'Kickoff' }, { 'meeting' })
  t.eq(parsed, {
    template = nil,
    title = 'Project Kickoff',
  })
end)

t.test('parse_note_fargs guesses template when list unavailable', function()
  local parsed = commands.parse_note_fargs({ 'meeting', 'Project', 'Kickoff' }, {})
  t.eq(parsed, {
    template = 'meeting',
    title = 'Project Kickoff',
  })
end)

t.test('parse_journal_fargs keeps date and offset', function()
  local parsed = commands.parse_journal_fargs({ 'day', '--date', '2026-04-19', '--offset', '-1', 'day' })
  t.eq(parsed, {
    name = 'day',
    date = '2026-04-19',
    offset = '-1 day',
  })
end)

t.test('parse_journal_fargs rejects unknown args', function()
  local parsed, err = commands.parse_journal_fargs({ '--wat' })
  t.eq(parsed, nil)
  t.eq(err, 'unsupported argument: --wat')
end)

