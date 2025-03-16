# Detect the OS
OS="$(uname -s)"

if [[ "$OS" == "Darwin" ]]; then # macOS
  export PATH="$PATH:/Users/ryan/Library/Python/3.9/bin"
  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
elif [[ "$OS" == "Linux" ]]; then # linux
  export PATH="$PATH:/home/ryan/.local/bin"
elif [[ "$OS" == "Windows_NT" ]]; then # Windows
  echo "Windows"
else
  echo "Unsupported OS"
fi

# Set the directory we want to share zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit package manager, if it's not there
if [ ! -d $ZINIT_HOME ]; then
  echo "Downloading zinit package manager..."
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

# Load starship prompt
# eval "$(starship init zsh)"

# Load oh-my-posh prompt
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/.ohmyposh.toml)"
fi

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ---- Eza (better ls) -----
alias ls="eza --icons=always -1 -l --color=always --all --group-directories-first --sort=modified --reverse"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)