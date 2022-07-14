local docker = vim.fn.executable('docker')
local docker_api = require('dock.docker_api')
local M = {}

Dock_win_id = nil
Dock_buf_id = nil

M.show_containers = function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  local containers_data = docker_api.list_containers()
  local containers = {}
  --vim.api.nvim_buf_set_name(bufnr, 'dock')
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'delete')
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_lines(bufnr, 1, #containers+1, false, containers)
end

M.setup = function()
  if docker then
    vim.api.nvim_command("command! -bar Docker lua require('dock').show_containers()")
  else
    print('Docker is not installed')
  end
end

return M
