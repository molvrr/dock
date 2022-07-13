local job = require('plenary.job')
local popup = require('plenary.popup')
local exec = vim.api.nvim_exec
local docker = vim.fn.executable('docker')
local M = {}

Dock_win_id = nil
Dock_buf_id = nil

M.docker = function()
  local t = {}
  t.containers = function ()
    local c = vim.split(exec("!docker ps --format '{{.ID}}/{{.Names}}/{{.Image}}/{{.Status}}'", true), '\r\n')
    local c = vim.split(vim.trim(table.concat(c, '')), '\n')
    table.remove(c, 1)
    return c
  end


  return t
end

M.show_containers = function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  local containers = M.docker().containers()
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':bd<CR>', { silent = true })
  vim.api.nvim_buf_set_name(bufnr, 'dock')
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'delete')
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'x', ':lua require("dock").kill_current_container()<CR>', { silent = true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'r', ':lua require("dock").async_restart_container()<CR>', { silent = true })
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { 'ID/NAME/IMAGE/UPTIME' })
  vim.api.nvim_buf_set_lines(bufnr, 1, #containers+1, false, containers)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  local Dock_win_id, win = popup.create(bufnr, {
    minwidth = 100,
    minheight = 20,
    border = {1, 1, 1, 1},
    highlight = 'DOCKER',
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    title = 'CONTAINERS',
  })
  vim.api.nvim_win_set_cursor(0, {2, 0})
  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:DockBorder"
  )
end

M.kill_current_container = function ()
  local container = vim.api.nvim_get_current_line()
  local id = vim.split(container, '/')
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_buf_line_count(bufnr)
  local prompt = nil
  vim.ui.input({prompt = 'Are you sure you wish to kill this container? [y/n]'}, function (v) prompt = v end)
  if prompt == 'y' or prompt == nil then
    exec('!docker kill '..id[1], true)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    local containers = M.docker().containers() or {}
    vim.api.nvim_buf_set_lines(bufnr, 1, line, false, containers)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  end
end

M.async_restart_container = function ()
  local container = vim.api.nvim_get_current_line()
  local id = vim.split(container, '/')
  local bufnr = vim.api.nvim_get_current_buf()
  job:new({
    command = 'docker',
    args = {'container', 'restart', id[1]},
    on_exit = function(j, exit_code)
      vim.defer_fn(function()
        vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
        local containers = M.docker().containers()
        vim.api.nvim_buf_set_lines(bufnr, 1, #containers+1, false, containers)
        vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
      end, 0)
    end
  }):start()
end

M.show_container = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local container = vim.api.nvim_get_current_line()
  print(container)
end

M.setup = function()
  if docker then
    vim.api.nvim_command("command! -bar Docker lua require('dock').show_containers()")
  else
    print('Docker is not installed')
  end
end

return M
