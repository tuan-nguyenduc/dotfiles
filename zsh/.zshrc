# Managed by dotfiles (stow package: zsh)

if command -v brew &>/dev/null; then
  eval "$(brew shellenv)"
fi

if [[ -d "$(brew --prefix libpq 2>/dev/null)/bin" ]]; then
  export PATH="$(brew --prefix libpq)/bin:$PATH"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

if [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi

alias ll="ls -lah"
alias k="kubectl"
alias tf="terraform"
alias python="python3"
alias pip="pip3"
