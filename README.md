# Caelestia Greeter

A Material Expressive login screen for Caelestia Shell, built with QML, Quickshell, Hyprland and greetd.

## Features

- Caelestia wallpaper and Material 3 colour scheme.
- Clock, date, motion and password glyphs matching the Caelestia lock screen.
- Dynamic Google Sans Flex loading from the installed Caelestia Shell.
- Brazilian Portuguese and English.
- Automatic user, display-name and avatar detection.
- greetd authentication and Hyprland session launch.
- Multi-monitor rendering and local preview mode.
- Restart and power-off actions.
- Interactive installer with display-manager backup and recovery.

## Requirements

- Caelestia Shell
- Hyprland
- Quickshell 0.3 or newer
- greetd
- systemd
- `M3Shapes`, provided by Caelestia Shell; simple circular password glyphs are used as a fallback

The installer is intended for systemd-based Caelestia/Hyprland systems and has been validated on CachyOS.

## Preview

Always test the interface before replacing a working display manager:

```bash
./scripts/run-preview.sh
```

Preview mode reads the current user's Caelestia state:

```text
~/.config/caelestia/shell.json
~/.local/state/caelestia/scheme.json
~/.local/state/caelestia/wallpaper/path.txt
```

Useful overrides:

```bash
CAELESTIA_GREETER_LANGUAGE=pt-BR ./scripts/run-preview.sh
CAELESTIA_GREETER_USER=user ./scripts/run-preview.sh
CAELESTIA_GREETER_AVATAR=/path/to/avatar.png ./scripts/run-preview.sh
CAELESTIA_GREETER_WALLPAPER=/path/to/wallpaper.jpg ./scripts/run-preview.sh
CAELESTIA_GREETER_SCHEME_PATH=/path/to/scheme.json ./scripts/run-preview.sh
```

## Installation

Run the interactive installer from the repository root:

```bash
./install.sh
```

The language is detected from the system locale. It can also be selected explicitly:

```bash
./install.sh --lang pt-BR
./install.sh --lang en
```

Before changing the system, the installer displays the complete plan and waits for an explicit confirmation. It then:

1. detects the local user whose Caelestia profile will be used;
2. detects the current display manager through `display-manager.service` and active systemd services;
3. validates Hyprland, Quickshell, greetd and the project files;
4. backs up the current display manager, its service state and any existing Caelestia Greeter installation;
5. installs the QML interface, session scripts, Hyprland greeter configuration and greetd configuration;
6. copies the user's avatar, wallpaper, Material palette, Shell configuration and Google Sans Flex file into `/var/cache/caelestia-greeter` for the restricted `greeter` account;
7. configures GNOME Keyring PAM integration when `pam_gnome_keyring.so` is available;
8. disables the previous display manager and enables greetd for the next boot;
9. installs the `caelestia-greeter-restore` recovery command.

The currently running display manager is **not stopped** during installation. The change takes effect only after a reboot.

### Display-manager backups

The installer recognises SDDM, GDM, LightDM, greetd, Ly and LXDM. Backups are stored under:

```text
/var/backups/caelestia-greeter/YYYYmmdd-HHMMSS/
```

For SDDM, the backup includes its configuration, state file and the configured theme directory when one can be identified. The systemd `display-manager.service` link and the previous service state are recorded for every supported manager.

### Installer options

```text
--user USER       Select the user profile to synchronise
--yes             Skip the confirmation prompt
--no-keyring      Do not modify greetd's PAM file for GNOME Keyring
--lang pt-BR|en   Select the installer language
```

## Restore the previous display manager

From a TTY, run:

```bash
sudo caelestia-greeter-restore
```

The command displays the recovery plan, disables greetd for the next boot, restores the backed-up files and re-enables the previous display manager. A specific backup can be selected:

```bash
sudo caelestia-greeter-restore /var/backups/caelestia-greeter/YYYYmmdd-HHMMSS
```

The current graphical session is not stopped by the restore command; reboot to apply the restored configuration.

## Configuration

Defaults live in `config/defaults.json`:

```json
{
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

## Runtime data

The profile synchroniser creates root-owned, greeter-readable copies of the selected user's visual state. It writes cached assets to `/var/cache/caelestia-greeter` and the resolved environment to `/run/caelestia-greeter/profile.env`.

The user's original wallpaper, avatar, Shell configuration and palette are never modified.

## Structure

- `components/`: interface components.
- `config/`: defaults and environment overrides.
- `design/`: dynamic theme and motion tokens.
- `i18n/`: translation catalogues.
- `services/`: authentication and power actions.
- `packaging/`: greetd, Hyprland and systemd configuration.
- `scripts/`: preview, synchronisation, session and recovery commands.
- `install.sh`: interactive system installer.
