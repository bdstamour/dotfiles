#!/usr/bin/env bash
#
# install.sh — install tmux, zsh (oh-my-zsh + powerlevel10k), neovim (LazyVim),
# the Fira Code Nerd Font, and their dependencies.
#
# This script is idempotent: it can be re-run safely. It does NOT change your
# login shell automatically and does NOT symlink any config files — run
# bootstrap.sh for that.
#
set -euo pipefail

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
err()   { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Absolute path to the directory containing this script (scripts/); bootstrap.sh
# is a sibling in the same directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

# -----------------------------------------------------------------------------
# 1. Base dependencies (apt)
# -----------------------------------------------------------------------------
install_base_deps() {
  info "Updating apt and installing base dependencies..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    ca-certificates \
    fontconfig \
    ripgrep \
    fd-find \
    fzf \
    stow \
    xclip
}

# -----------------------------------------------------------------------------
# 2. tmux + TPM (Tmux Plugin Manager)
# -----------------------------------------------------------------------------
install_tmux() {
  info "Installing tmux..."
  $SUDO apt-get install -y tmux

  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    info "TPM already installed, updating..."
    git -C "$tpm_dir" pull --ff-only || warn "Could not update TPM"
  else
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

# -----------------------------------------------------------------------------
# 3. zsh + oh-my-zsh + powerlevel10k + plugins
# -----------------------------------------------------------------------------
install_zsh() {
  info "Installing zsh..."
  $SUDO apt-get install -y zsh

  local omz_dir="$HOME/.oh-my-zsh"
  if [[ -d "$omz_dir" ]]; then
    info "oh-my-zsh already installed."
  else
    info "Installing oh-my-zsh (unattended)..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # powerlevel10k theme
  local p10k_dir="$zsh_custom/themes/powerlevel10k"
  if [[ -d "$p10k_dir" ]]; then
    info "powerlevel10k already installed, updating..."
    git -C "$p10k_dir" pull --ff-only || warn "Could not update powerlevel10k"
  else
    info "Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  fi

  # zsh-autosuggestions
  local autosuggest_dir="$zsh_custom/plugins/zsh-autosuggestions"
  if [[ -d "$autosuggest_dir" ]]; then
    info "zsh-autosuggestions already installed, updating..."
    git -C "$autosuggest_dir" pull --ff-only || warn "Could not update zsh-autosuggestions"
  else
    info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$autosuggest_dir"
  fi

  # zsh-syntax-highlighting
  local syntax_dir="$zsh_custom/plugins/zsh-syntax-highlighting"
  if [[ -d "$syntax_dir" ]]; then
    info "zsh-syntax-highlighting already installed, updating..."
    git -C "$syntax_dir" pull --ff-only || warn "Could not update zsh-syntax-highlighting"
  else
    info "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_dir"
  fi
}

# -----------------------------------------------------------------------------
# 4. Neovim (official stable release into ~/.local)
#
# The apt package is frequently too old for current LazyVim, so we install the
# official pre-built stable release. Idempotent: skips if a recent-enough
# (>= 0.10) nvim is already on PATH.
# -----------------------------------------------------------------------------
nvim_is_recent() {
  command_exists nvim || return 1
  local ver
  ver="$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)"
  local major="${ver%%.*}" minor="${ver##*.}"
  (( major > 0 )) || (( minor >= 10 ))
}

install_neovim() {
  if nvim_is_recent; then
    info "Neovim already up to date: $(nvim --version | head -n1)"
    return
  fi

  local arch asset
  case "$(uname -m)" in
    x86_64)  arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) warn "Unsupported arch $(uname -m); falling back to apt neovim."; $SUDO apt-get install -y neovim; return ;;
  esac
  asset="nvim-linux-${arch}.tar.gz"

  info "Installing latest stable Neovim ($asset) into ~/.local..."
  local url="https://github.com/neovim/neovim/releases/download/stable/${asset}"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/nvim.tar.gz" "$url"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"

  local prefix="$HOME/.local"
  mkdir -p "$prefix/bin"
  # Replace any previous install of this managed copy.
  rm -rf "$prefix/nvim-stable"
  mv "$tmp/${asset%.tar.gz}" "$prefix/nvim-stable"
  ln -sf "$prefix/nvim-stable/bin/nvim" "$prefix/bin/nvim"
  rm -rf "$tmp"

  if ! command_exists nvim; then
    warn "~/.local/bin is not on your PATH yet; open a new shell (the .zshrc adds it)."
  fi
  info "Neovim installed: $("$prefix/bin/nvim" --version | head -n1)"
}

