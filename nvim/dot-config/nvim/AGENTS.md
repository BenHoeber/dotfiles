# Repository Guidelines

## Project Structure & Module Organization
- Core entrypoint is `init.lua`, which wires `lua/ben/core` and the Lazy plugin loader in `lua/ben/lazy.lua`.
- Editor behavior lives under `lua/ben/core` (options, keymaps, LSP wiring, automated vsplit logic).
- Plugins are declared in `lua/ben/plugins` and locked via `lazy-lock.json`. Add new plugin specs beside the existing files to keep scope small.
- Filetype-specific tweaks belong in `ftplugin/` (e.g., `ftplugin/typst.lua`). Keep per-filetype logic there rather than in global autocommands.

## Build, Test, and Development Commands
- Install/upgrade plugins: `nvim --headless "+Lazy sync" +qa` (installs new specs and respects `lazy-lock.json`).
- Health check: `nvim --headless "+checkhealth" +qa` to confirm tooling (LSP, compilers like Typst) is available.
- Minimal launch for debugging: `nvim --clean -u init.lua` to isolate this config without user after/plugin files.

## Coding Style & Naming Conventions
- Lua files in this repo use 2-space indentation; keep trailing whitespace trimmed. Runtime options set `tabstop/shiftwidth=4` for edited buffers, but the config itself stays 2 spaces for consistency.
- Prefer single quotes in Lua tables and require paths (`require 'ben.core'`).
- Place new modules under the `ben.core.*` or `ben.plugins.*` namespace to mirror existing structure; avoid top-level globals.
- For plugin specs, keep each plugin in its own file when configuration is non-trivial, and add brief inline comments when behavior is non-obvious.

## Testing Guidelines
- Smoke test after changes with `nvim --headless "+Lazy sync" "+checkhealth" +qa` to ensure plugin graph and health pass.
- Manually verify key workflows you touch (e.g., Typst save-to-compile behavior) inside a temporary buffer before pushing changes.
- If adding autocommands, confirm they are buffer-local when appropriate to avoid cross-file side effects.

## Commit & Pull Request Guidelines
- If versioned with Git, prefer concise, action-oriented messages (e.g., `feat: add treesitter context config`, `fix: guard typst compile errors`). Group related config updates into a single commit.
- Pull requests should include: a short summary of the user-visible change, notes on impacted workflows, and any validation steps you ran (`Lazy sync`, `checkhealth`, manual repro). Add screenshots only when UI-facing plugin changes are involved (statusline, colorscheme previews).

## Security & Configuration Tips
- `lua/ben/core/options.lua` sets `undodir` under `~/.nvim/undodir`; ensure the directory exists and is not world-writable.
- Typst auto-compile relies on the `typst` CLI on `$PATH`; surface errors through the quickfix list is already handled—keep any additions non-blocking and async-friendly.
