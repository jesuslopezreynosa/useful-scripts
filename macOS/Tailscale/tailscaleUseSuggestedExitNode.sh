#!/bin/zsh

output=$(tailscale exit-node list)
if ! echo "$output" | grep -q "selected"; then
    echo "No exit node is selected, continuing...\n\n"

    suggestOutput=$(tailscale exit-node suggest)
    command=$(echo "$suggestOutput" | grep -o 'tailscale set[^.]*' | head -n 1)

    if [ -n "$command" ]; then
        echo "Executing command: $command"
        eval "$command"
    else
        echo "No command found in the response."
    fi
else
    echo "An exit node is selected, exiting..."
    exit 1
fi