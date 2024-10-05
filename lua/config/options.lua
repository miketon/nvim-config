-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- winbar : file path
opt.winbar = "%=%m %f"

-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
  local full_path = vim.fn.expand("%:p")
  return full_path:gsub(vim.fn.expand("$HOME"), "~")
end
-- Function to get the number of open buffers using the :ls command
local function get_buffer_count()
  local buffers = vim.fn.execute("ls")
  local count = 0
  -- Match only lines that represent buffers, typically starting with a number followed by a space
  for line in string.gmatch(buffers, "[^\r\n]+") do
    if string.match(line, "^%s*%d+") then
      count = count + 1
    end
  end
  return count
end
-- Function to update the winbar
local function update_winbar()
  local home_replaced = get_winbar_path()
  local buffer_count = get_buffer_count()
  vim.opt.winbar = "%#WinBar1#%m "
    .. "%#WinBar2#("
    .. buffer_count
    .. ") "
    .. "%#WinBar1#"
    .. home_replaced
    .. "%*%=%#WinBar2#"
    .. vim.fn.systemlist("hostname")[1]
end
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = update_winbar,
})
