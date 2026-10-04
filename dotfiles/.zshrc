# Find Homebrew on Apple Silicon or Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# User-installed tools, including global npm packages.
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.local/npm/bin" "$HOME/.cargo/bin" "$HOME/go/bin" $path)
if (( $+commands[brew] )); then
  _dotfiles_brew_prefix=$(brew --prefix)
  path=("$_dotfiles_brew_prefix/opt/rustup/bin" $path)
  fpath=("$_dotfiles_brew_prefix/share/zsh/site-functions" $fpath)
fi

# History and completion.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_SAVE_NO_DUPS
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

alias ll='ls -lah'
alias ..='cd ..'
mkcd() { [[ $# -eq 1 ]] && mkdir -p -- "$1" && cd -- "$1"; }

if [[ -n ${_dotfiles_brew_prefix:-} ]]; then
  [[ -f "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
# Use a font-independent prompt, with no Nerd Font requirement.
export STARSHIP_CONFIG="${${(%):-%N}:A:h}/starship.toml"
(( $+commands[starship] )) && eval "$(starship init zsh)"


# Optional machine-specific settings; keep this file outside the repository.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Syntax highlighting loads after the other widgets.
if [[ -n ${_dotfiles_brew_prefix:-} ]]; then
  [[ -f "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _dotfiles_brew_prefix

# Git aliases
alias gs='git status -sb'
alias ga='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gsw='git switch'