local M = {}

function M.run()
  vim.opt.runtimepath:prepend(vim.fn.getcwd())

  require('tests.command_spec')
  require('tests.init_spec')
  require('tests.selection_spec')
  require('tests.link_spec')
  require('tests.cli_spec')

  require('tests.minitest').run()
  print('tests: ok')
end

return M
