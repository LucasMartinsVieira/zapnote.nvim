# Repository Guidelines

## Project Structure & Module Organization

This repository is a Neovim plugin wrapper around `zn`.

- `plugin/zapnote.lua` registers commands on load.
- `lua/zapnote/` holds the plugin logic:
  - `init.lua` public entrypoint
  - `cli.lua` `zn` process calls and JSON decoding
  - `commands.lua` Ex command parsing
  - `selection.lua` visual selection handling
  - `link.lua` wiki-link replacement
  - `open.lua` buffer/file opening
  - `ui.lua` prompt and picker helpers
- `doc/zapnote.txt` is the help file.
- `tests/` contains headless Neovim specs and the tiny test runner.

## Build, Test, and Development Commands

There is no build step. Work directly from Neovim.

- `nvim --headless -u NONE -i NONE -c "lua require('tests.run').run()" -c qa` runs the full test suite.
- `nvim --headless -u NONE -i NONE -c "set runtimepath^=/home/lucas/repos/zapnote.nvim" -c "lua require('zapnote').setup()" -c qa` smoke-tests plugin load.
- `stylua lua tests plugin` formats Lua code if you have `stylua` installed.

## Coding Style & Naming Conventions

- Use 2-space indentation and single quotes for Lua strings where practical.
- Keep modules small and focused; prefer one responsibility per file.
- Public plugin API lives under `require('zapnote')`.
- Ex commands use `Zn*` naming, for example `:ZnNote` and `:ZnJournal`.
- Keep code ASCII-only unless an existing file already uses other characters.

## Testing Guidelines

Tests are plain Lua specs under `tests/*_spec.lua`, run through `tests/run.lua`.

- Add unit coverage for parsing, selection normalization, link replacement, and CLI path extraction.
- Prefer deterministic tests that do not require a real `zn` binary.
- When adding command behavior, include at least one headless integration-style test path.

## Security & Configuration Tips

- Do not parse `zapnote.toml` in the plugin. `zn` remains source of truth.
- Treat `zn` stderr as display text, not structured data.
- Keep the plugin tolerant of missing picker integrations; builtin `vim.ui.*` should always work.
