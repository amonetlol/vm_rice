# Debian Sid Setup Scripts

Modular install scripts for a Debian Sid GNOME desktop, extracted from a VM setup session.

## Quick start

```bash
cd scripts_avulsos
chmod +x *.sh
./0.install_all.sh    # interactive menu
# or run individual scripts:
./7.base_apps.sh      # start here (apt + CLI tools)
./6.apps.sh           # Brave, Blackbox, herdr
./5.configs.sh        # dotfiles (amonetlol)
./1.temas.sh          # Catppuccin GTK
./2.icones.sh         # McMojave-circle icons
./3.cursor.sh         # Qogir cursor
./4.gnome-tweaks.sh   # keybinds + GNOME settings
```

## Recommended order

| # | Script | Purpose |
|---|--------|---------|
| 7 | `7.base_apps.sh` | Apt packages, contrib/non-free, CLI binaries |
| 6 | `6.apps.sh` | Brave, Blackbox, herdr |
| 5 | `5.configs.sh` | Bash, fonts, starship, nvim, ulauncher theme |
| 1 | `1.temas.sh` | Catppuccin GTK themes |
| 2 | `2.icones.sh` | McMojave-circle icons |
| 3 | `3.cursor.sh` | Qogir cursor |
| 4 | `4.gnome-tweaks.sh` | Keybinds, overlay-key, close-window helper |

Use `0.install_all.sh` to pick one, several, a range (`2-5`), or `all`.

## Notes

- Scripts use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Scripts that need root call `sudo` automatically when run as a normal user.
- `5.configs.sh` runs dotfile modules as the real user, not root.
- GNOME custom keybindings use **full dconf paths** (short names crash GNOME Settings).
- Brave apt source must be `stable main` only — never add contrib/non-free to third-party repos.
- Icon scripts remove `*ubuntu*` and `*manjaro*` folders from `~/.icons` after install (Qogir leftovers).
- **Do not** use `libreoffice*` wildcard removal in these scripts.
- If debloating elsewhere, `apt-mark hold` display/GNOME packages first.

## Legacy

Original one-off helpers from the setup session are in `legacy/` (Python remotes, fix scripts, old `debian-setup.sh`).