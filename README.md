# dot-files stow layout

This directory is organized as GNU Stow packages using Stow's `--dotfiles` convention.
Package contents use `dot-*` names in the repository and are mapped back to leading-dot names when stowed.

Packages:

- `git`
- `zsh`
- `nvim`
- `fuzzel`
- `kanshi`
- `mimeapps`
- `niri`
- `noctalia`
- `sway`
- `swaylock`
- `swaync`
- `swayr`
- `visidata`
- `waybar`
- `wezterm`
- `wlogout`
- `yazi`
- `zathura`
- `local-bin`
- `ssh`

Not stowed:

- `_unstowed/ssh`: private keys, `known_hosts`, and other local SSH state
- `_unstowed/nvim-state`: Neovim log and undo history
- `_unstowed/swaylock-local`: backup config
- `_unstowed/zathura-local`: local PDF

First-time setup:

```sh
cd ~/dot-files
stow --dotfiles --adopt --target="$HOME" git zsh nvim fuzzel kanshi mimeapps niri noctalia sway swaylock swaync swayr visidata waybar wezterm wlogout yazi zathura local-bin ssh
```

After that:

```sh
cd ~/dot-files
stow --dotfiles -R --target="$HOME" git zsh nvim fuzzel kanshi mimeapps niri noctalia sway swaylock swaync swayr visidata waybar wezterm wlogout yazi zathura local-bin ssh
```

Helper script:

```sh
cd ~/dot-files
./stow-all.sh --adopt
```

For normal updates:

```sh
cd ~/dot-files
./stow-all.sh
```
