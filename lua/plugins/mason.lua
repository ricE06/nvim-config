local M = {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'mason-org/mason.nvim', version="^1.0.0",
    },
    {
      'https://github.com/williamboman/mason-lspconfig.nvim',
    },
  },
}

-- Utility
local function on_attach(client, bufnr)
  
  -- Keymaps
  vim.keymap.set('n', '<leader>ca', function()
    local curr_row = vim.api.nvim_win_get_cursor(0)[1]
    vim.lsp.buf.code_action({ ['range'] = { ['start'] = { curr_row, 0 }, ['end'] = { curr_row, 100 } } })
  end, {
    buffer = bufnr,
    desc =
    'the below function should get the code action available on the whole line no matter where are you standing in the line',
  })
  vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, { desc = '[C]ode [F]ormat' })

  -- config : keep diagnostic message in insert mode
  vim.diagnostic.config({ update_in_insert = true })

  -- config : format on save, uncomment next block to enable it

  -- local format_on_save = vim.api.nvim_create_augroup("formatOnSave", { clear = false })

  -- if client.supports_method("textDocument/formatting") then
  -- 	vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  -- 		buffer = bufnr,
  -- 		group = format_on_save,
  -- 		callback = function()
  -- 			vim.lsp.buf.format()
  -- 		end,
  -- 		desc = "Format on save a file with formatting capable attached language server",
  -- 	})
  -- end
end

capabilities = {
    fileOperations = {
        didRename = true,
        willRename = true,
    },
}

function M.config()
  local mason = require 'mason'
  local mason_lspconfig = require 'mason-lspconfig'

  mason.setup()

  mason_lspconfig.setup({
    ensure_installed = { 'lua_ls', 'clangd', 'pyright', 'ts_ls', },
    automatic_enable = true,
  })

  mason_lspconfig.setup_handlers({

    -- Automatically setup any language server
    function(server_name)
        --vim.lsp.enable({server_name})

        require('lspconfig')[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end,
  })
end

return M
