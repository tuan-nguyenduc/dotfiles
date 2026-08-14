#!/usr/bin/env bash
# One-command bootstrap for a fresh macOS machine.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tuan-nguyenduc/dotfiles/main/bootstrap.sh)"
#
# Installs Xcode Command Line Tools + Homebrew, clones this repo to
# ~/dotfiles, then hands off to install.sh.

set -euo pipefail

REPO_URL="https://github.com/tuan-nguyenduc/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap only supports macOS." >&2
  exit 1
fi

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools (follow the GUI prompt, then re-run this command)..."
  xcode-select --install
  exit 0
fi

if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "==> Updating existing dotfiles checkout at $DOTFILES_DIR..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo "==> Cloning dotfiles into $DOTFILES_DIR..."
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh"
