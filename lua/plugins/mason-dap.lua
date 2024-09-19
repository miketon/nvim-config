return {
  "jay-babu/mason-nvim-dap.nvim",
  -- Ensure that mason installs the codelldb adapter
  opts = {
    ensure_installed = { "codelldb" },
  },
}
