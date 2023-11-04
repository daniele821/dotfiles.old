-- vim config
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.opt.completeopt = 'menuone,noselect'
vim.opt.termguicolors = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.cmd [[
    autocmd BufEnter * set formatoptions-=cro
    autocmd BufEnter * setlocal formatoptions-=cro
]]


-- keybindings config
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', {}) -- exit terminal mode with
vim.keymap.set({'n','v'}, '<Space>', '<NOP>', {})    -- disable leader key in normal mode


-- lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- plugins config
require('lazy').setup{
    -- one-dark theme
    {
        'navarasu/onedark.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            style = 'darker'
            vim.cmd.colorscheme 'onedark'
        end
    },

    -- git-signs
    {
        'lewis6991/gitsigns.nvim',
        opts = {},
        lazy = false,
    },

    -- status-line 
    {
        'nvim-lualine/lualine.nvim',
        opts = {},
        lazy = false,
    },
    
    -- comments
    {
        'numToStr/Comment.nvim',
        opts = {},
        lazy = false,
    },

    -- telescope
    {
        'nvim-telescope/telescope.nvim', 
        tag = '0.1.4',
        lazy = false,
        dependencies = { 
            'nvim-lua/plenary.nvim',
            lazy = true,
        }
    },

    -- tree-sitter
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            lazy = false,
        },
    },
}


-- plugin keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})


-- config tree-sitter 
vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
        },
    }
end, 0)


-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})


