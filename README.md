# Caelestia Greeter

A Material Expressive login screen for Caelestia Shell, built with QML, Quickshell, Hyprland and greetd.

## Features

- Caelestia wallpaper and Material 3 colour scheme.
- Caelestia expressive spatial and effect motion curves.
- Stacked and horizontal clock layouts.
- Brazilian Portuguese and English.
- Automatic user, display-name and avatar detection.
- greetd authentication and session launch.
- Multi-monitor rendering.
- Local preview mode.
- Restart and power-off actions.

## Requirements

- Caelestia Shell
- Hyprland
- Quickshell 0.3 or newer
- greetd

## Preview

Run from the repository root:

```bash
./scripts/run-preview.sh
```

Preview mode uses the current user's Caelestia state:

```text
~/.local/state/caelestia/scheme.json
~/.local/state/caelestia/wallpaper/path.txt
```

Useful overrides:

```bash
CAELESTIA_GREETER_CLOCK_LAYOUT=horizontal ./scripts/run-preview.sh
CAELESTIA_GREETER_LANGUAGE=pt-BR ./scripts/run-preview.sh
CAELESTIA_GREETER_USER=user ./scripts/run-preview.sh
CAELESTIA_GREETER_AVATAR=/path/to/avatar.png ./scripts/run-preview.sh
CAELESTIA_GREETER_WALLPAPER=/path/to/wallpaper.jpg ./scripts/run-preview.sh
CAELESTIA_GREETER_SCHEME_PATH=/path/to/scheme.json ./scripts/run-preview.sh
```

## Configuration

Defaults live in `config/defaults.json`:

```json
{
  "clockLayout": "stacked",
  "defaultUser": "",
  "displayName": "",
  "avatar": "",
  "language": "system",
  "loginStartsOpen": true,
  "wallpaper": "caelestia",
  "sessions": [
    {
      "name": "Caelestia",
      "command": ["/usr/local/bin/caelestia-session"]
    }
  ]
}
```

Use `"wallpaper": "caelestia"` to follow the active Caelestia wallpaper.

## Installation

Test preview mode before replacing an existing display manager.

```bash
sudo install -d -m 0755 /etc/xdg/quickshell/caelestia-greeter
sudo cp -a assets components config design i18n services shell.qml \
  /etc/xdg/quickshell/caelestia-greeter/

for script in \
  caelestia-greeter-session \
  caelestia-greeter-run \
  caelestia-greeter-compositor \
  caelestia-greeter-profile-sync \
  caelestia-session
do
  sudo install -Dm755 "scripts/$script" "/usr/local/bin/$script"
done

sudo install -Dm644 packaging/greetd/caelestia-greeter-hyprland.conf \
  /etc/greetd/caelestia-greeter-hyprland.conf
sudo install -Dm644 packaging/greetd/config.toml \
  /etc/greetd/config.toml
sudo install -Dm644 packaging/systemd/greetd-caelestia-greeter.conf \
  /etc/systemd/system/greetd.service.d/caelestia-greeter.conf

sudo systemctl daemon-reload
sudo /usr/local/bin/caelestia-greeter-profile-sync
```

The profile synchronizer copies the selected user's avatar, wallpaper and colour scheme to `/var/cache/caelestia-greeter` and writes `/run/caelestia-greeter/profile.env`.

## Structure

- `components/`: interface components.
- `config/`: defaults and environment overrides.
- `design/`: dynamic theme and motion tokens.
- `i18n/`: translation catalogs.
- `services/`: authentication and power actions.
- `packaging/`: greetd, Hyprland and systemd configuration.
- `scripts/`: preview, synchronization and session launchers.
