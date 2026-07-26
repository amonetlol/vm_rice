# hypr4 rice (Jules3182 adapted)

![preview](preview.png)

Rice Hyprland baseado nos [dotfiles do Jules3182](https://github.com/Jules3182/dotfiles), adaptado para **VMware** / **CachyOS**.

Stack: **foot** (terminal), **rofi** (estilo wofi/drun), **thunar** (arquivos), **waybar** (barra superior).

## Atalhos principais

| Tecla | Ação |
|-------|------|
| `Alt+D` | Rofi drun (launcher) |
| `Alt+Return` | Foot (terminal) |
| `Alt+W` | Firefox |
| `Alt+X` | Wlogout |
| `Alt+E` | Thunar |
| `Alt+Q` | Fechar janela |
| `Alt+F` | Fullscreen |
| `Alt+F12` | Refresh Waybar |
| `Super+R` | Reload acessórios |
| `Super+V` | Toggle float |
| `Super+1…0` | Workspace 1–10 |
| `Super+Shift+1…0` | Mover janela para workspace |

## Instalação e uso

1. Copie `hypr4/` para `~/.config/hypr4/`
2. Copie os configs de shell:
   - `starship.toml` → `~/.config/starship.toml`
   - `fastfetch/config.jsonc` → `~/.config/fastfetch/config.jsonc`
   - `fastfetch/rice.txt` → `~/.config/fastfetch/rice.txt` (logo usado pelo fastfetch)
3. Dependências: `hyprland`, `foot`, `rofi`, `waybar`, `thunar`, `wlogout`, `grim`, `swaybg`, `wireplumber`, `brightnessctl`, `starship`, `fastfetch`
4. No SDDM, selecione a sessão **hypr4** (ou inicie manualmente):

```bash
Hyprland --config ~/.config/hypr4/hyprland.lua
```

5. Após editar configs, recarregue sem relogar:

```bash
hyprctl reload
# ou
~/.config/hypr4/scripts/reload.sh
```

## Créditos

- Base visual e binds: [Jules3182/dotfiles](https://github.com/Jules3182/dotfiles)
- Adaptação: dot-grey / vm_rice