# -----------------------------------------------------------------------------
# 5. Fira Code Nerd Font
# -----------------------------------------------------------------------------
install_font() {
  info "Installing Fira Code Nerd Font..."

  local font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"

  if ls "$font_dir"/FiraCode*Nerd*Font* >/dev/null 2>&1; then
    info "Fira Code Nerd Font already present."
    return
  fi

  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
  local tmp
  tmp="$(mktemp -d)"
  info "Downloading Fira Code Nerd Font..."
  curl -fsSL -o "$tmp/FiraCode.zip" "$url"
  unzip -o "$tmp/FiraCode.zip" -d "$tmp/FiraCode" >/dev/null
  find "$tmp/FiraCode" -name '*.ttf' -exec cp {} "$font_dir/" \;
  rm -rf "$tmp"

  info "Refreshing font cache..."
  fc-cache -f "$font_dir" >/dev/null 2>&1 || true
  info "Fira Code Nerd Font installed. Set it as your terminal font."
}

# -----------------------------------------------------------------------------
# 6. Set zsh as the default login shell
# -----------------------------------------------------------------------------
set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found on PATH; skipping default shell change."
    return
  fi

  # Ensure zsh is a valid login shell.
  if ! grep -qxF "$zsh_path" /etc/shells; then
    info "Registering $zsh_path in /etc/shells..."
    echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null
  fi

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    info "Default shell is already zsh."
    return
  fi

  info "Setting default login shell to zsh..."
  if chsh -s "$zsh_path"; then
    info "Default shell changed to zsh (log out / restart your terminal to apply)."
  else
    warn "Could not change shell automatically. Run manually: chsh -s \"$zsh_path\""
  fi
}

# -----------------------------------------------------------------------------
# 7. Symlink configs + install plugins (via bootstrap.sh)
# -----------------------------------------------------------------------------
run_bootstrap() {
  local bootstrap="$SCRIPT_DIR/bootstrap.sh"
  if [[ ! -x "$bootstrap" ]]; then
    warn "bootstrap.sh not found or not executable; skipping. Run it manually to link configs."
    return
  fi

  # Neovim was installed into ~/.local/bin, which may not be on PATH in this
  # shell yet. Add it so bootstrap.sh can find nvim and sync LazyVim plugins.
  export PATH="$HOME/.local/bin:$PATH"

  info "Running bootstrap.sh to symlink configs and install plugins..."
  # Don't let a Stow conflict (pre-existing configs) abort the whole install;
  # surface it as a warning so the completion message still prints.
  if "$bootstrap"; then
    info "bootstrap.sh completed."
  else
    warn "bootstrap.sh reported errors (e.g. Stow found existing files). Resolve them and re-run ./scripts/bootstrap.sh."
  fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  info "Starting dotfiles installation..."

  # This installer targets Debian/Ubuntu (incl. WSL2). Bail out early with a
  # clear message on other systems rather than failing deep inside apt calls.
  if ! command_exists apt-get; then
    err "apt-get not found — this installer supports Debian/Ubuntu only."
    err "Install the tools listed in the README manually, then run ./scripts/bootstrap.sh."
    exit 1
  fi

  install_base_deps
  install_tmux
  install_zsh
  install_neovim
  install_font
  set_default_shell
  run_bootstrap

  echo
  info "Installation complete!"
  echo
  cat <<'EOF'
Next steps:
  1. Set your terminal font to "FiraCode Nerd Font".
  2. Log out / restart your terminal so the zsh login shell takes effect.

If bootstrap.sh was skipped or hit conflicts above, run ./scripts/bootstrap.sh manually.
EOF
}

main "$@"
