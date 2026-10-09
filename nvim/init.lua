-- Neovim options. Colours are NOT set here: they are generated from your wallpaper (theme.nix).
local o = vim.opt

vim.g.mapleader = " "

o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = "number"
o.signcolumn = "yes"
o.scrolloff = 8
o.wrap = false

o.expandtab = true          -- tabs become spaces
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

o.ignorecase = true         -- search: case-insensitive unless you type a capital
o.smartcase = true
o.hlsearch = true
o.incsearch = true

o.splitright = true
o.splitbelow = true
o.mouse = "a"
o.undofile = true           -- undo survives closing the file
o.clipboard = "unnamedplus" -- yank/paste via the system clipboard (needs xclip, installed)
o.termguicolors = true
o.updatetime = 250
o.laststatus = 2

-- Keys
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File browser (netrw)" })
