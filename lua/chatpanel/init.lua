local api = vim.api
local set_keymap = vim.api.nvim_set_keymap
local plenary = require('plenary.reload')

local reload = function(path)
  if _G.__is_dev then
    print(vim.inspect(path))
  end
  plenary.reload_module(path)
end

local modules = {
  'chatpanel.config',
  'chatpanel.ai',
  'chatpanel.ui',
}

local reload_all_modules = function()
  for _, module in ipairs(modules) do
    reload(module)
  end
end
reload_all_modules()

local _config = require('chatpanel.config')
local config, state = _config.config, _config.state
local ui = require('chatpanel.ui')
local ai = require('chatpanel.ai')

local M = {}

function start()
  ui.open_chat_window(state)
end

function chat()
  ai.chat(state)
end

function show()
  ui.show_window(state)
end

function hide()
  ui.hide_window(state)
end

set_keymap('n', 'cs', '<cmd>lua start()<cr>', { noremap = true, silent = false })
set_keymap('n', 'cc', '<cmd>lua chat()<cr>', { noremap = true, silent = false })
set_keymap('n', 'co', '<cmd>lua show()<cr>', { noremap = true, silent = false })
set_keymap('n', 'ch', '<cmd>lua hide()<cr>', { noremap = true, silent = false })
