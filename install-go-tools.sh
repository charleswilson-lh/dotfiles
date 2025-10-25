#!/bin/bash

# Optional script to install additional Go development tools
# Run this after install.sh if you want these tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing additional Go tools...${NC}\n"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}Error: Go is not installed. Please run ./install.sh first.${NC}"
    exit 1
fi

# Setup Go environment (if not already set)
if [[ -z "$GOPATH" ]]; then
    export GOPATH="${HOME}/.go"
    echo -e "${YELLOW}Set GOPATH=${GOPATH}${NC}"
fi

if [[ -z "$GOROOT" ]]; then
    export GOROOT="$(brew --prefix golang)/libexec"
    echo -e "${YELLOW}Set GOROOT=${GOROOT}${NC}"
fi

# Add to PATH if not already present
if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
    export PATH="$PATH:$GOPATH/bin"
    echo -e "${YELLOW}Added $GOPATH/bin to PATH${NC}"
fi

if [[ ":$PATH:" != *":$GOROOT/bin:"* ]]; then
    export PATH="$PATH:$GOROOT/bin"
    echo -e "${YELLOW}Added $GOROOT/bin to PATH${NC}"
fi

echo ""

# Array of Go tools to install
declare -a tools=(
    "github.com/onsi/ginkgo/v2/ginkgo@latest"
    "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
    "go.uber.org/mock/mockgen@latest"
    "github.com/swaggo/swag/cmd/swag@latest"
)

# Install each tool
for tool in "${tools[@]}"; do
    echo -e "${YELLOW}▶ Installing ${tool}...${NC}"
    if go install "$tool"; then
        echo -e "${GREEN}✓ Installed ${tool}${NC}"
    else
        echo -e "${RED}✗ Failed to install ${tool}${NC}"
    fi
done

echo -e "\n${GREEN}Go tools installation complete!${NC}"
echo -e "Tools installed to: ${YELLOW}${GOPATH}/bin${NC}"
echo -e "\nAvailable commands:"
echo -e "  • ginkgo - BDD testing framework"
echo -e "  • golangci-lint - Linter aggregator"
echo -e "  • mockgen - Mock generator"
echo -e "  • swag - Swagger documentation generator"
