local Text = require('nui.text')
local Layout = require('nui.layout')
local Popup = require('nui.popup')
local Menu = require('nui.menu')
local Box = Layout.Box

function Popup:set_text(s, e, f, content)
  vim.api.nvim_buf_set_lines(self.bufnr, s, e, f, content)
end

for i, v in ipairs(require('dock').docker().containers()) do
  id, name, image, status = unpack(vim.split(v, '/'))
  data = { id = id, name = name, image = image, status = status}
  data.action = function()
    require('dock.ui').manage(id)
  end
  containers[i] = Menu.item(name, data)
end

local ContainerMenu = Menu(
  {
    border = {
      style = 'rounded',
      text = {
        top = Text(' CONTAINERS ', 'IncSearch')
      }
    },
    position = '50%',
    size = '15%',
    relative = 'editor',
    enter = true,
    win_options = {
      winhighlight = 'Normal:Fon,FloatBorder:Fon'
    }
  },
  {
    lines = containers,
    keymap = {
      close = { 'q' },
      submit = {'<CR>'}
    },
    on_submit = function (v)
      v.action()
    end,
    on_change = function (v)
    end
})

local M = {}

M.manage = function (id)
  print(id)
end

M.run = function ()
  ContainerMenu:mount()
end


return M

