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
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      vim.g.copilot_filetypes = {
        ["*"] = true,
      }

      vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion"
      })
      vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)', { desc = "Accept Copilot word" })
      vim.keymap.set('i', '<C-k>', '<Plug>(copilot-next)', { desc = "Next Copilot suggestion" })
      vim.keymap.set('i', '<C-h>', '<Plug>(copilot-previous)', { desc = "Previous Copilot suggestion" })
      vim.keymap.set('i', '<C-x>', '<Plug>(copilot-dismiss)', { desc = "Dismiss Copilot suggestion" })

      vim.keymap.set('i', '<Tab>', 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion with Tab"
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

  -- Enhanced Git signs with more functionality
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Next git hunk"})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Previous git hunk"})

          -- Actions
          map('n', '<leader>gs', gs.stage_hunk, { desc = "Stage hunk" })
          map('n', '<leader>gr', gs.reset_hunk, { desc = "Reset hunk" })
          map('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Stage hunk" })
          map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Reset hunk" })
          map('n', '<leader>gS', gs.stage_buffer, { desc = "Stage buffer" })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map('n', '<leader>gR', gs.reset_buffer, { desc = "Reset buffer" })
          map('n', '<leader>gp', gs.preview_hunk, { desc = "Preview hunk" })
          map('n', '<leader>gb', function() gs.blame_line{full=true} end, { desc = "Git blame line" })
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = "Toggle git blame" })
          map('n', '<leader>gd', gs.diffthis, { desc = "Git diff this" })
          map('n', '<leader>gD', function() gs.diffthis('~') end, { desc = "Git diff this ~" })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = "Toggle deleted" })

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select git hunk" })
        end
      })
    end,
  },

  -- Fugitive for comprehensive git operations
  {
    "tpope/vim-fugitive",
    config = function()
      -- Git keymaps using Fugitive
      vim.keymap.set("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
      vim.keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
      vim.keymap.set("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git pull" })
      vim.keymap.set("n", "<leader>gf", "<cmd>Git fetch<CR>", { desc = "Git fetch" })
      vim.keymap.set("n", "<leader>gB", "<cmd>Git branch<CR>", { desc = "Git branch" })
      vim.keymap.set("n", "<leader>gL", "<cmd>Git log --oneline<CR>", { desc = "Git log" })
    end,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    config = function()
      local wk = require("which-key")
      wk.setup()

      -- Register your groups
      wk.add({
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>t", group = "tunnell" },
      })
    end,
  },

  -- Flash for navigation
  {
    "folke/flash.nvim",
    keys = {
      -- More intuitive keybindings for Flash
      { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "<leader>J", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "<leader>/", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },

      -- Alternative: use 'm' for motion (doesn't conflict with marks since this is different)
      { "m", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "M", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

      -- Search integration
      { "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Search" },
    },
    config = function()
      require("flash").setup({
        labels = "asdfghjklqwertyuiopzxcvbnm",
        search = {
          multi_window = true,
          forward = true,
          wrap = true,
        },
        jump = {
          jumplist = true,
          pos = "start",
          history = false,
          register = false,
          nohlsearch = false,
        },
        label = {
          uppercase = true,
          exclude = "",
          current = true,
          after = true,
          before = false,
          style = "overlay",
        },
        highlight = {
          backdrop = true,
          matches = true,
          priority = 5000,
          groups = {
            match = "FlashMatch",
            current = "FlashCurrent",
            backdrop = "FlashBackdrop",
            label = "FlashLabel",
          },
        },
        modes = {
          search = {
            enabled = true,
            highlight = { backdrop = false },
            jump = { history = true, register = true, nohlsearch = true },
          },
          char = {
            enabled = true,
            config = function(opts)
              opts.autohide = opts.autohide or (vim.fn.mode(true):find("no") and vim.v.operator == "y")
            end,
            jump = { register = false },
          },
          treesitter = {
            labels = "abcdefghijklmnopqrstuvwxyz",
            jump = { pos = "range" },
            highlight = {
              backdrop = false,
              matches = false,
            },
          },
        },
      })
    end,
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
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
      show_icons = true,
      leader_key = ';',
      buffer_leader_key = 'm',
      statusline = {
        enabled = true,
        icon_closed = "🏹", -- Custom icon when arrow is closed
        icon_open = "🎯",   -- Custom icon when arrow is open
      }
    }
  },
-- OSC Yank for remote clipboard
{
  "ojroques/vim-oscyank",
  lazy = false,
  config = function()
    local function is_ssh()
      return os.getenv("SSH_CONNECTION") or os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
    end

    local function is_tmux()
      return os.getenv("TMUX") ~= nil
    end

    if is_ssh() then
      -- SSH sessions: always use OSC 52
      vim.g.oscyank_term = 'default'
      vim.g.oscyank_silent = false
      vim.g.oscyank_max_length = 100000
      vim.opt.clipboard = ""
      print("SSH detected - using OSC 52")

    elseif is_tmux() then
      -- Local tmux: use system clipboard but keep OSC available
      vim.opt.clipboard = "unnamedplus"
      vim.g.oscyank_term = 'alacritty'
      print("Local tmux detected - using system clipboard + OSC fallback")

    else
      -- Local no tmux: use system clipboard
      vim.opt.clipboard = "unnamedplus"
      print("Local session - using system clipboard")
    end

    -- Manual OSC yank (works in all scenarios)
    vim.keymap.set('v', '<leader>c', function()
      vim.cmd('normal! y')
      local text = vim.fn.getreg('"')
      vim.fn.OSCYank(text)
      print('OSC Yank: Forced copy via OSC 52')
    end, { desc = 'Force copy via OSC 52' })

    vim.keymap.set('n', '<leader>cc', function()
      local line = vim.api.nvim_get_current_line()
      vim.fn.OSCYank(line)
      print('OSC Yank: Forced line copy via OSC 52')
    end, { desc = 'Force line copy via OSC 52' })
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

keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Visual mode mappings
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Tunnell mappings
keymap("n", "<leader>tt", "<cmd>TunnellCell<CR>", { desc = "Tunnell cell" })
keymap("v", "<leader>tt", ":TunnellRange<CR>", { desc = "Tunnell range" })
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
