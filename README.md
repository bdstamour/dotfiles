# dotfiles

Personal dotfiles for **tmux**, **zsh** (oh-my-zsh + powerlevel10k), and
**neovim** (LazyVim). Tested on Ubuntu (incl. WSL2).

## Contents

```
.
├── install.sh          # Install tools + dependencies
├── bootstrap.sh        # Symlink config files into place
└── config/
    ├── tmux/
    │   ├── .tmux.conf
    │   └── gruvbox-material-dark.tmuxtheme
    ├── zsh/
    │   ├── .zshrc
    │   └── .p10k.zsh
    └── nvim/           # LazyVim configuration
```

## Usage

```bash
# 1. Install tools, plugins, the Fira Code Nerd Font, and set zsh as the
#    default login shell
./install.sh

# 2. Symlink the config files (backs up existing files to *.bak) and
#    install tmux + Neovim plugins automatically
./bootstrap.sh
```

Remaining manual steps (cannot be automated):

- Set your terminal font to **FiraCode Nerd Font**.
- Log out / restart your terminal so the zsh login shell takes effect.

## What gets installed

| Tool     | Details                                                                       |
| -------- | ---------------------------------------------------------------------------- |
| tmux     | via apt; + TPM (git) and a set of sensible plugins                           |
| zsh      | via apt; + oh-my-zsh, powerlevel10k, autosuggestions, syntax-highlighting    |
| neovim   | official stable release into `~/.local`, configured with LazyVim              |
| font     | Fira Code Nerd Font (downloaded from the Nerd Fonts release)                 |
| deps     | via apt: git, curl, wget, unzip, build-essential, ripgrep, fd-find, fzf      |

## tmux highlights

- Leader remapped to `Ctrl-a`
- Panes and windows indexed from `1`
- Vim-style pane navigation (`h/j/k/l`) and splits (`v` / `s`)
- Truecolor, focus-events and low escape-time (required for the pi coding agent)
- Mouse support and large scrollback history

## zsh plugins

`git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `sudo`,
`docker`, `docker-compose` — with the `powerlevel10k/powerlevel10k` theme.

## Theme

[Gruvbox Material](https://github.com/sainnhe/gruvbox-material) (dark, medium
background) is applied to both Neovim (`sainnhe/gruvbox-material`) and tmux
(hand-rolled statusline in `config/tmux/gruvbox-material-dark.tmuxtheme`).

## Notes

- `install.sh` is idempotent. It installs a recent stable Neovim into `~/.local`
  (the apt package is often too old for LazyVim) and sets zsh as your default
  login shell (via `chsh`), but never symlinks files.
- The `.zshrc` only exports `NODE_EXTRA_CA_CERTS` if `~/.certs/…DoD….pem` exists,
  so it is safe on machines without that corporate cert.
- The shell change takes effect after you log out and back in (or restart your terminal).
- `bootstrap.sh` backs up any existing target to `<file>.bak` before linking.
