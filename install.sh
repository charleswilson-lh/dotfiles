#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Print banner
print_banner() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════╗"
    echo "║   Dotfiles Bootstrap Installation   ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print step
print_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Ask yes/no question
ask_yes_no() {
    local question=$1
    while true; do
        read -p "$(echo -e ${YELLOW}${question}${NC} [y/n]: )" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Install Nerd Fonts for Powerline support
install_nerd_fonts() {
    if [[ "$(uname)" == "Darwin" ]]; then
        print_step "Installing Nerd Fonts for Powerline support..."

        # Check if font is already installed
        if [[ -f "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" ]]; then
            print_success "Nerd Fonts already installed"
            return
        fi

        # Install via Homebrew cask
        brew tap homebrew/cask-fonts 2>/dev/null || true
        brew install --cask font-meslo-lg-nerd-font 2>/dev/null || true

        print_success "Nerd Fonts installed"
    fi
}

# Setup iTerm2 configuration
setup_iterm2() {
    if [[ "$(uname)" != "Darwin" ]]; then
        return
    fi

    if [[ ! -d "/Applications/iTerm.app" ]]; then
        return
    fi

    print_step "Configuring iTerm2..."

    # Create DynamicProfiles directory if it doesn't exist
    local profiles_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    mkdir -p "$profiles_dir"

    # Copy iTerm2 profile if it exists
    if [[ -f "$SCRIPT_DIR/iterm2-profile.json" ]]; then
        cp "$SCRIPT_DIR/iterm2-profile.json" "$profiles_dir/dotfiles-profile.json"
        print_success "iTerm2 profile installed (select 'Dotfiles - Agnoster' in Profiles)"
    else
        echo -e "${YELLOW}⚠ iTerm2 profile not found, skipping${NC}"
    fi

    # Set as default profile (optional)
    if ask_yes_no "Set 'Dotfiles - Agnoster' as default iTerm2 profile?"; then
        defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "dotfiles-agnoster-profile"
        print_success "iTerm2 default profile updated"
    fi
}

# Setup default shell to zsh
setup_default_shell() {
    # Check if already using zsh
    if [[ "$SHELL" == */zsh ]]; then
        print_success "Default shell is already zsh"
        return
    fi

    if ask_yes_no "Change default shell to zsh?"; then
        print_step "Changing default shell to zsh..."

        # Add zsh to allowed shells if not present
        if ! grep -q "$(which zsh)" /etc/shells; then
            echo "$(which zsh)" | sudo tee -a /etc/shells > /dev/null
        fi

        # Change shell
        chsh -s "$(which zsh)"
        print_success "Default shell changed to zsh (takes effect on next login)"
    else
        echo -e "${YELLOW}Skipped changing default shell${NC}"
    fi
}

# Setup Node.js version with NVM
setup_node_version() {
    if [[ ! -d "$HOME/.nvm" ]]; then
        return
    fi

    # Source NVM for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Check if any Node version is installed
    if command -v node &> /dev/null; then
        print_success "Node.js $(node --version) already installed"
        return
    fi

    if ask_yes_no "Install Node.js LTS version?"; then
        print_step "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        print_success "Node.js LTS installed and set as default"
    else
        echo -e "${YELLOW}Skipped Node.js installation${NC}"
    fi
}

# Prompt to install additional Go tools
setup_go_tools_prompt() {
    if ! command -v go &> /dev/null; then
        return
    fi

    if [[ ! -f "$SCRIPT_DIR/install-go-tools.sh" ]]; then
        return
    fi

    if ask_yes_no "Install additional Go development tools (ginkgo, golangci-lint, etc.)?"; then
        print_step "Installing Go tools..."
        bash "$SCRIPT_DIR/install-go-tools.sh"
    else
        echo -e "${YELLOW}Skipped Go tools installation (you can run ./install-go-tools.sh later)${NC}"
    fi
}

# Main installation
main() {
    print_banner

    # Check if we need to clone the repo first
    if [[ ! -f "$SCRIPT_DIR/Brewfile.common" ]]; then
        print_step "Dotfiles repo not found. Cloning..."

        # Default repo URL - update this with your actual repo URL
        DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/charleswilson-lh/dotfiles.git}"
        DOTFILES_DIR="${HOME}/code/dotfiles"

        # Create code directory if it doesn't exist
        mkdir -p "${HOME}/code"

        if [[ -d "$DOTFILES_DIR" ]]; then
            echo -e "${YELLOW}Directory $DOTFILES_DIR already exists${NC}"
            echo -e "${YELLOW}Pulling latest changes...${NC}"
            cd "$DOTFILES_DIR" && git pull
        else
            git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        fi

        print_success "Dotfiles cloned to $DOTFILES_DIR"

        # Re-execute the script from the cloned location
        echo -e "${YELLOW}Re-running install from ${DOTFILES_DIR}...${NC}\n"
        exec bash "$DOTFILES_DIR/install.sh"
        exit 0
    fi

    OS=$(detect_os)
    echo -e "Detected OS: ${GREEN}${OS}${NC}\n"

    if [[ "$OS" == "unknown" ]]; then
        echo -e "${RED}Error: Unsupported OS${NC}"
        exit 1
    fi

    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        print_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew installed"
    else
        print_success "Homebrew already installed"
    fi

    # Run OS-specific setup
    print_step "Running $OS-specific setup..."
    if [[ -f "$SCRIPT_DIR/${OS}.sh" ]]; then
        if bash "$SCRIPT_DIR/${OS}.sh"; then
            print_success "OS-specific setup complete"
        else
            echo -e "${YELLOW}⚠ Warning: Some OS-specific settings may not have applied${NC}"
            echo -e "${YELLOW}  This is normal and the installation will continue${NC}"
        fi
    else
        echo -e "${YELLOW}No ${OS}.sh found, skipping OS-specific setup${NC}"
    fi

    # Install packages via Brewfile
    print_step "Installing packages from Brewfile..."
    cd "$SCRIPT_DIR"

    if [[ -f "Brewfile.common" ]]; then
        brew bundle --file=Brewfile.common
    fi

    if [[ -f "Brewfile.${OS}" ]]; then
        brew bundle --file="Brewfile.${OS}"
    fi

    print_success "Packages installed"

    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_step "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_success "Oh My Zsh already installed"
    fi

    # Copy Oh My Zsh custom files
    if [[ -d "$SCRIPT_DIR/oh-my-zsh-custom" ]]; then
        print_step "Setting up Oh My Zsh custom files..."
        cp -r "$SCRIPT_DIR/oh-my-zsh-custom/"* "$HOME/.oh-my-zsh/custom/" 2>/dev/null || true
        print_success "Oh My Zsh custom files set up"
    fi

    # Install NVM (Node Version Manager)
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_step "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        print_success "NVM installed"
    else
        print_success "NVM already installed"
    fi

    # Setup Go directories and tools
    if command -v go &> /dev/null; then
        print_step "Setting up Go workspace..."

        # Create Go workspace directories
        mkdir -p "$HOME/Go/src/github.com"
        mkdir -p "$HOME/.go"

        # Setup Go environment for this session
        export GOPATH="${HOME}/.go"
        export GOROOT="$(brew --prefix golang)/libexec"
        export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"

        # Install basic Go tools
        print_step "Installing Go tools..."
        go install golang.org/x/tools/cmd/godoc@latest

        print_success "Go workspace and tools set up"
    fi

    # Link dotfiles
    print_step "Linking dotfiles..."
    link_dotfile ".zshrc"
    link_dotfile ".zprofile"
    link_dotfile ".gitconfig"
    print_success "Dotfiles linked"

    # Post-installation setup
    echo ""
    print_step "Running post-installation setup..."

    install_nerd_fonts
    setup_iterm2
    setup_default_shell
    setup_node_version
    setup_go_tools_prompt

    # Restart Finder if on macOS and macOS settings were applied
    if [[ "$OS" == "macos" && -f "$SCRIPT_DIR/macos.sh" ]]; then
        print_step "Restarting Finder to apply changes..."
        killall Finder 2>/dev/null || true
        print_success "Finder restarted"
    fi

    print_banner
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "\nTo get started:"
    echo -e "  • Restart your shell: ${YELLOW}exec zsh${NC}"
    echo -e "  • Or open a new terminal window"
    if [[ -d "/Applications/iTerm.app" ]]; then
        echo -e "  • iTerm2: Select the ${YELLOW}Dotfiles - Agnoster${NC} profile in Preferences → Profiles"
    fi
}

# Link dotfile
link_dotfile() {
    local dotfile=$1
    local source="$SCRIPT_DIR/$dotfile"
    local target="$HOME/$dotfile"

    if [[ ! -f "$source" ]]; then
        echo -e "${YELLOW}⚠ $dotfile not found in dotfiles directory, skipping${NC}"
        return
    fi

    if [[ -L "$target" ]]; then
        # Already a symlink, check if it points to the right place
        if [[ "$(readlink "$target")" == "$source" ]]; then
            echo -e "${GREEN}✓ $dotfile already linked${NC}"
            return
        else
            rm "$target"
        fi
    elif [[ -f "$target" ]]; then
        # Backup existing file
        mv "$target" "$target.backup.$(date +%s)"
        echo -e "${YELLOW}⚠ Backed up existing $dotfile${NC}"
    fi

    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Linked $dotfile${NC}"
}

main "$@"
