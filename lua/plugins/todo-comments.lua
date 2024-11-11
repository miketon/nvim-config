return {
  "folke/todo-comments.nvim",
  opts = {
    merge_keywords = true,
    keywords = {
      -- Table of key concepts, core data structures, and important patterns
      TABLE = {
        icon = "🔑",
        color = "hint",
        alt = {
          "KEY", -- key concept
          "ARCH", -- architectural note
          "CONCEPT", -- core concept
        },
      },
      -- explain like I'm 5
      ELI5 = {
        icon = "👶", -- 󰹼 or 👶 if an emoji is more preferable
        color = "hint",
        alt = { "IAM5" },
      },
      -- clown world
      OOOF = {
        icon = "🤡",
        color = "hint",
        alt = { "CLOWN" },
      },
    },
  },
}
