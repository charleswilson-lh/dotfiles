#!/bin/bash

# macOS System Settings Configuration
# Customize your macOS system settings here

# Colors for output
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Configuring macOS system settings..."

# Function to safely set defaults with error handling
safe_defaults() {
    if ! defaults write "$@" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Warning: Could not set preference for $1${NC}" >&2
        return 1
    fi
    return 0
}

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Close Safari if running (required to modify Safari preferences)
if pgrep -x "Safari" > /dev/null; then
    echo "Closing Safari to apply preferences..."
    osascript -e 'tell application "Safari" to quit' 2>/dev/null || true
    sleep 2
fi

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Finder                                                                      #
###############################################################################

# Set Home as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library 2>/dev/null || echo -e "${YELLOW}⚠ Warning: Could not unhide ~/Library folder${NC}"

# Show the /Volumes folder (requires sudo)
if sudo -n true 2>/dev/null; then
    sudo chflags nohidden /Volumes 2>/dev/null || echo -e "${YELLOW}⚠ Warning: Could not unhide /Volumes folder${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Skipping /Volumes unhide (requires sudo authentication)${NC}"
fi

# Add Home folder to Finder sidebar favorites
sfltool add-item com.apple.LSSharedFileList.FavoriteItems file://${HOME}/ 2>/dev/null || true

###############################################################################
# Dock, Dashboard, and hot corners                                           #
###############################################################################

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 48

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Set the animation speed when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Privacy: don't send search queries to Apple
safe_defaults com.apple.Safari UniversalSearchEnabled -bool false
safe_defaults com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
safe_defaults com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Enable the Develop menu and the Web Inspector in Safari
safe_defaults com.apple.Safari IncludeDevelopMenu -bool true
safe_defaults com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
safe_defaults com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

###############################################################################
# Terminal & iTerm 2                                                          #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit                                                                    #
###############################################################################

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Save screenshots to ~/Pictures/Screenshots
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Done                                                                        #
###############################################################################

echo ""
echo -e "${GREEN}✓ macOS settings configuration complete!${NC}"
echo ""
echo -e "Note: Some changes require a logout/restart to take effect."
echo -e "Finder will be restarted automatically by the install script."
echo ""
if [ -n "$warning_count" ] && [ "$warning_count" -gt 0 ]; then
    echo -e "${YELLOW}Some preferences could not be set (see warnings above)${NC}"
    echo -e "This is normal for certain system preferences that require:"
    echo -e "  • Applications to be closed"
    echo -e "  • Full Disk Access permissions"
    echo -e "  • System Integrity Protection adjustments"
fi
