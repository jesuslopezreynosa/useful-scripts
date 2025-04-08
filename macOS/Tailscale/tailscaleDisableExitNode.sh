#!/bin/zsh

output=$(tailscale exit-node list)
if ! echo "$output" | grep -q "selected"; then
    echo "No exit node is selected, exiting...\n\n"
    exit 1
else
    echo "An exit node is selected, continuing..."
    tailscale set --exit-node=
fi