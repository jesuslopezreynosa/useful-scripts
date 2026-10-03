#!/bin/zsh

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

readonly LOCK_DIR="/tmp/tailscale_shortcut_trigger.lock.d"
readonly SHORTCUT_NAME="Tailscale Exit Node on SSID"
readonly TIMEOUT_SECS=10

# Acquire atomic lock directory to prevent concurrent execution races
if ! mkdir "${LOCK_DIR}" 2>/dev/null; then
    if [[ -d "${LOCK_DIR}" ]]; then
        lock_age=$(($(date +%s) - $(stat -f %m "${LOCK_DIR}" 2>/dev/null || echo 0)))
        if [[ ${lock_age} -gt 60 ]]; then
            rm -rf "${LOCK_DIR}"
            mkdir "${LOCK_DIR}" 2>/dev/null || exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
fi

trap 'rm -rf "${LOCK_DIR}"' EXIT INT TERM

# Run Shortcut with a process watchdog timeout to prevent daemon hanging
(
    /usr/bin/shortcuts run "${SHORTCUT_NAME}" 2>/dev/null
) &
runner_pid=$!

(
    sleep "${TIMEOUT_SECS}"
    if kill -0 "${runner_pid}" 2>/dev/null; then
        kill -9 "${runner_pid}" 2>/dev/null
    fi
) &
watcher_pid=$!

wait "${runner_pid}" 2>/dev/null
kill -9 "${watcher_pid}" 2>/dev/null

exit 0