return {
  "nvim-telescope/telescope-frecency.nvim",
  -- NOTE: this key gets overwritten so we duplicate in lua/after/
  -- TODO-ok: find out why this is
  -- - instead of using ff, we are just going to use fq
  keys = {
    {
      "<leader>fq",
      function()
        require("telescope").extensions.frecency.frecency({
          workspace = "CWD",
        })
      end,
      desc = "[f]ind fre[q]uently opened",
    },
  },
  config = function()
    require("telescope").setup({
      extensions = {
        frecency = {
          show_scores = true,
          matcher = "fuzzy",
          -- Show the path of the active filter before file paths
          show_filter_column = false,
          path_display = { "filename_first" },
        },
      },
    })
    require("telescope").load_extension("frecency")
  end,
}
