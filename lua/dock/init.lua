local exec = vim.api.nvim_exec
local popup = require('plenary.popup')
local M = {}
local docker = vim.fn.executable('docker')

Dock_win_id = nil

if (docker) then
  M.docker = function()
    local t = {}
    t.containers = function ()
      local c = vim.split(exec("!docker ps --format '{{.ID}}/{{.Names}}/{{.Image}}/{{.RunningFor}}'", true), '\r\n')
      local c = vim.split(vim.trim(table.concat(c, '')), '\n')
      table.remove(c, 1)
      return c
    end


    return t
  end
end

M.show_containers = function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  local containers = M.docker().containers()
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':bd<CR>', {silent = true})
  vim.api.nvim_buf_set_name(bufnr, 'dock')
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'x', ':lua require("dock").kill_current_container()<CR>', {silent = true})
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { 'ID/NAME/IMAGE/UPTIME' })
  vim.api.nvim_buf_set_lines(bufnr, 1, #containers, false, containers)
  local Dock_win_id, win = popup.create(bufnr, {
    minwidth = 100,
    minheight = 20,
    border = {1, 1, 1, 1},
    highlight = 'DOCKER',
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    title = 'DOCK',
  })
  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:DockBorder"
  )
end

M.kill_current_container = function ()
  local container = vim.api.nvim_get_current_line()
  local id = vim.split(container, '/')
  exec('!docker kill '..id[1], true)
  local bufnr = vim.api.nvim_get_current_buf()
  exec(':%d', true)
  local containers = M.docker().containers()
  for i, v in ipairs(containers) do
    vim.api.nvim_buf_set_lines(bufnr, i-1, i-1, false, {v})
  end
end

M.show_container = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local container = vim.api.nvim_get_current_line()
  print(container)
end

return M
