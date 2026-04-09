export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# "Trusted" SSIDs to disable Exit Node on
trusted_ssids=("Trusted SSID 1" "Trusted SSID 2")

# Set 'current_network' from the first argument passed to the script
current_network='SSID_Name'

# Safety check: If no argument is provided, exit to avoid logic errors
if [[ -z "$current_network" ]]; then
    echo "Error: No network name provided."
    exit 1
fi

# Check if the network has changed
# Using ZSH array search logic for better reliability
if [[ " ${trusted_ssids[(i)$current_network]} " -le ${#trusted_ssids} ]]; then
    # Disable Exit Node
    output=$(tailscale exit-node list)
    if echo "$output" | grep -q "selected"; then
        tailscale set --exit-node=
    fi
else
    # Enable Exit Node
    output=$(tailscale exit-node list)
    if ! echo "$output" | grep -q "selected"; then
        # NOTE: Ensure you are on a Tailscale version that supports 'auto:any'
        tailscale set --exit-node=auto:any 
    else
        exit 0
    fi
fi

exit 0