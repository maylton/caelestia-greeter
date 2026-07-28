#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CAELESTIA_GREETER_PREVIEW=1

user="${CAELESTIA_GREETER_USER:-$(id -un)}"
export CAELESTIA_GREETER_USER="$user"

passwd_entry="$(getent passwd "$user" || true)"
if [[ -n "$passwd_entry" ]]; then
    IFS=: read -r _ _ _ _ gecos home_dir _ <<<"$passwd_entry"
else
    gecos="$user"
    home_dir="${HOME:-/home/$user}"
fi

export CAELESTIA_GREETER_DISPLAY_NAME="${CAELESTIA_GREETER_DISPLAY_NAME:-${gecos%%,*}}"
export CAELESTIA_GREETER_STATE_DIR="${CAELESTIA_GREETER_STATE_DIR:-$home_dir/.local/state/caelestia}"

if [[ -z "${CAELESTIA_GREETER_AVATAR:-}" ]]; then
    accounts_file="/var/lib/AccountsService/users/$user"
    icon=""
    if [[ -r "$accounts_file" ]]; then
        icon="$(awk -F= '$1 == "Icon" { print substr($0, index($0, "=") + 1); exit }' "$accounts_file")"
    fi

    for candidate in \
        "$icon" \
        "/var/lib/AccountsService/icons/$user" \
        "$home_dir/.face.icon" \
        "$home_dir/.face"; do
        candidate="${candidate#file://}"
        if [[ -n "$candidate" && -r "$candidate" && -f "$candidate" ]]; then
            export CAELESTIA_GREETER_AVATAR="$candidate"
            break
        fi
    done
fi

exec qs -p "$project_dir"
