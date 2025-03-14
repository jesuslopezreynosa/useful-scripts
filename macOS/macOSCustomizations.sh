#!/bin/zsh

# Dock - Remove Auto-Hide Delay
defaults write com.apple.dock autohide-delay -float 0; killall Dock

# Disable creating .DS_Store on Network Volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable lock on Touch ID press
defaults write com.apple.loginwindow DisableScreenLockImmediate -bool yes

# Apple Mail - Copy email address only, not including contact name
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# App Store - Disable in-app ratings
defaults write com.apple.appstore InAppReviewEnabled -int 0

if [[ $EUID -ne 0 ]]; then
	# Not Root 
else 
	# Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed before.
	sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

	# Restart spotlight
	killall mds > /dev/null 2>&1
fi

# Setup Python 3 Path
pythonExists="$(type python)";
if [[ $pythonExists == *"not found"* ]]; then (
    echo "alias python='python3'" >> ~/.zshrc
) fi;

# Setup Python PIP
pipExists="$(type pip)";
if [[ $pipExists == *"not found"* ]]; then (
    echo "alias pip='pip3'" >> ~/.zshrc
) fi;

# Use Touch ID for Sudo
sudo sh ./enableTouchIdForSudo.sh

# Install Intel Mono Fonts
fontOut="$(ls ~/Library/Fonts | grep IntelOneMono)";
if [[ $fontOut != *"IntelOneMono"* ]]; then (
    cd /tmp
    curl -L "https://github.com/intel/intel-one-mono/raw/refs/heads/main/fonts/otf.zip" -O
    unzip otf.zip
    cd otf/
    open -b com.apple.FontBook *.otf
) fi;