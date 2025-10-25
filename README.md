# Dotfiles

Personal macOS (and eventually Linux) development environment setup using dotfiles and Homebrew.

## Quick Start

Run this single command to set up everything on a fresh machine:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/charleswilson-lh/dotfiles/main/install.sh)
```

**What this does:**
1. Downloads and runs the install script
2. Detects that dotfiles aren't present locally
3. Automatically clones the repo to `~/code/dotfiles`
4. Re-runs the installation from the cloned location
5. Sets up your entire development environment

Alternatively, you can manually clone first:

```bash
git clone https://github.com/charleswilson-lh/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

**Custom repository URL:**
```bash
DOTFILES_REPO=https://github.com/charleswilson-lh/dotfiles.git bash <(curl -fsSL https://raw.githubusercontent.com/charleswilson-lh/dotfiles/main/install.sh)
```

## What Gets Installed

### Applications & Tools (via Homebrew)

**CLI Tools:**
- Git, GitHub CLI, curl, wget, jq
- Zsh with Oh My Zsh (agnoster theme)
- Shell enhancements: fzf, thefuck, tldr
- Modern Unix replacements: ripgrep, bat, eza, fd
- System monitoring: htop, btop, ncdu, duf
- Development: Go, Node.js, Python, pyenv, NVM, tmux, neovim
- Cloud tools: Terraform, Helm, kubectl, kubectx, cloud-sql-proxy
- Build tools: Gradle, Maven, SDKMan

**macOS Applications:**
- iTerm2 (terminal emulator)
- Sublime Text (text editor)
- Visual Studio Code (with extensions)
- Bruno (API client)
- Rectangle (window manager)
- qlmarkdown (QuickLook plugin for Markdown)
- Firefox, Discord, WhatsApp
- Obsidian, VLC, Steam

### Shell Configuration

**Oh My Zsh:**
- Theme: `agnoster`
- Plugins: git, gh, fzf, kubectl, kubectx, sublime, golang, macos, gradle, npm, node
- Custom aliases and functions in `~/.oh-my-zsh/custom/aliases.zsh`

**Features:**
- Syntax highlighting (via Homebrew)
- Auto-suggestions (via Homebrew)
- Fast keyboard repeat rate
- Custom git helper functions

### macOS System Settings

The `macos.sh` script configures sensible macOS defaults:

- **Finder:**
  - Show all file extensions
  - Show status bar and path bar
  - New windows open to Home directory
  - Home folder added to sidebar
  - List view by default
  - Disable .DS_Store on network drives

- **Dock:**
  - Auto-hide with no delay
  - Fast animations (0.1s for Mission Control, 0.4s for dock)
  - Minimize windows to app icon

- **Keyboard:**
  - Fast key repeat rate
  - Full keyboard access for all controls

- **Screenshots:**
  - Save to `~/Pictures/Screenshots`
  - PNG format, no shadow

- **Safari:**
  - Show full URLs
  - Enable Web Inspector and Develop menu

## File Structure

```
dotfiles/
├── install.sh              # Main bootstrap script
├── install-go-tools.sh     # Optional Go tools installer
├── macos.sh                # macOS system settings
├── Brewfile.common         # Cross-platform packages
├── Brewfile.macos          # macOS-specific packages
├── iterm2-profile.json     # iTerm2 Dynamic Profile
├── .zshrc                  # Zsh configuration
├── .zprofile               # Shell environment variables
├── .gitconfig              # Git configuration
├── .gitignore              # Git ignore patterns
├── oh-my-zsh-custom/       # Oh My Zsh custom files
│   └── aliases.zsh         # Custom aliases and functions
├── LICENSE                 # MIT License
└── README.md               # This file
```

## Customization


### After Installation

- **Custom aliases:** Edit `~/.oh-my-zsh/custom/aliases.zsh`
- **Environment variables:** Add to `~/.zprofile`
- **Zsh plugins:** Edit the `plugins=()` line in `~/.zshrc`
- **Change theme:** Edit `ZSH_THEME` in `~/.zshrc`

