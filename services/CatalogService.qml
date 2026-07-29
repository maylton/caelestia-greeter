pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

Singleton {
    id: root

    property var users: fallbackUsers()
    property var discoveredSessions: []
    property string discoveryError: ""
    readonly property var sessions: mergeSessions(Config.sessions, discoveredSessions)

    readonly property string discoveryScript: `
import configparser
import json
import os
import pwd
import re
import shlex
import shutil
from pathlib import Path


def bool_value(value):
    return str(value or "").strip().lower() in {"1", "true", "yes", "on"}


def login_limits():
    minimum, maximum = 1000, 60000
    try:
        for line in Path("/etc/login.defs").read_text(encoding="utf-8", errors="ignore").splitlines():
            fields = line.split()
            if len(fields) < 2:
                continue
            if fields[0] == "UID_MIN":
                minimum = int(fields[1])
            elif fields[0] == "UID_MAX":
                maximum = int(fields[1])
    except (OSError, ValueError):
        pass
    return minimum, maximum


def accounts_service_values(username):
    values = {}
    path = Path("/var/lib/AccountsService/users") / username
    try:
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            if key in {"RealName", "Icon"}:
                values[key] = value.strip()
    except OSError:
        pass
    return values


def readable_file(path):
    try:
        candidate = Path(path).expanduser()
        return candidate.is_file() and os.access(candidate, os.R_OK)
    except (OSError, TypeError):
        return False


def discover_users():
    uid_min, uid_max = login_limits()
    service_user = os.environ.get("CAELESTIA_GREETER_SERVICE_USER", "greeter")
    result = []

    for account in sorted(pwd.getpwall(), key=lambda item: item.pw_uid):
        if not uid_min <= account.pw_uid <= uid_max:
            continue
        if account.pw_name in {"root", "nobody", service_user}:
            continue
        if account.pw_shell.endswith(("/nologin", "/false")):
            continue

        account_values = accounts_service_values(account.pw_name)
        gecos = account.pw_gecos.split(",", 1)[0].strip()
        display_name = account_values.get("RealName", "").strip() or gecos or account.pw_name
        icon = account_values.get("Icon", "").removeprefix("file://")
        candidates = [
            icon,
            f"/var/lib/AccountsService/icons/{account.pw_name}",
            f"{account.pw_dir}/.face.icon",
            f"{account.pw_dir}/.face",
        ]
        avatar = next((str(Path(path).expanduser()) for path in candidates if path and readable_file(path)), "")

        result.append({
            "username": account.pw_name,
            "displayName": display_name,
            "avatar": avatar,
        })

    return result


def localized_name(entry):
    locale_name = os.environ.get("LC_ALL") or os.environ.get("LC_MESSAGES") or os.environ.get("LANG", "")
    locale_name = locale_name.split(".", 1)[0]
    candidates = []
    if locale_name:
        candidates.append(f"Name[{locale_name}]")
        language = locale_name.split("_", 1)[0]
        if language != locale_name:
            candidates.append(f"Name[{language}]")
    candidates.append("Name")
    for key in candidates:
        value = entry.get(key, "").strip()
        if value:
            return value
    return ""


def clean_exec(value):
    try:
        tokens = shlex.split(value)
    except ValueError:
        return []

    cleaned = []
    field_code = re.compile(r"%[fFuUdDnNickvm]")
    for token in tokens:
        token = token.replace("%%", "%")
        token = field_code.sub("", token)
        if token:
            cleaned.append(token)
    return cleaned


def valid_executable(command, try_exec):
    candidate = try_exec.strip() if try_exec else command[0]
    if not candidate:
        return False
    if candidate.startswith("/"):
        return os.path.isfile(candidate) and os.access(candidate, os.X_OK)
    return shutil.which(candidate) is not None


def discover_sessions():
    directories = [
        (Path("/usr/local/share/wayland-sessions"), "wayland"),
        (Path("/usr/share/wayland-sessions"), "wayland"),
    ]
    if bool_value(os.environ.get("CAELESTIA_GREETER_INCLUDE_X11")):
        directories += [
            (Path("/usr/local/share/xsessions"), "x11"),
            (Path("/usr/share/xsessions"), "x11"),
        ]

    result = []
    seen = set()
    for directory, session_type in directories:
        if not directory.is_dir():
            continue
        for desktop_file in sorted(directory.glob("*.desktop")):
            parser = configparser.ConfigParser(interpolation=None, strict=False)
            parser.optionxform = str
            try:
                parser.read(desktop_file, encoding="utf-8")
                entry = parser["Desktop Entry"]
            except (OSError, KeyError, configparser.Error):
                continue

            if entry.get("Type", "Application") != "Application":
                continue
            if bool_value(entry.get("Hidden")) or bool_value(entry.get("NoDisplay")):
                continue

            name = localized_name(entry)
            command = clean_exec(entry.get("Exec", ""))
            if not name or not command or not valid_executable(command, entry.get("TryExec", "")):
                continue

            identity = tuple(command)
            if identity in seen:
                continue
            seen.add(identity)
            result.append({
                "name": name,
                "command": command,
                "type": session_type,
                "desktopFile": str(desktop_file),
            })

    return result


print(json.dumps({"users": discover_users(), "sessions": discover_sessions()}, ensure_ascii=False))
`

    function fallbackUsers() {
        if (!Config.defaultUser)
            return [];
        return [{
            "username": Config.defaultUser,
            "displayName": Config.displayName || Config.defaultUser,
            "avatar": Config.avatarSource
        }];
    }

    function sourceUrl(path) {
        if (!path || path.startsWith("file:") || path.startsWith("qrc:"))
            return path || "";
        return path.startsWith("/") ? `file://${path}` : path;
    }

    function normaliseUsers(items) {
        if (!Array.isArray(items))
            return fallbackUsers();
        return items.filter(item => item && item.username).map(item => ({
            "username": String(item.username),
            "displayName": String(item.displayName || item.username),
            "avatar": sourceUrl(String(item.avatar || ""))
        }));
    }

    function normaliseSessions(items) {
        if (!Array.isArray(items))
            return [];
        return items.filter(item => item && item.name && Array.isArray(item.command) && item.command.length > 0).map(item => ({
            "name": String(item.name),
            "command": item.command.map(part => String(part)),
            "type": item.type === "x11" ? "x11" : "wayland",
            "desktopFile": String(item.desktopFile || "")
        }));
    }

    function mergeSessions(configured, discovered) {
        const result = [];
        const seen = {};
        const append = item => {
            if (!item || !item.name || !Array.isArray(item.command) || item.command.length === 0)
                return;
            const command = item.command.map(part => String(part));
            const key = JSON.stringify(command);
            if (seen[key])
                return;
            seen[key] = true;
            result.push({
                "name": String(item.name),
                "command": command,
                "type": item.type === "x11" ? "x11" : "wayland",
                "desktopFile": String(item.desktopFile || "")
            });
        };

        if (Array.isArray(configured))
            configured.forEach(append);
        if (Array.isArray(discovered))
            discovered.forEach(append);
        return result;
    }

    function applyDiscovery(text) {
        try {
            const parsed = JSON.parse(text);
            const discoveredUsers = normaliseUsers(parsed.users);
            root.users = discoveredUsers.length > 0 ? discoveredUsers : fallbackUsers();
            root.discoveredSessions = normaliseSessions(parsed.sessions);
            root.discoveryError = "";
        } catch (error) {
            root.users = fallbackUsers();
            root.discoveredSessions = [];
            root.discoveryError = String(error);
            console.warn("Caelestia Greeter: failed to discover users and sessions:", error);
        }
    }

    Process {
        id: discoveryProcess

        running: true
        command: ["/usr/bin/python3", "-c", root.discoveryScript]
        stdout: StdioCollector {
            onStreamFinished: root.applyDiscovery(text)
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim();
                if (message)
                    console.warn("Caelestia Greeter: catalogue discovery warning:", message);
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.users = root.fallbackUsers();
                root.discoveredSessions = [];
                root.discoveryError = `Discovery exited with status ${exitCode}`;
            }
        }
    }
}
