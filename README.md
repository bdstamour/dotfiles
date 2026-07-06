# dotfiles

Personal dotfiles for **tmux**, **zsh** (oh-my-zsh + powerlevel10k), and
**neovim** (LazyVim). Tested on Ubuntu (incl. WSL2).

## Contents

Symlinking is handled by [GNU Stow](https://www.gnu.org/software/stow/). Each
top-level directory is a *package* whose layout mirrors `$HOME`, so Stow knows
exactly where every file belongs. To **add a new tool, create a package
directory laid out to mirror `$HOME`** (e.g. `git/.gitconfig`) and add its name
to the `PACKAGES` list in `bootstrap.sh`.

```
.
├── scripts/
│   ├── install.sh          # Install tools + dependencies
│   └── bootstrap.sh        # Stow the packages + install plugins
├── tmux/
│   ├── .tmux.conf                          → ~/.tmux.conf
│   └── .config/tmux/gruvbox-dark.tmuxtheme → ~/.config/tmux/…
├── zsh/
│   ├── .zshrc                              → ~/.zshrc
│   └── .p10k.zsh                           → ~/.p10k.zsh
└── nvim/
    └── .config/nvim/                       → ~/.config/nvim  (LazyVim)
```

## Usage

```bash
# Install tools (incl. stow), plugins, the Fira Code Nerd Font, set zsh as the
# default login shell, then run bootstrap.sh to symlink everything with Stow and
# install tmux + Neovim plugins (meant for a fresh system).
./scripts/install.sh
```

`install.sh` runs `bootstrap.sh` for you at the end. You can also run
`./scripts/bootstrap.sh` on its own any time to (re)link configs and sync plugins.

A `Makefile` provides shortcuts for the common tasks (run `make` to list them):

```bash
make install    # scripts/install.sh (fresh system)
make bootstrap  # scripts/bootstrap.sh (link + install plugins)
make link       # (re)link configs only, via Stow
make unlink     # remove the config symlinks
make dry-run    # preview what Stow would do, changing nothing
```

`bootstrap.sh` wraps Stow, but you can also link a single package by hand. The
`--no-folding` flag keeps `~/.config` and its subdirectories as real directories
(Stow only ever symlinks individual files), so it can never collapse a whole
directory into one symlink or touch folders this repo doesn't own:

```bash
# run these from the repo root (the Stow directory)
stow --target ~ --no-folding nvim      # (re)link just the nvim package
stow --target ~ -D nvim                # unlink it
stow --target ~ -n -v --no-folding nvim  # dry run: preview, change nothing
```

Stow only manages the symlinks it creates — it never deletes files or folders it
doesn't own, so unrelated `~/.config/*` directories are always left untouched.

Remaining manual steps (cannot be automated):

- Set your terminal font to **FiraCode Nerd Font**.
- Put any private/host-specific exports in `~/.zshrc.local` (see [Local
  overrides](#local-overrides)).
- Log out / restart your terminal so the zsh login shell takes effect.

## What gets installed

| Tool     | Details                                                                       |
| -------- | ---------------------------------------------------------------------------- |
| tmux     | via apt; + TPM (git) and a set of sensible plugins                           |
| zsh      | via apt; + oh-my-zsh, powerlevel10k, autosuggestions, syntax-highlighting    |
| neovim   | official stable release into `~/.local`, configured with LazyVim              |
| font     | Fira Code Nerd Font (downloaded from the Nerd Fonts release)                 |
| deps     | via apt: git, curl, wget, unzip, build-essential, ripgrep, fd-find, fzf, stow |

## tmux highlights

- Leader remapped to `Ctrl-a`
- Panes and windows indexed from `1`
- Vim-style pane navigation (`h/j/k/l`) and splits (`v` / `s`)
- Truecolor, focus-events and low escape-time (required for the pi coding agent)
- Mouse support and large scrollback history
- Session persistence via resurrect + continuum (auto-restore on server start)

## zsh plugins

`git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `sudo`,
`docker`, `docker-compose` — with the `powerlevel10k/powerlevel10k` theme.

## Theme

[Gruvbox](https://github.com/ellisonleao/gruvbox.nvim) (dark background, medium
contrast) is applied to:

- **Neovim** — `ellisonleao/gruvbox.nvim` (`nvim/.config/nvim/lua/plugins/colorscheme.lua`).
- **tmux** — hand-rolled statusline in `tmux/.config/tmux/gruvbox-dark.tmuxtheme`.

zsh uses the stock Powerlevel10k lean prompt (`zsh/.p10k.zsh`).

## Local overrides

The tracked `.zshrc` sources `~/.zshrc.local` at the end if it exists:

```zsh
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

Put machine-specific or private exports (tokens, proxies, corporate cert paths)
in `~/.zshrc.local`. It lives in your home directory, **not** this repo, so it is
never tracked. When migrating an existing machine, move those lines out of your
old `~/.zshrc` and remove it before running `bootstrap.sh` (Stow refuses to
overwrite pre-existing files).

## Notes

- `install.sh` is idempotent. It installs a recent stable Neovim into `~/.local`
  (the apt package is often too old for LazyVim) and sets zsh as your default
  login shell (via `chsh`), but never symlinks files.
- The shell change takes effect after you log out and back in (or restart your terminal).
- `bootstrap.sh` is meant for a fresh system: it runs `stow --restow`, so
  re-running is safe and leaves correct symlinks untouched, but Stow refuses to
  overwrite pre-existing real files rather than clobbering them.
- `lazy-lock.json` is intentionally untracked (see `nvim/.config/nvim/.gitignore`),
  so each machine installs the latest plugins rather than pinned versions.
