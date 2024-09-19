return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- extend the existing formatters_by_ft table
      opts.formatters_by_ft.rust = opts.formatters_by_ft or {}
      table.insert(opts.formatters_by_ft.rust, "rustfmt")

      -- extend the existing formatters table
      opts.formatters.rustfmt = {
        -- rustfmt uses a toml config file for it's options
        prepend_args = {
          "--config-path",
          vim.fn.expand("~/.config/nvim/lua/config/rustfmt.toml"),
        },
      }

      return opts
    end,
  },
}
