#!/bin/zsh

# Dock - Remove Auto-Hide Delay
defaults write com.apple.dock autohide-delay -float 0
killall Dock

# Disable creating .DS_Store on Network Volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable lock on Touch ID press
defaults write com.apple.loginwindow DisableScreenLockImmediate -bool true

# Apple Mail - Copy email address only, not including contact name
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# App Store - Disable in-app ratings
defaults write com.apple.appstore InAppReviewEnabled -int 0

# TextEdit - Open new document immediately
defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

# Spotlight - Exclude newly mounted volumes (Requires Root)
if [[ $EUID -eq 0 ]]; then
	defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
	killall mds > /dev/null 2>&1
else
	sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
	sudo killall mds > /dev/null 2>&1
fi

# Setup Python 3 Path
if ! command -v python >/dev/null 2>&1; then
    echo "alias python='python3'" >> ~/.zshrc
fi

# Setup Python PIP
if ! command -v pip >/dev/null 2>&1; then
    echo "alias pip='pip3'" >> ~/.zshrc
fi

# Use Touch ID for Sudo
if [[ -f "./enableTouchIdForSudo.sh" ]]; then
    sudo zsh ./enableTouchIdForSudo.sh
fi

# Font Installation Helper
install_font_archive() {
    local url="$1"
    local zip_name="$2"
    local font_pattern="$3"

    # Check if font matching pattern already exists in user fonts directory
    if zsh -c "ls ~/Library/Fonts/${font_pattern} >/dev/null 2>&1"; then
        return 0
    fi

    local temp_dir
    temp_dir=$(mktemp -d /tmp/font_install.XXXXXX)

    curl -sSL "$url" -o "${temp_dir}/${zip_name}"
    unzip -q "${temp_dir}/${zip_name}" -d "$temp_dir"
    
    # Move extracted OTF and TTF files into the user Font directory
    find "$temp_dir" -type f \( -name "*.otf" -o -name "*.ttf" \) -exec cp -f {} ~/Library/Fonts/ \;
    
    rm -rf "$temp_dir"
}

install_font_archive "https://github.com/intel/intel-one-mono/raw/main/fonts/otf.zip" "intel.zip" "*IntelOneMono*"
install_font_archive "https://brailleinstitute.box.com/shared/static/jgwjzchbnlqkrqmm5br27jcy6e3op3w0.zip" "ahm.zip" "*AtkinsonHyperlegibleMono*"
install_font_archive "https://brailleinstitute.box.com/shared/static/waaf5z9gfss6w6tf5118im5hhlwolacc.zip" "aho.zip" "*AtkinsonHyperlegibleNext*"