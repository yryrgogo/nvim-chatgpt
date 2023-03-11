local api = vim.api
local Split = require('nui.split')
local event = require("nui.utils.autocmd").event
local win = Split({
  relative = "editor",
  position = "bottom",
  size = "20%",
})

local _config = require('chatpanel.config')
local config = _config.config

local M = {}

M.write_virtual_text = function(bufnr, ns, line, chunks)
  local virt_text = {}
  for _, chunk in ipairs(chunks) do
    local hl = chunk[2]
    local text = chunk[1]
    if hl then
      table.insert(virt_text, { text, hl })
    else
      table.insert(virt_text, text)
    end
  end
  api.nvim_buf_set_virtual_text(bufnr, ns, line, virt_text, {})
end

M.exists_window = function(state)
  if state.bufnr ~= nil then
    local windows = vim.fn.win_findbuf(state.bufnr)
    if #windows >= 1 then
      for _, win_id in pairs(windows) do
        if vim.fn.win_gotoid(win_id) == 1 then
          return true
        end
      end
    end
  end
  return false
end

M.init_window = function(state)
  -- mount/open the component
  state.win = win
  state.win:mount()
  -- hide component when cursor leaves buffer
  -- split:on(event.BufLeave, function()
  --   split:hide()
  -- end)

  state.bufnr = api.nvim_get_current_buf()
  M.write_virtual_text(state.bufnr, config.namespace_panel, 0, { { "Nvim Chat", "" } })

  api.nvim_buf_clear_namespace(state.bufnr, config.namespace_panel, 0, -1)
  api.nvim_buf_set_lines(state.bufnr, 0, -1, 0, {})

  local lines = {}
  local last_line = 3
  for _ = 1, last_line do
    table.insert(lines, "")
  end
  api.nvim_buf_set_lines(state.bufnr, 0, 0, 0, lines)

  local line = 1
  M.write_virtual_text(state.bufnr, config.namespace_panel, line - 1, { { "Nvim Chat", "" } })
  M.write_virtual_text(state.bufnr, config.namespace_panel, line, { { "Input your message...", "String" } })

  api.nvim_win_set_cursor(0, { 3, 0 })
end

M.open_chat_window = function(state)
  if M.exists_window(state) == false then
    M.init_window(state)
  end
end

M.add_highlight = function(line)
  api.nvim_command('highlight ' .. config.highlight.message .. ' guifg=#00FFFF')
  api.nvim_buf_add_highlight(0, config.namespace_panel, config.highlight.message, line, 0, -1)
end

M.show_window = function(state)
  if state.win then
    state.win:show()
  end
end

M.hide_window = function(state)
  if M.exists_window(state) then
    state.win:hide()
  end
end

return M
