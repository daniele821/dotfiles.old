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
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', {})      -- exit terminal mode with
vim.keymap.set({ 'n', 'v' }, '<Space>', '<NOP>', {}) -- disable leader key in normal mode


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
require('lazy').setup {
    -- one-dark theme
    {
        'navarasu/onedark.nvim',
        lazy = false,
        priority = 1000,
        config = function()
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
    },

    -- lsp configuration
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'folke/neodev.nvim',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            {
                'j-hui/fidget.nvim',
                tag = 'legacy',
                opts = {}
            },
        },
    },

    -- autocompletion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',
            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
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
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, {})
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, {})
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, {})
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, {})


-- config tree-sitter
vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx',
            'javascript', 'typescript', 'vimdoc', 'vim', 'bash', "markdown",
            "java", "gitcommit" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
        },
        modules = {},
        sync_install = false,
        ignore_install = {},
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


-- lsp configuration [[ STOLEN FROM KICKSTARTER.NVIM ]]
local on_attach = function(_, bufnr)
    local nmap = function(keys, func)
        vim.keymap.set('n', keys, func, { buffer = bufnr })
    end
    nmap('<leader>rn', vim.lsp.buf.rename)
    nmap('<leader>ca', vim.lsp.buf.code_action)
    nmap('gd', require('telescope.builtin').lsp_definitions)
    nmap('gr', require('telescope.builtin').lsp_references)
    nmap('gI', require('telescope.builtin').lsp_implementations)
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions)
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols)
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols)
    nmap('<A-i>', vim.lsp.buf.format)
    nmap('K', vim.lsp.buf.hover)
    nmap('<C-k>', vim.lsp.buf.signature_help)
    nmap('gD', vim.lsp.buf.declaration)
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder)
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder)
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)
    vim.api.nvim_buf_create_user_command(bufnr, 'HintsEnable', function(_)
        vim.lsp.inlay_hint(bufnr, true)
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, 'HintsDisable', function(_)
        vim.lsp.inlay_hint(bufnr, false)
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, {})
end
require('mason').setup()
require('mason-lspconfig').setup()
local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- tsserver = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },
    rust_analyzer = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
        },
    },
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = "Disable" },
            telemetry = { enable = false },
        },
    },
}
require('neodev').setup()
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}
mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end,
}
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}
---@diagnostic disable-next-line: missing-fields
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}
