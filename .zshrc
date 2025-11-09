# Minimal environment detection (built-in tools only)
OS="$(uname -s)"
case "$OS" in
  Darwin)
    export PATH="$PATH:/Users/ryan/Library/Python/3.9/bin"
    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
    ;;
  Linux)
    export PATH="$PATH:/home/ryan/.local/bin"
    ;;
  Windows_NT)
    echo "Windows"
    ;;
  *)
    echo "Unsupported OS"
    ;;
esac

# Core completion support
autoload -Uz compinit && compinit

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History configuration
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory \
  hist_ignore_space hist_ignore_all_dups \
  hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Prompt setup (agnoster-inspired without external deps)
setopt prompt_subst
autoload -U colors && colors  # gives $fg[...] vars
POWERLINE_LEFT=$'\uE0B0'
PROMPT_LAST_ARROW_COLOR="%{$fg[magenta]%}"
GITHUB_ICON=$'\uF09B'
PUSH_ICON=$'⇡'
PULL_ICON=$'⇣'

prompt_segment() {
  local bg="$1" fg="$2" text="$3"
  printf "%s%s %s%s" "%{$bg%}" "%{$fg%}" "$text" "%{$reset_color%}"
}

prompt_git() {
  local branch status_ab ahead_token behind_token ahead behind arrows text
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || { PROMPT_GIT_SEGMENT=""; return 1; }
  PROMPT_GIT_SEGMENT=""
  PROMPT_GIT_SEGMENT+="%{$bg[green]%}%{$fg[magenta]%}$POWERLINE_LEFT%{$reset_color%}"

  status_ab=$(git status --porcelain=2 --branch 2>/dev/null | grep '^# branch.ab' | head -n1)
  if [[ -n "$status_ab" ]]; then
    IFS=' ' read -r _ _ ahead_token behind_token <<< "$status_ab"
    [[ "$ahead_token" == "+0" ]] && ahead_token=""
    [[ "$behind_token" == "-0" ]] && behind_token=""
    [[ -n "$ahead_token" ]] && ahead="${ahead_token#+}"
    [[ -n "$behind_token" ]] && behind="${behind_token#-}"
  fi

  if [[ -n "$ahead" || -n "$behind" ]]; then
    if [[ -n "$ahead" ]]; then
      arrows+="$PUSH_ICON$ahead"
    fi
    if [[ -n "$behind" ]]; then
      arrows+="$PULL_ICON$behind"
    fi
  fi

  text="$GITHUB_ICON $branch"
  [[ -n "$arrows" ]] && text+=" $arrows"
  PROMPT_GIT_SEGMENT+=$(prompt_segment $bg[green] $fg[black] "$text")
  PROMPT_LAST_ARROW_COLOR="%{$fg[green]%}"
  return 0
}

build_prompt() {
  local prompt_text="" show_identity=1
  local current_user="${USER:-}"
  local current_host="${HOST:-}"
  current_host="${current_host%%.*}"
  [[ -z "$current_host" ]] && current_host=$(hostname -s 2>/dev/null)

  if [[ "$current_user" == "ryan" && "$current_host" == "MacBookAir" ]]; then
    show_identity=0
  fi

  PROMPT_LAST_ARROW_COLOR="%{$fg[magenta]%}"
  if (( show_identity )); then
    prompt_text+=$(prompt_segment $bg[blue] $fg[white] "%n@%m")
    prompt_text+="%{$bg[magenta]%}%{$fg[blue]%}$POWERLINE_LEFT%{$reset_color%}"
  fi
  prompt_text+=$(prompt_segment $bg[magenta] $fg[white] "%~")

  PROMPT_GIT_SEGMENT=""
  if prompt_git; then
    prompt_text+="$PROMPT_GIT_SEGMENT"
  fi

  prompt_text+="${PROMPT_LAST_ARROW_COLOR}$POWERLINE_LEFT%{$reset_color%}"
  printf "%s" "$prompt_text"
}

PROMPT='$(build_prompt) %# '

# ls defaults
export CLICOLOR=1        # tell BSD/macOS ls to use color
export LSCOLORS=GxFxCxDxBxegedabagaced  # optional palette tweak
alias ls='ls -laG'       # -G forces color while keeping your defaults
