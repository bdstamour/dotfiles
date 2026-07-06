return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true, -- Show dotfiles
          },
          grep = {
            hidden = true, -- Include hidden files in live grep
          },
        },
      },
    },
  },
}
