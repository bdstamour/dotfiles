-- Gruvbox Material colorscheme (https://github.com/sainnhe/gruvbox-material)
-- A warm, muted retro dark theme.
return {
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      -- Configure before the colorscheme loads.
      vim.g.gruvbox_material_background = "medium" -- soft | medium | hard
      vim.g.gruvbox_material_foreground = "material" -- material | mix | original
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_transparent_background = 0
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
