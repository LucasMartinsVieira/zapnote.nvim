---@meta

---@alias ZapnoteSelectFn fun(items: any[], opts: table, on_choice: fun(choice: any|nil)): any
---@alias ZapnoteInputFn fun(opts: table, on_done: fun(value: string|nil)): any
---@alias ZapnotePickerBackend 'native'|'telescope'|'snacks'

---@class ZapnoteUiConfig
---@field picker ZapnotePickerBackend|nil
---@field select ZapnoteSelectFn|nil
---@field input ZapnoteInputFn|nil

---@class ZapnoteLinkConfig
---@field enabled boolean
---@field format string

---@class ZapnoteOpenConfig
---@field cmd string

---@class ZapnoteConfig
---@field zn_cmd string
---@field ui ZapnoteUiConfig
---@field link ZapnoteLinkConfig
---@field open ZapnoteOpenConfig

---@class ZapnoteTemplateEntry
---@field name string
---@field path string

---@class ZapnoteJournalEntry
---@field name string
---@field format string
---@field template string
---@field folder_path string

---@class ZapnoteNoteParseResult
---@field template string|nil
---@field title string|nil

---@class ZapnoteJournalParseResult
---@field name string|nil
---@field date string|nil
---@field offset string|nil

---@class ZapnoteJournalArgs
---@field date string|nil
---@field offset string|nil

---@class ZapnoteJournalNavArgs
---@field offset string|nil
---@field date string|nil

---@class ZapnoteVisualSelection
---@field bufnr integer
---@field mode string
---@field text string
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer

---@class ZapnoteCommandOpts
---@field fargs string[]
---@field range integer
