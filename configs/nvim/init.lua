-- Place this in ~/.config/nvim/init.lua

-- Basic Settings
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon", -- softer variant
        transparent = true, -- transparent background
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          sidebars = "dark", -- softer sidebar color
          floats = "dark",
        },
        on_highlights = function(hl, c)
          hl.CursorLine = { bg = c.bg_highlight } -- subtle cursor line
          hl.LineNr = { fg = c.dark5 }            -- less prominent line numbers
          hl.SignColumn = { bg = c.none }         -- transparent sign column
          hl.NormalFloat = { bg = c.bg_dark, blend = 10 } -- softer floats
        end,
      })
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "rust", "python", "javascript", "typescript", "html", "css" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Telescope fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = {
            horizontal = { prompt_position = "top", results_width = 0.8 },
            vertical = { mirror = false },
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
    end,
  },

  -- Mason for LSP management (optional for future use)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Autocompletion (basic setup without LSP for now)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        git = { ignore = false },
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Flash for navigation
  {
    "folke/flash.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Tunnell for REPL integration
  {
    "sourproton/tunnell.nvim",
    config = function()
      require("tunnell").setup({
        cell_header = "# %%",
        tmux_target = "{right-of}",
      })
    end,
  },

  -- Tmux navigation
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require("nvim-tmux-navigation").setup({
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
          last_active = "<C-\\>",
          next = "<C-Space>",
        }
      })
    end,
  },
}

-- Setup plugins
require("lazy").setup(plugins)

-- Key mappings
local keymap = vim.keymap.set

-- General mappings
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })

-- File explorer
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Explorer" })

-- Telescope mappings
keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find text" })
keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })

-- Buffer navigation
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Visual mode mappings
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Tunnell mappings
keymap("n", "<leader>tt", "<cmd>TunnellCell<CR>", { desc = "Tunnell cell" })
keymap("v", "<leader>tt", "<cmd>TunnellRange<CR>", { desc = "Tunnell range" })
keymap("n", "<leader>tc", "<cmd>TunnellConfig<CR>", { desc = "Tunnell config" })

-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = "%s/\\s\\+$//e",
})
