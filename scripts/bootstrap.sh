#!/usr/bin/env bash
#
# bootstrap.sh — link dotfiles into place with GNU Stow, then install plugins.
#
# Symlinking is delegated to GNU Stow. Each top-level directory in the repo root
# is a Stow package (tmux, zsh, nvim); each package mirrors $HOME, so `stow` knows exactly
# where every file should be linked. This script just:
#   1. runs `stow` to create/refresh the symlinks,
#   2. bootstraps tmux (TPM) and Neovim (LazyVim) plugins, which Stow can't do.
# It is meant to set up a fresh system. Re-running is safe: `stow --restow`
# leaves correct links untouched. On a system with pre-existing configs, Stow
# refuses rather than clobbering them — move or delete those files first.
#
set -euo pipefail

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
err()   { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; }

# This script lives in scripts/; the repo root (the Stow directory) is its parent.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Stow packages to link. Add a new tool by creating a directory in the repo root
# that mirrors $HOME (e.g. git/.gitconfig) and appending its name to this list.
PACKAGES=(nvim tmux zsh)

# -----------------------------------------------------------------------------
# Post-link setup
# -----------------------------------------------------------------------------

# Install tmux plugins non-interactively via TPM.
install_tmux_plugins() {
  local tpm_install="$HOME/.tmux/plugins/tpm/bin/install_plugins"
  if [[ -x "$tpm_install" ]]; then
    info "Installing tmux plugins via TPM..."
    "$tpm_install" >/dev/null 2>&1 && info "tmux plugins installed." \
      || warn "Could not install tmux plugins automatically (run <prefix> + I inside tmux)."
  else
    warn "TPM not found; skipping tmux plugin install. Run install.sh first."
  fi
}

# Bootstrap LazyVim and install its plugins headlessly.
install_nvim_plugins() {
  if command -v nvim >/dev/null 2>&1; then
    info "Bootstrapping LazyVim and installing plugins (headless)..."
    nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && info "Neovim plugins installed." \
      || warn "Could not install Neovim plugins automatically (launch nvim to finish)."
  else
    warn "nvim not found; skipping plugin install. Run install.sh first."
  fi
}

# -----------------------------------------------------------------------------
# Link (via Stow) + setup
# -----------------------------------------------------------------------------
main() {
  info "Bootstrapping dotfiles from: $DOTFILES_DIR"

  if ! command -v stow >/dev/null 2>&1; then
    err "GNU Stow is not installed. Run ./scripts/install.sh first (or: sudo apt-get install stow)."
    exit 1
  fi

  # --no-folding: create real directories in the target and symlink only leaf
  # files. This keeps ~/.config and its subdirectories as real directories, so
  # Stow can never "fold" a whole directory into a single symlink and a stray
  # `stow -D` can only ever remove the individual file symlinks it created —
  # never an entire directory or any folder this repo doesn't own.
  info "Linking packages with Stow: ${PACKAGES[*]}"
  stow --dir "$DOTFILES_DIR" --target "$HOME" --no-folding --restow "${PACKAGES[@]}"
  info "Symlinks created."

  install_tmux_plugins
  install_nvim_plugins

  echo
  info "Bootstrap complete!"
  echo
  cat <<'EOF'
Remaining manual steps (cannot be automated):
  - Set your terminal font to "FiraCode Nerd Font".
  - Put any private/host-specific exports in ~/.zshrc.local (not tracked here).
  - Log out / restart your terminal so the zsh login shell takes effect.
EOF
}

main "$@"
