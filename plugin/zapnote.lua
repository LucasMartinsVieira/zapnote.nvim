if vim.g.loaded_zapnote then
  return
end

vim.g.loaded_zapnote = 1

require('zapnote').setup()

