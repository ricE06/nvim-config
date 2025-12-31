vim.cmd [[colorscheme catppuccin-mocha]]
vim.cmd [[set number]]

vim.cmd [[set expandtab]]

vim.keymap.set("n", "<C-_>", function() require('Comment.api').toggle.linewise.current() end, { noremap = true, silent = true })
