local api = vim.api
local Job = require('plenary.job')
local cjson = require("cjson")

local M = {}

M.get_query = function(state)
  local lines = api.nvim_buf_get_lines(state.bufnr, 0, -1, 0)
  local query = ""
  for _, line in pairs(lines) do
    query = query .. "\n" .. line
  end

  return query
end

local write_to_window = function(state, data)
  local lines = {}
  for line in data.message:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local line_count = api.nvim_buf_line_count(state.bufnr)
  local current_time = os.date("%Y-%m-%d %H:%M:%S", os.time())
  api.nvim_buf_set_lines(state.bufnr, line_count, -1, false,
    { "", "ChatGPT start" .. current_time .. "-------------------------", "" })
  api.nvim_buf_set_lines(state.bufnr, line_count + 3, -1, false, lines)

  local new_line_count = api.nvim_buf_line_count(state.bufnr)
  api.nvim_buf_set_lines(state.bufnr, new_line_count, -1, false,
    { "", "ChatGPT end ---------------------------------------------", "" })
end

M.chat = function(state)
  local query = M.get_query(state)
  if #query < 10 then
    print('query is too short.')
    return
  end

  local promptType = 'default'
  local name = os.getenv("USER_NAME")
  local url = os.getenv("CHATGPT_API_ENDPOINT")

  local job = Job:new({
    command = 'curl',
    args = {
      '--request',
      'POST',
      '--data',
      'text=' .. query .. '&promptType=' .. promptType .. '&name=' .. name,
      url
    },
    on_stdout = function(_, data)
      vim.pretty_print(data)
    end,
    on_stderr = function(_, data)
      vim.pretty_print(data)
    end,
    on_exit = function(res, exit_code)
      pcall(vim.schedule_wrap(
        function()
          if exit_code == 0 then
            local response = res:result()[1]
            local body = cjson.decode(response)
            write_to_window(state, body)
          else
            print('Failed to get response.')
          end
        end
      ))
    end
  })
  job:start()
end

return M
