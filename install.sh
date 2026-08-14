#!/usr/bin/env bash
# Run from within the dotfiles repo (bootstrap.sh does this for you):
#   ./install.sh
#
# Installs all Brewfile packages, then symlinks dotfiles into $HOME via GNU Stow.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(zsh git)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

cd "$DOTFILES_DIR"

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Run bootstrap.sh first." >&2
  exit 1
fi

echo "==> Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

if ! command -v stow &>/dev/null; then
  brew install stow
fi

if command -v tfenv &>/dev/null; then
  echo "==> Installing latest terraform via tfenv..."
  tfenv install latest
  tfenv use latest
fi

echo "==> Linking dotfiles with stow..."
for package in "${STOW_PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$package"/}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "    backing up existing $target -> $BACKUP_DIR/$rel"
      mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
    fi
  done < <(find "$package" -type f -print0)

  stow -v -R -t "$HOME" "$package"
done

echo "==> Done. Restart your shell (or run: exec zsh)."
