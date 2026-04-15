-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
--   vim.opt.clipboard = 'unnamedplus'
-- end)

-- wrap lines
vim.opt.wrap = true
-- wrap at convenient point
vim.opt.linebreak = true
-- Enable break indent
vim.opt.breakindent = true
-- make indentation easier
vim.opt.autoindent = true
-- make Sure Indentation is 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- " Always use spaces insted of tabs
vim.opt.expandtab = true

-- allow backspace to be used on indnet, end of line etc.
vim.opt.backspace = 'indent,eol,start'

local undodir = vim.fn.stdpath 'config' .. '/undo'
vim.fn.mkdir(undodir, 'p')
vim.opt.undodir = undodir
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Make Vim Use better colors
vim.opt.termguicolors = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

--- Sets how neovim will display certain whitespace characters in the editor.- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8

-- [[ Autocommands ]]

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- -- Autocompile typst documents on save
-- vim.api.nvim_create_autocmd('BufWritePost', {
--   pattern = '*.typ',
--   callback = function()
--     local file = vim.fn.expand '%:p'
--     local stderr = {}
--     -- Async Job starten
--     vim.fn.jobstart({ 'typst', 'compile', file }, {
--       on_stderr = function(_, data)
--         for _, line in ipairs(data) do
--           if #line > 0 then
--             table.insert(stderr, line)
--           end
--         end
--       end,
--       on_exit = function(_, exit_code)
--         if exit_code ~= 0 then
--           -- Quickfix-Liste (ersetzt) befüllen
--           vim.fn.setqflist({}, 'r', {
--             title = 'Typst-Fehler: ' .. vim.fn.fnamemodify(file, ':t'),
--             lines = stderr,
--           })
--           -- Quickfix öffnen (öffnet, aber wechselt NICHT automatisch den Fokus)
--           vim.cmd 'copen'
--
--           -- 1) Quickfix-Window suchen
--           local qf_win
--           for _, win in ipairs(vim.api.nvim_list_wins()) do
--             local buf = vim.api.nvim_win_get_buf(win)
--             if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'quickfix' then
--               qf_win = win
--               break
--             end
--           end
--
--           if qf_win then
--             -- 2) Buffer der QF-Window ermitteln
--             local qf_buf = vim.api.nvim_win_get_buf(qf_win)
--             -- 3) Nur in DIESEM Buffer q → cclose mappen
--             vim.api.nvim_buf_set_keymap(qf_buf, 'n', 'q', '<cmd>cclose<CR>',
--               { nowait = true, noremap = true, silent = true })
--           end
--         else
--           vim.notify('Typst: OK', vim.log.levels.INFO, { title = 'Compile' })
--         end
--       end,
--     })
--   end,
-- })

-- Simple helper: does this file exist?
local function file_exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

-- Helper: find "root" Typst file which includes this file (if any),
-- with preference for "bericht.typ" as project root.
local function find_typst_root(current_file)
  current_file = vim.fs.normalize(current_file)

  -- 1) If current file is "bericht.typ", it's definitely the root
  if vim.fn.fnamemodify(current_file, ':t') == 'bericht.typ' then
    vim.b.typst_root = current_file
    return current_file
  end

  -- 2) Reuse cached root if still present
  if vim.b.typst_root and file_exists(vim.b.typst_root) then
    return vim.b.typst_root
  end

  local current_dir = vim.fs.dirname(current_file)

  -- 3) Detect project root via git; fall back to the current dir
  local git_root = vim.fn.systemlist(
    'git -C ' .. vim.fn.shellescape(current_dir) .. ' rev-parse --show-toplevel'
  )[1]

  local root_dir
  if git_root and git_root ~= '' and not git_root:match('fatal') then
    root_dir = git_root
  else
    root_dir = current_dir
  end

  -- 4) If "bericht.typ" exists at the project root, prefer that as root
  local bericht_root = vim.fs.normalize(vim.fs.joinpath(root_dir, 'bericht.typ'))
  if file_exists(bericht_root) then
    vim.b.typst_root = bericht_root
    return bericht_root
  end

  -- 5) Fallback: find all .typ files and look for #include/#import of current_file
  local typ_files = vim.fs.find(function(name, _)
    return name:match('%.typ$')
  end, {
    path = root_dir,
    type = 'file',
    limit = 2000,
  })

  for _, candidate in ipairs(typ_files) do
    candidate = vim.fs.normalize(candidate)
    if candidate ~= current_file then
      local f = io.open(candidate, 'r')
      if f then
        for line in f:lines() do
          local rel = line:match('#%s*include%s*"(.-)"')
              or line:match('#%s*import%s*"(.-)"')
          if rel then
            local abs = vim.fs.normalize(
              vim.fs.joinpath(vim.fs.dirname(candidate), rel)
            )
            if abs == current_file then
              f:close()
              vim.b.typst_root = candidate
              return candidate
            end
          end
        end
        f:close()
      end
    end
  end

  -- 6) No parent found -> this file is the root
  vim.b.typst_root = current_file
  return current_file
end

-- Autocompile typst documents on save
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.typ',
  callback = function()
    local file = vim.fn.expand '%:p'
    local root = find_typst_root(file)

    local stderr = {}
    vim.fn.jobstart({ 'typst', 'compile', root }, {
      on_stderr = function(_, data)
        for _, line in ipairs(data) do
          if #line > 0 then
            table.insert(stderr, line)
          end
        end
      end,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.fn.setqflist({}, 'r', {
            title = 'Typst-Fehler: ' .. vim.fn.fnamemodify(root, ':t'),
            lines = stderr,
          })
          vim.cmd 'copen'

          local qf_win
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'quickfix' then
              qf_win = win
              break
            end
          end

          if qf_win then
            local qf_buf = vim.api.nvim_win_get_buf(qf_win)
            vim.api.nvim_buf_set_keymap(
              qf_buf,
              'n',
              'q',
              '<cmd>cclose<CR>',
              { nowait = true, noremap = true, silent = true }
            )
          end
        else
          vim.notify(
            ('Typst: OK (%s)'):format(vim.fn.fnamemodify(root, ':t')),
            vim.log.levels.INFO,
            { title = 'Compile' }
          )
        end
      end,
    })
  end,
})

-- Change commentstring for typst files: Add commentstring for typst.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typst' },
  callback = function()
    vim.opt.commentstring = '// %s'
  end,
  desc = 'Change commentstring for typst files',
})
-- Show folds
-- vim.opt.foldcoumn = 'auto'
-- vim.opt.foldmethod = 'indent'

-- Needed for obsidian.nvim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "obsidian" },
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})
