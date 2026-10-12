#!/bin/zsh

# 1 October 2026: Updated to ensure root permission & to use regex to handle whitespacing
# 5 April 2024: Originally obtained from: https://medium.com/@laclementine/commandes-sudo-terminal-avec-touch-id-223e329f9e88

# This script is designed to enable Touch ID authentication for sudo on macOS Sonoma 
# 14.x and later. It does this by copying the template file /etc/pam.d/sudo_local.template
# to /etc/pam.d/sudo_local.
#
# If /etc/pam.d/sudo_local already exists, the existing file is backed up prior to modification.

# Script Constants
readonly MIN_MACOS_VERSION=14
readonly TOUCH_ID_TEMPLATE_FILE="/etc/pam.d/sudo_local.template"
readonly TOUCH_ID_AUTH_FILE="/etc/pam.d/sudo_local"

# Pre-flight Check: Verify root privileges
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Root privileges required. Please execute this script using sudo." >&2
    exit 1
fi

exitCode=0

os_version=$(sw_vers --productVersion)
os_version_check=$(echo "$os_version" | awk -F. '{print $1}')

# Verify that Mac is running macOS 14.x or later
if [[ "$os_version_check" -ge "$MIN_MACOS_VERSION" ]]; then
    # Verify template file availability
    if [[ ! -f "$TOUCH_ID_TEMPLATE_FILE" ]]; then
        echo "ERROR: Template file $TOUCH_ID_TEMPLATE_FILE does not exist." >&2
        exit 1
    fi

    # Back up existing file if present
    if [[ -f "$TOUCH_ID_AUTH_FILE" ]]; then
         /bin/mv "$TOUCH_ID_AUTH_FILE" "${TOUCH_ID_AUTH_FILE}_$(date "+%s").bak"
    fi

    # Copy template and enable Touch ID module via Extended Regex
    if [[ ! -f "$TOUCH_ID_AUTH_FILE" ]]; then
         /bin/cp "$TOUCH_ID_TEMPLATE_FILE" "$TOUCH_ID_AUTH_FILE"
         sed -i '' -E 's/^#[[:space:]]*(auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so)/\1/' "$TOUCH_ID_AUTH_FILE"
         /usr/sbin/chown root:wheel "$TOUCH_ID_AUTH_FILE"
         /bin/chmod 555 "$TOUCH_ID_AUTH_FILE"
    else
         echo "ERROR: Failed to enable Touch ID authorization for sudo." >&2
         echo "PROBLEM: $TOUCH_ID_AUTH_FILE exists. New $TOUCH_ID_AUTH_FILE was not able to be created from $TOUCH_ID_TEMPLATE_FILE template file." >&2
         exitCode=1
    fi
else
    # Unsupported macOS version
    echo "This Mac is running $os_version. This script is not able to enable Touch ID authorization for sudo on this macOS version."
    exitCode=1
fi

exit "$exitCode"