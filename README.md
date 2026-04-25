# zapnote.nvim

Thin Neovim wrapper around `zn`.

V1 goals:

- create or open regular notes with `:ZnNote`
- create or open journal notes with `:ZnJournal`
- use visual selection as note title
- replace successful visual note selection with `[[title]]`
- keep `zn` as source of truth for templates, journals, and path resolution

## Install

Example with `lazy.nvim`:

```lua
{
  dir = "~/repos/zapnote.nvim",
  config = function()
    require("zapnote").setup()
  end,
}
```

## Setup

```lua
require("zapnote").setup({
  zn_cmd = "zn",
  link = {
    enabled = true,
    format = "[[%s]]",
  },
  open = {
    cmd = "edit",
  },
})
```

## Commands

```vim
:ZnNote
:ZnNote meeting Project kickoff
:'<,'>ZnNote
:'<,'>ZnNote meeting

:ZnJournal
:ZnJournal day
:ZnJournal day --offset -1 day
:ZnJournal week --date 2026-W04
```

## Testing

```sh
nvim --headless -u NONE -c "lua require('tests.run').run()" -c qa
```

