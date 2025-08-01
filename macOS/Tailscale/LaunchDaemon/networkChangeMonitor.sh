#!/bin/zsh

## Update the list of SSIDs to match (line 18 of this file), these will have the Exit Node turned off when connected
## Run the following
    # sudo mkdir /opt/ts-network-change
    # sudo cp networkChangeMonitor.sh /opt/ts-network-change/.
    # sudo chmod +x /opt/ts-network-change/*
    # sudo chown root:wheel /opt/ts-network-change/*
## Then add Launch Daemon to `/Library/LaunchDaemons/`
    # sudo cp com.local.macos_network_change.plist /Library/LaunchDaemons/.
    # sudo sudo launchctl load -w /Library/LaunchDaemons/com.local.macos_network_change.plist
    ## To remove permanently: sudo sudo launchctl unload -w /Library/LaunchDaemons/com.local.macos_network_change.plist

# Set PATH for the script (Necessary since tailscale may run as local user, and LaunchDaemons run as root)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin/tailscale"

# Networks to use Directly
direct_ssids=("SSID 1" "SSID 2")

# Get the current network name
current_network=$(system_profiler SPAirPortDataType | awk '/Current Network Information:/{getline; gsub(/:/, ""); print $1}' | grep -v "Network")

# Check if the network has changed
if [[ " ${direct_ssids[*]} " == *" $current_network "* ]]; then
    # Disable Exit Node
    output=$(tailscale exit-node list)
    if ! echo "$output" | grep -q "selected"; then
    else
        tailscale set --exit-node=
    fi
else
    # Enable Exit Node
    output=$(tailscale exit-node list)
    if ! echo "$output" | grep -q "selected"; then
        tailscale set --exit-node=auto:any  # Since Tailscale version 1.86.2
    fi
fi

exit 0