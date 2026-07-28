# Caelestia Greeter

An expressive Wayland greeter adapted for Caelestia Shell, built with QML, Quickshell, Hyprland and greetd.

The interface keeps the centered Material Expressive / Pixel lock-screen composition from the original Lumina Greeter while adopting Caelestia's wallpaper and Material 3 colour scheme.

## Current features

- Centered expressive clock.
- Two clock layouts: stacked (`HH` above `mm`) and horizontal (`HH:mm`).
- Runtime clock-layout toggle.
- Automatic Caelestia wallpaper detection.
- Dynamic Material 3 colours from Caelestia's `scheme.json`.
- Safe fallback palette and bundled wallpaper.
- Automatic local-user, display-name and avatar detection.
- Password authentication through `Quickshell.Services.Greetd`.
- Caelestia / Hyprland session launch through greetd.
- Brazilian Portuguese and English translation catalogs.
- Locale-aware date formatting.
- Multi-monitor rendering; authentication controls remain on the first monitor.
- Safe local preview mode.
- Power-off and reboot actions through systemd.

## Requirements

- Caelestia Shell or a compatible Caelestia state directory.
- Hyprland.
- Quickshell 0.3 or newer, available as `qs`.
- greetd for real authentication.
- A font such as Inter; the system fallback is used when unavailable.

## Local visual test

Run without touching the current display manager:

```bash
git clone https://github.com/maylton/lumina-greeter.git
cd lumina-greeter
git switch feat/caelestia-greeter
./scripts/run-preview.sh
```

Preview mode reads these Caelestia files when available:

```text
~/.local/state/caelestia/scheme.json
~/.local/state/caelestia/wallpaper/path.txt
```

It simulates successful authentication and never starts a desktop session.

Useful overrides:

```bash
CAELESTIA_GREETER_CLOCK_LAYOUT=horizontal ./scripts/run-preview.sh
CAELESTIA_GREETER_LANGUAGE=pt-BR ./scripts/run-preview.sh
CAELESTIA_GREETER_LANGUAGE=en ./scripts/run-preview.sh
CAELESTIA_GREETER_USER=maylton ./scripts/run-preview.sh
CAELESTIA_GREETER_AVATAR=/absolute/path/to/avatar.png ./scripts/run-preview.sh
CAELESTIA_GREETER_WALLPAPER=/absolute/path/to/wallpaper.jpg ./scripts/run-preview.sh
CAELESTIA_GREETER_SCHEME_PATH=/absolute/path/to/scheme.json ./scripts/run-preview.sh
```

The old `LUMINA_GREETER_*` profile and visual overrides remain accepted temporarily for migration.

## Configuration

Edit `config/defaults.json`:

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
      "command": ["/usr/bin/Hyprland"]
    }
  ]
}
```

Use `"wallpaper": "caelestia"` to follow the current Caelestia wallpaper. A normal absolute or project-relative image path is also supported.

## Theme and profile synchronization

The installed greeter normally runs as the restricted `greeter` user. The synchronization helper copies the selected user's avatar, wallpaper and colour scheme to a readable cache:

```bash
sudo install -Dm755 scripts/caelestia-greeter-profile-sync \
  /usr/local/bin/caelestia-greeter-profile-sync
sudo /usr/local/bin/caelestia-greeter-profile-sync
```

The generated profile is stored at:

```text
/run/caelestia-greeter/profile.env
```

Cached visual data is stored under:

```text
/var/cache/caelestia-greeter/
```

Run the synchronization helper again after changing the wallpaper, palette or avatar. A system or user hook can automate this later.

## Experimental greetd installation

Do not replace a working display manager until preview mode has been tested.

```bash
sudo mkdir -p /etc/xdg/quickshell/caelestia-greeter
sudo cp -a . /etc/xdg/quickshell/caelestia-greeter/

sudo install -Dm755 scripts/caelestia-greeter-session \
  /usr/local/bin/caelestia-greeter-session
sudo install -Dm755 scripts/caelestia-greeter-run \
  /usr/local/bin/caelestia-greeter-run
sudo install -Dm755 scripts/caelestia-greeter-compositor \
  /usr/local/bin/caelestia-greeter-compositor
sudo install -Dm755 scripts/caelestia-greeter-profile-sync \
  /usr/local/bin/caelestia-greeter-profile-sync

sudo install -Dm644 packaging/greetd/caelestia-greeter-hyprland.conf \
  /etc/greetd/caelestia-greeter-hyprland.conf
```

After running the profile sync, adapt and install `packaging/greetd/config.toml`. Confirm all paths from a TTY before enabling greetd.

## Architecture

- `components/`: visual and interaction components.
- `config/`: validated defaults, environment overrides and Caelestia state paths.
- `design/`: dynamic Material 3 theme bridge.
- `i18n/`: locale detection and translation catalogs.
- `services/`: greetd authentication and system actions.
- `packaging/greetd/`: greetd and minimal Hyprland configuration.
- `scripts/`: preview, profile synchronization and greeter entry points.

## Roadmap

- Discover installed Wayland sessions from desktop files.
- Add keyboard layout, accessibility and network controls.
- Add a language selector to the interface.
- Automate theme synchronization after Caelestia wallpaper changes.
- Package for Arch Linux and other distributions.
