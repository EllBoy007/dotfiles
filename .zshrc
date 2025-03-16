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

# Load starship prompt
# eval "$(starship init zsh)"

# Load oh-my-posh prompt
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.ohmyposh.toml)"
fi