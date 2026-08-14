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

if ! command -v tflint &>/dev/null; then
  echo "==> Installing tflint (direct binary download, no third-party tap)..."
  case "$(uname -m)" in
    arm64) tflint_arch="arm64" ;;
    x86_64) tflint_arch="amd64" ;;
    *) echo "    unsupported architecture for tflint: $(uname -m), skipping" >&2; tflint_arch="" ;;
  esac
  if [[ -n "$tflint_arch" ]]; then
    tflint_tmp="$(mktemp -d)"
    tflint_zip="tflint_darwin_${tflint_arch}.zip"
    trap 'rm -rf "$tflint_tmp"' EXIT
    curl -sSLo "$tflint_tmp/$tflint_zip" \
      "https://github.com/terraform-linters/tflint/releases/latest/download/$tflint_zip"
    curl -sSLo "$tflint_tmp/checksums.txt" \
      "https://github.com/terraform-linters/tflint/releases/latest/download/checksums.txt"
    (cd "$tflint_tmp" && grep "$tflint_zip" checksums.txt | shasum -a 256 -c -)
    unzip -q "$tflint_tmp/$tflint_zip" -d "$tflint_tmp"
    install -m 0755 "$tflint_tmp/tflint" "$(brew --prefix)/bin/tflint"
    rm -rf "$tflint_tmp"
    trap - EXIT
  fi
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
