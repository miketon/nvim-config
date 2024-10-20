return {
  "folke/todo-comments.nvim",
  opts = {
    merge_keywords = true,
    keywords = {
      -- explain like I'm 5
      ELI5 = {
        icon = "👶", -- 󰹼 or 👶 if an emoji is more preferable
        color = "info",
        alt = { "IAM5" },
      },
      -- clown world
      OOOF = {
        icon = "🤡",
        color = "info",
        alt = { "CLOWN" },
      },
    },
  },
}
