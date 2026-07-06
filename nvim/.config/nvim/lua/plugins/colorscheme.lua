-- Gruvbox colorscheme (https://github.com/ellisonleao/gruvbox.nvim)
-- Dark background with medium (default) contrast.
return {
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    lazy = false,
    priority = 1000,
    opts = {
      contrast = "", -- "hard" | "soft" | ""
      italic = {
        strings = false,
        comments = true,
        operators = false,
        folds = true,
      },
      bold = true,
      transparent_mode = false,
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
