#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export LUMINA_GREETER_PREVIEW=1

preview_user="${LUMINA_GREETER_USER:-$(id -un)}"
export LUMINA_GREETER_USER="$preview_user"

passwd_entry="$(getent passwd "$preview_user" || true)"
if [[ -n "$passwd_entry" ]]; then
    IFS=: read -r _ _ _ _ gecos home_dir _ <<<"$passwd_entry"
    display_name="${gecos%%,*}"
    export LUMINA_GREETER_DISPLAY_NAME="${LUMINA_GREETER_DISPLAY_NAME:-${display_name:-$preview_user}}"
else
    home_dir="${HOME:-/home/$preview_user}"
    export LUMINA_GREETER_DISPLAY_NAME="${LUMINA_GREETER_DISPLAY_NAME:-$preview_user}"
fi

if [[ -z "${LUMINA_GREETER_AVATAR:-}" ]]; then
    accounts_file="/var/lib/AccountsService/users/$preview_user"
    configured_icon=""
    if [[ -r "$accounts_file" ]]; then
        configured_icon="$(awk -F= '$1 == "Icon" { print substr($0, index($0, "=") + 1); exit }' "$accounts_file")"
    fi

    for candidate in \
        "$configured_icon" \
        "/var/lib/AccountsService/icons/$preview_user" \
        "$home_dir/.face.icon" \
        "$home_dir/.face"; do
        [[ -n "$candidate" ]] || continue
        candidate_path="${candidate#file://}"
        if [[ -f "$candidate_path" && -r "$candidate_path" ]]; then
            export LUMINA_GREETER_AVATAR="$candidate_path"
            break
        fi
    done
fi

exec qs -p "$project_dir"
