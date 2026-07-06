return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Chaining executes formatters sequentially
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },
}