## What the Script Does

1. **Detects OS** (macOS or Linux)
2. **Clones repository** (if running via curl from remote)
3. **Installs Homebrew** (if not present)
4. **Installs packages** from Brewfiles
5. **Runs OS-specific setup** (e.g., `macos.sh` for macOS settings)
6. **Installs Oh My Zsh** (if not present)
7. **Copies Oh My Zsh custom files** (aliases, functions)
8. **Installs NVM** (Node Version Manager)
9. **Sets up Go workspace** and installs godoc
10. **Links dotfiles** to home directory (creates symlinks)
11. **Installs Nerd Fonts** for Powerline/agnoster theme support
12. **Configures iTerm2** (font, colors)
13. **Prompts for optional setup** (default shell, Node.js, Go tools)
14. **Restarts Finder** to apply macOS settings

### Idempotency

The script is designed to be idempotent - you can run it multiple times safely:
- Existing installations are detected and skipped
- Existing dotfiles are backed up before being replaced
- Homebrew handles package updates gracefully

## Post-Installation

### What Happens Automatically

The install script will **automatically** handle:
- ✅ Installing Nerd Fonts (MesloLGS NF) for Powerline support
- ✅ Installing iTerm2 Dynamic Profile with proper font and colors for agnoster theme
- ✅ Restarting Finder to apply macOS settings

The install script will **prompt you** for:
- 🔔 Setting iTerm2 default profile to "Dotfiles - Agnoster"
- 🔔 Changing default shell to Zsh (requires password)
- 🔔 Installing Node.js LTS version via NVM
- 🔔 Installing additional Go development tools

### Remaining Manual Steps

After installation completes:

1. **Restart your terminal** or run:
   ```bash
   exec zsh
   ```

2. **For iTerm2 users:**
   - A new profile called "Dotfiles - Agnoster" is automatically installed
   - If you chose not to set it as default, you can select it via: iTerm2 → Preferences → Profiles
   - The profile includes:
     - MesloLGS NF font (size 13)
     - Colors optimized for agnoster theme
     - Proper Powerline character rendering

3. **Sign in to applications:**
   - VS Code: Sign in to Settings Sync
   - GitHub CLI: `gh auth login`
   - Cloud providers (GCP, AWS, etc.)

4. **Optional - Install Go tools later** (if you skipped the prompt):
   ```bash
   cd ~/code/dotfiles
   ./install-go-tools.sh
   ```

## Updating

To update your setup:

```bash
cd ~/code/dotfiles
git pull
./install.sh
```

Homebrew will update outdated packages automatically.

## Cross-Platform Support

This setup is designed to work on both macOS and Linux:
- `Brewfile.common` - Packages available on all platforms
- `Brewfile.macos` - macOS-specific packages and casks
- `Brewfile.linux` - Linux-specific packages (to be added)
- `macos.sh` - macOS system settings
- `linux.sh` - Linux system settings (to be added)

## Useful Aliases & Functions

Included in `oh-my-zsh-custom/aliases.zsh`:

- `git-prune-gone` - Delete local branches that have been deleted remotely
- `git-prune-gone-force` - Force delete local branches that have been deleted remotely
- `gfaf` - Git fetch all with tags and force
- `python` - Alias to `python3`

## Troubleshooting

**Oh My Zsh theme not displaying correctly:**
- Install a Powerline-compatible font (e.g., [Meslo LG](https://github.com/powerline/fonts))
- Set the font in your terminal preferences

**Homebrew not found after installation:**
- Run: `eval "$(/opt/homebrew/bin/brew shellenv)"`
- Or restart your terminal

**Permission denied on scripts:**
- Make them executable: `chmod +x install.sh macos.sh`

**NVM not found:**
- Restart your shell: `exec zsh`

## Resources

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Oh My Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)
- [Oh My Zsh Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- [NVM](https://github.com/nvm-sh/nvm)

## Contributing

Feel free to fork this repo and customize it for your own use!

## License

MIT
