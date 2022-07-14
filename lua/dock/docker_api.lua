local curl = require('plenary.curl')
local M = {}

M.containers = {}

M.containers.list = function ()
  local containers = {}
  local resp = curl.get('http://localhost/v1.41/containers/json', { raw = {'--unix-socket', '/var/run/docker.sock'}})
  local data = vim.json.decode(resp.body)
  local p = nil
  for i, v in ipairs(data) do
    containers[i] = {}
    containers[i].id = v.Id
    containers[i].name = string.gsub(v.Names[1], '/(%w+)', '%1')
    containers[i].image = v.Image
    containers[i].networks = {}
    for x, n in ipairs(v.NetworkSettings.Networks) do
      containers[i].networks[1] = x
    end
  end
  return containers
end

M.containers.kill = function (c)
  local resp = curl.post('http://localhost/v1.41/containers/'..c..'/kill', { raw = {'--unix-socket', '/var/run/docker.sock'}})
  return resp.status
end

M.containers.restart = function (c)
  local resp = curl.post('http://localhost/v1.41/containers/'..c..'/restart', { raw = {'--unix-socket', '/var/run/docker.sock'}})
  return resp.status
end

M.containers.rename = function (c, n)
  local resp = curl.post('http://localhost/v1.41/containers/'..c..'/rename', { body = { name = n }, raw = {'--unix-socket', '/var/run/docker.sock'}})
  return resp.status
end

M.containers.remove = function (c)
  local resp = curl.delete('http://localhost/v1.41/containers/'..c, { raw = {'--unix-socket', '/var/run/docker.sock'} })
  return resp.status
end

M.containers.stop = function (c)
  local resp = curl.post('http://localhost/v1.41/containers/'..c..'/stop', { raw = {'--unix-socket', '/var/run/docker.sock'} })
  return resp.status
end

return M
