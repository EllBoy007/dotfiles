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
SIMPLE_ARROW=$'›'
PROMPT_STYLE="${PROMPT_STYLE:-simple}"
PROMPT_LAST_ARROW_COLOR="%{$fg[magenta]%}"
GITHUB_ICON=$'\uF09B'
PUSH_ICON=$'⇡'
PULL_ICON=$'⇣'

if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
  GITHUB_ICON=""
fi

prompt_segment() {
  local bg="$1" fg="$2" text="$3"
  printf "%s%s %s%s" "%{$bg%}" "%{$fg%}" "$text" "%{$reset_color%}"
}

git_prompt_text() {
  local branch status_ab ahead_token behind_token ahead behind arrows text
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
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

  if [[ -n "$GITHUB_ICON" ]]; then
    text="$GITHUB_ICON $branch"
  else
    text="$branch"
  fi
  [[ -n "$arrows" ]] && text+=" $arrows"
  printf "%s" "$text"
  return 0
}

prompt_git() {
  local text
  text=$(git_prompt_text) || { PROMPT_GIT_SEGMENT=""; return 1; }
  PROMPT_GIT_SEGMENT=""
  PROMPT_GIT_SEGMENT+="%{$bg[green]%}%{$fg[magenta]%}$POWERLINE_LEFT%{$reset_color%}"
  PROMPT_GIT_SEGMENT+=$(prompt_segment $bg[green] $fg[black] "$text")
  PROMPT_LAST_ARROW_COLOR="%{$fg[green]%}"
  return 0
}

should_show_identity() {
  local current_user="${USER:-}"
  local current_host="${HOST:-}"
  current_host="${current_host%%.*}"
  [[ -z "$current_host" ]] && current_host=$(hostname -s 2>/dev/null)

  if [[ "$current_user" == "ryan" ]]; then
    return 1
  fi
  return 0
}

build_powerline_prompt() {
  local prompt_text="" show_identity=1

  if should_show_identity; then
    show_identity=1
  else
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

build_simple_prompt() {
  local segments=() text git_text separator='%F{240}▶%f'

  if should_show_identity; then
    segments+=("%F{33}%n@%m%f")
  fi

  segments+=("%F{213}%~%f")

  if git_text=$(git_prompt_text); then
    segments+=("$separator")
    segments+=("%F{40}$git_text%f")
  fi

  local prompt_text="" count=${#segments[@]}
  if (( count > 0 )); then
    prompt_text="${segments[1]}"
    local i
    for (( i=2; i<=count; i++ )); do
      prompt_text+=" ${segments[i]}"
    done
  fi
  printf "%s" "$prompt_text"
}

build_prompt() {
  case "$PROMPT_STYLE" in
    simple)
      build_simple_prompt
      ;;
    *)
      build_powerline_prompt
      ;;
  esac
}

promptstyle() {
  local style="$1"
  if [[ "$style" != "simple" && "$style" != "powerline" ]]; then
    echo "Usage: promptstyle [powerline|simple]"
    return 1
  fi
  PROMPT_STYLE="$style"
  if [[ -o interactive ]]; then
    zle reset-prompt 2>/dev/null
  fi
}

PROMPT='$(build_prompt) %# '

# ls defaults 
export CLICOLOR=1        # tell BSD/macOS ls to use color
export LSCOLORS=GxFxCxDxBxegedabagaced  # optional palette tweak
alias ls='ls -laG'       # -G forces color while keeping your defaults
