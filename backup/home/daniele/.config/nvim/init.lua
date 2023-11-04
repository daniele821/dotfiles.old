-- vim config
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.cmd [[ 
    autocmd BufEnter * set formatoptions-=cro
    autocmd BufEnter * setlocal formatoptions-=cro 
]]



-- keybindings config
vim.keymap.set('t','<ESC>','<C-\\><C-n>',{})                -- exit terminal mode with 
vim.keymap.set('n','<Leader>','<NOP>',{})                   -- disable leader key in normal mode
local builtin = require('telescope.builtin')    
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})   -- telescope find files
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})    -- telescope grep files
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})      -- telescope find buffers
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})    -- telescope neovim help



-- plugin configs 
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    -- insert new plugins here, separatedd by a newline (to allow easy movement with '{,}' vim shortcuts

    -- one dark 
    use 'navarasu/onedark.nvim'
    require('onedark').setup {
        style = 'dark',
    }
    require('onedark').load()

    --lualine 
    use {
        'nvim-lualine/lualine.nvim',
        -- probably the next line would be necessary without a nerd font? idk
        -- requires = { 'nvim-tree/nvim-web-devicons', opt = true } 
    }
    require('lualine').setup()

    -- gitsigns
    -- TODO (maybe): add keybindings to move to previous/next git change
    use 'lewis6991/gitsigns.nvim'
    require('gitsigns').setup()

    -- comments
    use 'numToStr/Comment.nvim'
    require('Comment').setup()

    -- telescope
    use {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x', 
        requires = { 'nvim-lua/plenary.nvim' }
    }

    -- tree-sitter
    use {
        "nvim-treesitter/nvim-treesitter",
        build = ':TSUpdate',
    } 
    require('nvim-treesitter.configs').setup {
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'toml', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
        },
    }

    -- packer bootstrap
    if packer_bootstrap then
        require('packer').sync()
    end
end)






