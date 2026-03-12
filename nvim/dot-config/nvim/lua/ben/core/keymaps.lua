local keymap = vim.keymap
-- Set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]
--  See `:help keymap.set()`

-- Move normally between wrapped lines
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
--  This is also done in gitsigns
keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Swap
keymap.set({ 'n', 'v' }, '#', '#zz', { noremap = true, silent = true })
keymap.set({ 'n', 'v' }, '*', '*zz', { noremap = true, silent = true })

-- local function fallback_char_search(mode)
--   local char = vim.fn.getcharstr()
--   if char == '' or char == '\027' then
--     return ''
--   end
--
--   local pattern = '\\V' .. vim.fn.escape(char, '\\')
--   local line = vim.fn.line('.')
--   local flags = (mode == 'F' or mode == 'T') and 'nWb' or 'nW'
--   local found = vim.fn.searchpos(pattern, flags, line)
--
--   if found[1] == 0 then
--     if mode == 'f' then
--       return 'F' .. char
--     elseif mode == 't' then
--       return 'T' .. char
--     elseif mode == 'F' then
--       return 'f' .. char
--     end
--     return 't' .. char
--   end
--
--   return mode .. char
-- end
--
-- -- Try the opposite direction when f/t/F/T finds nothing on the current line.
-- keymap.set({ 'n', 'x', 'o' }, 'f', function()
--   return fallback_char_search('f')
-- end, { expr = true, silent = true })
-- keymap.set({ 'n', 'x', 'o' }, 't', function()
--   return fallback_char_search('t')
-- end, { expr = true, silent = true })
-- keymap.set({ 'n', 'x', 'o' }, 'F', function()
--   return fallback_char_search('F')
-- end, { expr = true, silent = true })
-- keymap.set({ 'n', 'x', 'o' }, 'T', function()
--   return fallback_char_search('T')
-- end, { expr = true, silent = true })

-- Visual mode paste without overwriting register
keymap.set({ 'v', 'n' }, '<leader>p', '"+p', { silent = true, desc = 'Paste from system clipboard' })
keymap.set({ 'v', 'n' }, '<leader>P', '"+P', { silent = true, desc = 'Paste from system clipboard' })

-- Delete to black hole register
keymap.set({ 'n', 'v' }, '<leader>d', '"_d')

-- TODO: Maybe remap these to <leader>y
-- Yank and put from System Clipboard
keymap.set({ 'n', 'v' }, 'y', '"+y', { noremap = true })

-- Replace word under cursor
keymap.set({ 'n' }, '<leader>R', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Replace visual selection
vim.keymap.set('x', '<leader>R', [[y:%s/\V<C-r>"/<C-r>"/gI<Left><Left><Left>]], { noremap = true, silent = false })

-- Center cursor in the middle of the screen when half page scrolling
keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
-- Center cursor in the middle of the screen when searching; also unfold any folds
keymap.set('n', 'n', 'nzz', { noremap = true, silent = true })
keymap.set('n', 'N', 'Nzz', { noremap = true, silent = true })

-- Keymaps to move selected text in Visual mode
-- keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
-- keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
-- Now done by mini.move which has some extra functionality

-- Diagnostic keymaps
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Allow to close cmdwin q: by pressing q
vim.api.nvim_create_autocmd('CmdwinEnter', {
  callback = function()
    keymap.set('n', 'q', '<C-c><Esc>', { buffer = true, desc = 'Quit command-line window' })
  end,
})
