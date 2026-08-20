# dotfiles

Personal macOS dotfiles and machine setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start (fresh machine)

Run this in a terminal on a new macOS machine:

```sh
/bin/bash -c "$(curl -fsSL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/tuan-nguyenduc/dotfiles/main/bootstrap.sh)"
```

This installs Xcode Command Line Tools and Homebrew (if missing), clones this repo to `~/dotfiles`, and hands off to `install.sh`.

If Xcode Command Line Tools weren't already installed, the script exits after kicking off the GUI install prompt — just re-run the command above once that finishes.

## Manual install (repo already cloned)

```sh
./install.sh
```

This will:

1. Install all packages listed in `Brewfile` (`brew bundle`).
2. Install `stow` and `tflint` if missing.
3. Install the latest Terraform via `tfenv`, if `tfenv` is present.
4. Symlink the dotfiles below into `$HOME` via `stow`, backing up any existing non-symlink files to `~/.dotfiles-backup/<timestamp>/`.
5. Prompt for your `git user.name` / `user.email` on first run and save them to `~/.gitconfig.local` (not tracked in this repo).

## What's included

| Package | Symlinked to        | Notes                                   |
|---------|----------------------|------------------------------------------|
| `zsh`   | `~/.zshrc`           | Homebrew, starship prompt, direnv, fzf key-bindings, a few aliases |
| `git`   | `~/.gitconfig`       | Sane defaults (rebase on pull, `main` default branch); includes `~/.gitconfig.local` for your identity |

`Brewfile` lists all Homebrew packages/casks installed (CLI tools, Docker/k8s tooling, Terraform tooling, cloud CLIs, Claude Code, VS Code, etc.).

## Re-running / updating

Re-run `./install.sh` any time after pulling changes — it's safe to run repeatedly (`stow -R` re-links, `brew bundle` skips already-installed packages).

```sh
cd ~/dotfiles && git pull --ff-only && ./install.sh
```

## Uninstall a package

```sh
stow -D -t "$HOME" zsh   # or: git
```
