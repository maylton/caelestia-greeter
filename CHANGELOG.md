# Changelog

## 1.0.0 — 2026-07-28

First official Caelestia Greeter release.

### Interface

- Material Expressive login screen built with QML and Quickshell.
- Clock, date, typography and password interaction aligned with the Caelestia lock screen.
- Animated Google Sans Flex clock using the variable font shipped by Caelestia Shell.
- Material password glyphs, compact-to-expanded password field and Caelestia motion curves.
- Dynamic wallpaper and Material 3 palette synchronisation.
- Brazilian Portuguese and English localisation.
- Responsive multi-monitor rendering, restart and power-off controls.

### Authentication and sessions

- greetd authentication.
- Hyprland greeter compositor session.
- Caelestia/Hyprland desktop-session handoff.
- Optional GNOME Keyring PAM integration.
- Automatic local-user, display-name and avatar detection.

### Installation and recovery

- Interactive bilingual installer.
- Automatic detection of SDDM, GDM, LightDM, greetd, Ly and LXDM.
- Backup of the previous display manager, service state and existing greeter files.
- SDDM configuration, state and active-theme backup when available.
- Safe next-boot switch to greetd without stopping the current graphical session.
- Profile cache synchronisation for wallpaper, palette, Shell configuration, avatar and font.
- `caelestia-greeter-restore` command for restoring the previous display manager.
