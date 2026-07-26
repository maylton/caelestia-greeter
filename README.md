# Lumina Greeter

An expressive Wayland greeter for the Lumina Shell, built with QML, Quickshell and greetd.

The interface takes visual cues from Material Expressive and the centered Pixel lock-screen composition. It includes a centered clock, animated login surface, configurable sessions, multi-monitor rendering and a safe local preview mode.

## Current features

- Centered expressive clock.
- Two clock layouts: stacked (`HH` above `mm`) and horizontal (`HH:mm`).
- Runtime clock-layout toggle.
- JSON and environment-variable configuration.
- Automatic local-user, display-name and avatar detection.
- Login surface open by default with the password field focused.
- System-locale detection with English fallback.
- Brazilian Portuguese and English translation catalogs.
- Locale-aware date formatting.
- Password authentication through `Quickshell.Services.Greetd`.
- Session launch through greetd.
- Preview mode when greetd is unavailable.
- Power-off and reboot actions through systemd.
- One visual surface per monitor; authentication controls remain on the first monitor.

## Requirements

- Wayland compositor with layer-shell support.
- Quickshell 0.3 or newer, available as `qs`.
- greetd for real authentication.
- Niri for the provided greeter compositor example.
- A font such as Inter; the system fallback is used when unavailable.

## Local visual test

Run without touching your current display manager:

```bash
git clone https://github.com/maylton/lumina-greeter.git
cd lumina-greeter
./scripts/run-preview.sh
```

The preview automatically simulates a successful authentication, uses the current local user's profile when available and never starts a desktop session.

You can launch a specific clock layout, language or profile:

```bash
LUMINA_GREETER_CLOCK_LAYOUT=horizontal ./scripts/run-preview.sh
LUMINA_GREETER_LANGUAGE=pt-BR ./scripts/run-preview.sh
LUMINA_GREETER_LANGUAGE=en ./scripts/run-preview.sh
LUMINA_GREETER_USER=maylton ./scripts/run-preview.sh
LUMINA_GREETER_AVATAR=/absolute/path/to/avatar.png ./scripts/run-preview.sh
```

Use `stacked` for the two-line clock. The language value `system` detects `LC_ALL`, `LC_MESSAGES`, `LANG` and the Qt system locale, in that order. Unsupported languages and missing translation keys fall back to English.

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
  "wallpaper": "assets/default-wallpaper.svg",
  "sessions": [
    {
      "name": "Lumina Shell",
      "command": ["niri-session"]
    }
  ]
}
```

When `defaultUser`, `displayName` and `avatar` are empty, the installed greetd launcher detects the first regular local account. It reads the display name from the passwd GECOS field and looks for an avatar in AccountsService, `.face.icon` and `.face`, in that order. Environment overrides always take priority.

Supported environment overrides:

- `LUMINA_GREETER_CLOCK_LAYOUT=stacked|horizontal`
- `LUMINA_GREETER_LANGUAGE=system|en|pt-BR`
- `LUMINA_GREETER_USER=<username>`
- `LUMINA_GREETER_DISPLAY_NAME=<name>`
- `LUMINA_GREETER_AVATAR=/absolute/path/to/image`
- `LUMINA_GREETER_WALLPAPER=/absolute/path/to/image`
- `LUMINA_GREETER_PREVIEW=1`

## Translations

Translation catalogs live in `i18n/`. English is the mandatory fallback catalog. See `i18n/README.md` for the workflow for adding another language.

## Experimental greetd installation

Do not replace a working display manager until preview mode has been tested.

1. Install the project under `/etc/xdg/quickshell/lumina-greeter`.
2. Install `scripts/lumina-greeter-session` as `/usr/local/bin/lumina-greeter-session`.
3. Copy `packaging/greetd/lumina-greeter-niri.kdl` to `/etc/greetd/` and update its launcher path if needed.
4. Adapt `packaging/greetd/config.toml` and copy it to `/etc/greetd/config.toml`.
5. Confirm that the `greeter` system account can execute Niri and Quickshell.
6. Enable greetd only after validating all paths from a TTY.

The session commands in `config/defaults.json` are examples and must match the commands installed by the target distribution.

## Architecture

- `components/`: visual and interaction components.
- `config/`: validated configuration defaults and environment overrides.
- `design/`: shared Lumina visual tokens.
- `i18n/`: locale detection, translation catalogs and English fallback.
- `services/`: greetd authentication and system actions.
- `packaging/greetd/`: experimental greetd and Niri configuration.
- `scripts/`: preview and greeter entry points.

## Roadmap

- Discover Wayland sessions from desktop files.
- Read Lumina Shell wallpaper and dynamic color state.
- Add keyboard layout, accessibility and network controls.
- Add a language selector to the configuration UI.
- Package for Arch Linux and other distributions.
