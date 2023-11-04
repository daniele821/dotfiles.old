-- vim config
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.signcolumn = 'yes'


-- plugin configs (Packer)
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

    -- one dark (colorscheme)
    use 'navarasu/onedark.nvim'
    require('onedark').setup {
        style = 'dark',
    }
    require('onedark').load()

    --lualine (status-line)
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    require('lualine').setup()

    -- nim-fugitive (git)
    use 'tpope/vim-fugitive'

    -- packer bootstrap
    if packer_bootstrap then
        require('packer').sync()
    end
end)








