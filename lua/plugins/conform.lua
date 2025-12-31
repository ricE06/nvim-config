
return {
  'stevearc/conform.nvim',
  event = {"BufReadPre", "BufNewFile"},
  config = function()
      local conform = require("conform")
      conform.setup({
          formatters_by_ft = {
              lua = { "stylua" },
              python = { "black" },
              rust = { "rustfmt", lsp_format = "fallback" },
              javascript = { "prettierd", "prettier",},
          },
          -- format_on_save = {
            -- These options will be passed to conform.format()
            -- timeout_ms = 500,
            -- lsp_format = "fallback",
          -- },
      })
  end,
  opts = {},
}
