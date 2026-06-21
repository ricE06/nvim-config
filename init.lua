vim = vim

require("config.lazy")
require("rice")

vim.g.mapleader = " "

-- return to netrw
vim.keymap.set("n", "<leader>pv", ":e %:h <CR>")

-- random options

vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.relativenumber = true

-- QoL keybind mods
vim.keymap.set("n", "<M-d>", "<C-d>zz")
vim.keymap.set("n", "<M-u>", "<C-u>zz")

-- we hate WSL all my homies hate WSL
vim.keymap.set("v", "<M-c>", ":w !clip.exe <CR>")

-- primeagen magic to move stuff around
-- do i understand how it works? no
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- binds for treewalker
vim.api.nvim_set_keymap("n", "<C-j>", ":Treewalker Down<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":Treewalker Up<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", ":Treewalker Left<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", ":Treewalker Right<CR>", { noremap = true })

-- binds for home keyboard without right ctrl
vim.api.nvim_set_keymap("i", "<M-n>", "<C-n>", { noremap = true })
vim.api.nvim_set_keymap("i", "<M-p>", "<C-p>", { noremap = true })
vim.api.nvim_set_keymap("v", "<M-n>", "<C-n>", { noremap = true })
vim.api.nvim_set_keymap("v", "<M-p>", "<C-p>", { noremap = true })

-- for vimgo
vim.g.go_doc_popup_window = 1

-- fix JSDoc indentation
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1167
function _G.javascript_indent()
	local line = vim.fn.getline(vim.v.lnum)
	local prev_line = vim.fn.getline(vim.v.lnum - 1)
	if line:match("^%s*[%*/]%s*") then
		if prev_line:match("^%s*%*%s*") then
			return vim.fn.indent(vim.v.lnum - 1)
		end
		if prev_line:match("^%s*/%*%*%s*$") then
			return vim.fn.indent(vim.v.lnum - 1) + 1
		end
	end

	return vim.fn["GetJavascriptIndent"]()
end

-- vim.cmd[[autocmd FileType javascript setlocal indentexpr=v:lua.javascript_indent()]]

-- make error messages not get cut off

vim.diagnostic.config({
	virtual_text = false, -- Turn off inline diagnostics
})

-- Show all diagnostics on current line in floating window
vim.api.nvim_set_keymap("n", "<Leader>d", ":lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })
-- Go to next diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap("n", "<Leader>n", ":lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
-- Go to prev diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap("n", "<Leader>p", ":lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })

-- stupid patch for rustaceanvim
vim.lsp.config = {
	rust_analyzer = {
		diagnostic = {
			refreshSupport = false,
		},
	},
}

-- prevent rust analyzer from spamming cancelled request notifications
-- https://github.com/neovim/neovim/issues/30985
-- apparently upgrading to 0.11 does not fix it lmao
for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
	local default_diagnostic_handler = vim.lsp.handlers[method]
	vim.lsp.handlers[method] = function(err, result, context, config)
		if err ~= nil and err.code == -32802 then
			return
		end
		return default_diagnostic_handler(err, result, context, config)
	end
end

-- vim.lsp.enable('rust_analyzer')

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.lsp.start({
			name = "rust-analyzer",
			cmd = { "rust-analyzer" },
			root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true })[1]),
		})
	end,
})

-- chatgpt code to keep track of keystrokes for fun

-- File to store the counter
local counter_file = "/home/ezhan/.config/nvim/tmux_keystroke_counter"

local function read_counter_from_file()
	local file = io.open(counter_file, "r")
	if file then
		local value = file:read("*n") -- Read the first number from the file
		file:close()
		return value or 0
	else
		return 0 -- Default to 0 if the file doesn't exist
	end
end

local function write_counter_to_file()
	local file = io.open(counter_file, "w")
	if file then
		file:write(vim.g.char_insert_counter)
		file:close()
	else
		vim.notify("Failed to write counter to file: " .. counter_file, vim.log.levels.ERROR)
	end
end

local function update_tmux_statusline()
	local cmd = string.format(
		'tmux set-option -g status-right "#{window_bell_flag,bell,} %d | %%H:%%M:%%S | %%d-%%b-%%Y"',
		vim.g.char_insert_counter
	)
	-- Run the command asynchronously
	vim.fn.jobstart(cmd, { detach = true })
end

local function increment_char_insert_counter()
	vim.g.char_insert_counter = read_counter_from_file()
	vim.g.char_insert_counter = vim.g.char_insert_counter + 1
	-- Update the statusline with the counter value
	update_tmux_statusline()
	write_counter_to_file()
end

-- Autocmd to call the function on every character insertion
vim.api.nvim_create_autocmd("InsertCharPre", {
	pattern = "*",
	callback = increment_char_insert_counter,
})
