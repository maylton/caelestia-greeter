#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CAELESTIA_GREETER_PREVIEW=1

preview_user="${CAELESTIA_GREETER_USER:-${LUMINA_GREETER_USER:-$(id -un)}}"
export CAELESTIA_GREETER_USER="$preview_user"

passwd_entry="$(getent passwd "$preview_user" || true)"
if [[ -n "$passwd_entry" ]]; then
    IFS=: read -r _ _ _ _ gecos home_dir _ <<<"$passwd_entry"
    display_name="${gecos%%,*}"
    export CAELESTIA_GREETER_DISPLAY_NAME="${CAELESTIA_GREETER_DISPLAY_NAME:-${LUMINA_GREETER_DISPLAY_NAME:-${display_name:-$preview_user}}}"
else
    home_dir="${HOME:-/home/$preview_user}"
    export CAELESTIA_GREETER_DISPLAY_NAME="${CAELESTIA_GREETER_DISPLAY_NAME:-${LUMINA_GREETER_DISPLAY_NAME:-$preview_user}}"
fi

state_dir="${CAELESTIA_GREETER_STATE_DIR:-$home_dir/.local/state/caelestia}"
export CAELESTIA_GREETER_STATE_DIR="$state_dir"

scheme_path="${CAELESTIA_GREETER_SCHEME_PATH:-$state_dir/scheme.json}"
if [[ -f "$scheme_path" && -r "$scheme_path" ]]; then
    export CAELESTIA_GREETER_SCHEME_PATH="$scheme_path"
fi

if [[ -z "${CAELESTIA_GREETER_WALLPAPER:-}" ]]; then
    wallpaper_pointer="$state_dir/wallpaper/path.txt"
    if [[ -r "$wallpaper_pointer" ]]; then
        wallpaper_path="$(head -n 1 "$wallpaper_pointer" | tr -d '\r')"
        if [[ -n "$wallpaper_path" && -f "$wallpaper_path" && -r "$wallpaper_path" ]]; then
            export CAELESTIA_GREETER_WALLPAPER="$wallpaper_path"
        fi
    fi
fi

if [[ -z "${CAELESTIA_GREETER_AVATAR:-}" ]]; then
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
            export CAELESTIA_GREETER_AVATAR="$candidate_path"
            break
        fi
    done
fi

exec qs -p "$project_dir"
