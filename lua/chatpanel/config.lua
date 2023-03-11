local api = vim.api

local config = {
  filetype = "chatgpt_panel",
  namespace_panel = api.nvim_create_namespace("CHATGPT_PANEL"),
  line_sep = '--------------------------------------',
  highlight = {
    title = "Title",
  },
  mapping = {},
}

local state = {
  query = {},
  vt = {}
}

_G.__chat_state = _G.__chat_state or state
state = _G.__chat_state

return {
  state = state,
  config = config,
}
