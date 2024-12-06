return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      sections = {
        lualine_c = {
          { "navic" },
        },
      },
    }
  end,
  dependencies = {
    "SmiteshP/nvim-navic",
  },
}
