-- Options are automatically loaded after lazy.nvim configured
-- Set options for text view here

local opt = vim.opt

-- grid marker
vim.cmd([[highlight ColorColumn ctermbg=0 guibg=#323252]])
opt.colorcolumn = "80"

-- fold configs
opt.foldenable = true
opt.foldlevel = 3
opt.foldlevelstart = 3

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
  opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
  opt.foldmethod = "expr"
  opt.foldtext = ""
else
  opt.foldmethod = "indent"
  opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end

-- Options for the LazyVim statuscolumn
vim.g.lazyvim_statuscolumn = {
  folds_open = false, -- show fold sign when fold is open
  folds_githl = false, -- highlight fold sign with git sign color
}
