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


