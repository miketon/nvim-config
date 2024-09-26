return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Ensure 'formatters' is initialized as a table
      opts.formatters = opts.formatters or {}

      -- Ensure 'formatters_by_ft' is initialized as a table
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- Rust configuration
      -- rustfmt is the official Rust formatter, ensures consistent code style
      opts.formatters_by_ft.rust = opts.formatters_by_ft.rust or {}
      table.insert(opts.formatters_by_ft.rust, "rustfmt")

      -- Define the configuration for 'rustfmt' without specifying 'config-path'
      opts.formatters.rustfmt = {
        -- Since we're using a global or per-project config, we don't need to specify 'prepend_args'
        -- NOTE: implicitly points to @lua/config/rustfmt.toml
        args = {},
      }

      -- Prettier configuration
      -- Prettier is a widely used formatter that supports multiple languages
      opts.formatters_by_ft.javascript = { "prettier" }
      opts.formatters_by_ft.typescript = { "prettier" }
      opts.formatters_by_ft.css = { "prettier" }
      opts.formatters_by_ft.html = { "prettier" }
      opts.formatters_by_ft.json = { "prettier" }

      -- Define the configuration for 'prettier'
      opts.formatters.prettier = {
        -- You can add Prettier-specific configuration here if needed
        -- For example:
        -- args = { "--print-width", "100", "--single-quote" },
      }

      -- Markdown configurations
      -- Multiple formatters are used for comprehensive Markdown formatting
      opts.formatters_by_ft.markdown = opts.formatters_by_ft.markdown or {}

      -- The order of formatters is important as each formatter processes the
      -- output of the previous one:
      -- 1. prettier: General formatting (indentation, line wrapping, etc.)
      -- 2. markdown-toc: Generates or updates the table of contents
      -- 3. markdownlint-cli2: Applies linting rules and fixes issues
      -- This order ensures that the TOC is generated after general formatting
      -- but before linting, and that linting rules are applied to the final
      -- formatted content.

      -- general formatting
      table.insert(opts.formatters_by_ft.markdown, "prettier")
      -- Table of contents generation
      table.insert(opts.formatters_by_ft.markdown, "markdown-toc")
      -- Linting and fixing
      table.insert(opts.formatters_by_ft.markdown, "markdownlint-cli2")

      -- Add configurations for markdown-toc and markdownlint-cli2
      opts.formatters["markdown-toc"] = {
        command = "markdown-toc",
        args = { "--no-firsth1" },
        condition = function(_)
          return vim.fn.executable("markdown-toc") == 1
        end,
      }

      opts.formatters["markdownlint-cli2"] = {
        command = "markdownlint-cli2",
        args = { "--fix", "$FILENAME" },
        condition = function(_)
          return vim.fn.executable("markdownlint-cli2") == 1
        end,
      }

      return opts
    end,
  },
}
