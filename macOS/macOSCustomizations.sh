#!/bin/zsh

# Setup Python 3 Path
pythonExists="$(type python)";
if [[ $pythonExists == *"not found"* ]]; then (
    echo "alias python='python3'" >> ~/.zshrc
) fi;

# Install Intel Mono Fonts
fontOut="$(ls ~/Library/Fonts | grep IntelOneMono)";
if [[ $fontOut != *"IntelOneMono"* ]]; then (
    cd /tmp
    curl -L "https://github.com/intel/intel-one-mono/raw/refs/heads/main/fonts/otf.zip" -O
    unzip otf.zip
    cd otf/
    open -b com.apple.FontBook *.otf
) fi;

# Disable lock on Touch ID press
defaults write com.apple.loginwindow DisableScreenLockImmediate -bool yes

# Use Touch ID for Sudo
sudo sh ./enableTouchIdForSudo.sh