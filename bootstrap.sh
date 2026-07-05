#!/usr/bin/env bash
#
# bootstrap.sh — symlink dotfiles config into place, then install plugins.
#
# Existing files/directories are backed up to "<file>.bak" before a symlink is
# created. Re-running is safe: correct symlinks are left untouched.
#
set -euo pipefail

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# Absolute path to the directory containing this script (the repo root).
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# link <source> <target>
link() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    warn "Source does not exist, skipping: $src"
    return
  fi

  # Already the correct symlink? Nothing to do.
  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    info "Already linked: $dest"
    return
  fi

  # Back up an existing file/dir/link that is not our symlink.
  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="${dest}.bak"
    warn "Backing up existing $dest -> $backup"
    rm -rf "$backup"
    mv "$dest" "$backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  info "Linked: $dest -> $src"
}

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
# Symlinks + setup
# -----------------------------------------------------------------------------
main() {
  info "Bootstrapping dotfiles from: $DOTFILES_DIR"

  # tmux
  link "$DOTFILES_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link "$DOTFILES_DIR/config/tmux/gruvbox-material-dark.tmuxtheme" "$HOME/.config/tmux/gruvbox-material-dark.tmuxtheme"

  # zsh
  link "$DOTFILES_DIR/config/zsh/.zshrc"   "$HOME/.zshrc"
  link "$DOTFILES_DIR/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

  # neovim (LazyVim) -> ~/.config/nvim
  link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

  install_tmux_plugins
  install_nvim_plugins

  echo
  info "Bootstrap complete!"
  echo
  cat <<'EOF'
Remaining manual steps (cannot be automated):
  - Set your terminal font to "FiraCode Nerd Font".
  - Log out / restart your terminal so the zsh login shell takes effect.
EOF
}

main "$@"
