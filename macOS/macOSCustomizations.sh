#!/bin/zsh

# Dock - Remove Auto-Hide Delay
defaults write com.apple.dock autohide-delay -float 0
killall Dock

# Remove window snapping delay (macOS 27.0+)
defaults write com.apple.WindowManager hotzoneDelay -float 0
defaults write com.apple.WindowManager softHotzoneDelay -float 0
killall WindowManager

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

# iWork (Pages, Numbers, Keynote) - Disable Creator Studio Upgrade / Upsell
defaults write -g TSADisableUpdateNotifications -bool yes
defaults write com.apple.iWork.Pages TSADisableUpdateNotifications -bool yes
defaults write com.apple.iWork.Keynote TSADisableUpdateNotifications -bool yes
defaults write com.apple.iWork.Numbers TSADisableUpdateNotifications -bool yes

# Spotlight - Exclude newly mounted volumes (Requires Root)
if [[ $EUID -eq 0 ]]; then
	defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
	killall mds > /dev/null 2>&1
else
	sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
	sudo killall mds > /dev/null 2>&1
fi

# Use Touch ID for Sudo
if [[ -f "./enableTouchIdForSudo.sh" ]]; then
    sudo zsh ./enableTouchIdForSudo.sh
fi

# --- ZSH Configurations ---
ZSHRC="$HOME/.zshrc"

append_if_missing() {
    local line="$1"
    grep -qF "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
}

append_if_missing "export GH_TELEMETRY=false" # Disable GitHub CLI Telemetry
append_if_missing "alias dns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'"   # Alias - Flush DNS
append_if_missing "alias server='python3 -m http.server'"   # Alias - Python HTTP File Server
append_if_missing "alias g32='openssl rand -base64 24'" # Alias - Generate random 32 character
append_if_missing "alias python='python3'"
append_if_missing "alias pip='pip3'"

# --- Simplified Font Installation ---
install_font() {
    local url="$1"
    local font_name="$2"
    
    if ls ~/Library/Fonts/*"${font_name}"* >/dev/null 2>&1; then
        return 0
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    
    curl -sSL "$url" -o "${temp_dir}/font.zip"
    unzip -q "${temp_dir}/font.zip" -d "$temp_dir"
    
    find "$temp_dir" -type f \( -name "*.otf" -o -name "*.ttf" \) -exec cp -f {} ~/Library/Fonts/ \;
    rm -rf "$temp_dir"
}

install_font "https://github.com/intel/intel-one-mono/raw/main/fonts/otf.zip" "IntelOneMono"
install_font "https://brailleinstitute.box.com/shared/static/jgwjzchbnlqkrqmm5br27jcy6e3op3w0.zip" "AtkinsonHyperlegibleMono"
install_font "https://brailleinstitute.box.com/shared/static/waaf5z9gfss6w6tf5118im5hhlwolacc.zip" "AtkinsonHyperlegibleNext"