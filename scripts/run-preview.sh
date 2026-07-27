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

find_lumina_state_file() {
    local candidate newest="" newest_mtime=0 mtime

    for candidate in \
        "${LUMINA_SHELL_STATE_PATH:-}" \
        "$home_dir"/.local/state/quickshell/by-shell/*/lumina-state.json \
        "$home_dir"/.local/state/quickshell/lumina-shell/lumina-state.json \
        "$home_dir"/.local/state/lumina-shell/lumina-state.json; do
        [[ -n "$candidate" && -f "$candidate" && -r "$candidate" ]] || continue
        mtime="$(stat -c %Y "$candidate" 2>/dev/null || printf '0')"
        if (( mtime >= newest_mtime )); then
            newest="$candidate"
            newest_mtime="$mtime"
        fi
    done

    printf '%s' "$newest"
}

read_lumina_avatar_path() {
    local state_file="$1"

    [[ -n "$state_file" ]] || return

    if command -v python3 >/dev/null 2>&1; then
        python3 - "$state_file" <<'PY'
import json
import pathlib
import sys
import urllib.parse

try:
    with open(sys.argv[1], "r", encoding="utf-8") as handle:
        state = json.load(handle)
except (OSError, ValueError):
    raise SystemExit(0)

if state.get("dashboardUseUserAvatarImage", True) is False:
    raise SystemExit(0)

value = str(state.get("dashboardUserAvatarPath", "") or "").strip()
if not value:
    raise SystemExit(0)

if value.startswith("file:"):
    parsed = urllib.parse.urlparse(value)
    value = urllib.parse.unquote(parsed.path)
else:
    value = urllib.parse.unquote(value)

if value:
    print(str(pathlib.Path(value).expanduser()))
PY
        return
    fi

    sed -n 's/.*"dashboardUserAvatarPath"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
        "$state_file" | head -n 1
}

if [[ -z "${LUMINA_GREETER_AVATAR:-}" ]]; then
    accounts_file="/var/lib/AccountsService/users/$preview_user"
    configured_icon=""
    if [[ -r "$accounts_file" ]]; then
        configured_icon="$(awk -F= '$1 == "Icon" { print substr($0, index($0, "=") + 1); exit }' "$accounts_file")"
    fi

    lumina_state_file="$(find_lumina_state_file)"
    lumina_avatar="$(read_lumina_avatar_path "$lumina_state_file" || true)"

    for candidate in \
        "$configured_icon" \
        "/var/lib/AccountsService/icons/$preview_user" \
        "$home_dir/.face.icon" \
        "$home_dir/.face" \
        "$lumina_avatar"; do
        [[ -n "$candidate" ]] || continue
        candidate_path="${candidate#file://}"
        if [[ -f "$candidate_path" && -r "$candidate_path" ]]; then
            export LUMINA_GREETER_AVATAR="$candidate_path"
            break
        fi
    done
fi

exec qs -p "$project_dir"
