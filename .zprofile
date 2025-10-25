
# Initialize Homebrew (supports both Intel and Apple Silicon Macs)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

### PATH manipulation for login shells ###

# Add Sublime Text to path (if installed)
if [[ -d "/Applications/Sublime Text.app" ]]; then
  export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
fi

# Add home local bin to path
export PATH="$HOME/.local/bin:$PATH"

# SDKMan init (if installed via Homebrew)
if command -v brew &> /dev/null; then
  export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# JetBrains Toolbox scripts (if installed)
if [[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
  export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Go programming language
if command -v brew &> /dev/null && brew list go &> /dev/null; then
  export GOPATH="${HOME}/.go"
  export GOROOT="$(brew --prefix golang)/libexec"
  export PATH="$PATH:$GOPATH/bin"
  export PATH="$PATH:$GOROOT/bin"
fi

# Add your custom environment variables and PATH modifications below
# Example:
# export MY_CUSTOM_VAR="value"
# export PATH="$PATH:/custom/path"
