# Stellix Shell

A modern, aesthetic shell built with **Quickshell** for **Hyprland**. Dynamic theming, deep system integration, and a refined glass-dark aesthetic. 🌑

## Preview

| 1 | 2 | 3|
|:---:|:---------:|:-------:|
| <img width="500" alt="1" src="https://github.com/user-attachments/assets/fb518ad4-005a-4593-9fbd-9b32edd3e8b0" /> | <img width="500" alt="2" src="https://github.com/user-attachments/assets/fdccc76e-ef95-4072-a9d5-75975f1b9273" /> | <img width="500" alt="3" src="https://github.com/user-attachments/assets/dd27722a-ed61-4c9a-bb0c-b31cd51ec4ef" /> |

<details>
<summary>Other Images</summary>

| | Others | |
|:---:|:---:|:---:|
| <img width="500" alt="4" src="https://github.com/user-attachments/assets/8e67f468-2f62-488a-9e01-22cab6c81dd5" /> | <img width="500" alt="5" src="https://github.com/user-attachments/assets/3f4d09b9-c4e2-4812-bc0b-a5989fa35b8d" /> | <img width="500" alt="6" src="https://github.com/user-attachments/assets/2d8270d7-6f1c-487e-bc7a-76a69cba81c7" /> |

</details>

## Features

- 🎨 **Dynamic Colors** -- Matugen extracts colors from your wallpaper, auto-syncs across the entire shell
- 📊 **Adaptive Bar** -- Top/bottom position, rearrangeable items, custom opacity & blur
- 🖥️ **Desktop Widgets** -- Draggable & rotatable clock, stats, weather, music player, equalizer
- 🎛️ **Control Center** -- Wi-Fi, Bluetooth, Audio, Media, Brightness, Quick Toggles
- 🔍 **App Launcher** -- Search apps, calculator, currency converter, clipboard, power menu
- ⚙️ **Settings Panel** -- Full GUI settings with live keybind editor for Hyprland

## Requirements

```
quickshell · hyprland · hyprpaper · qt6-base · qt6-declarative · qt6-svg
networkmanager · bluez · bluez-utils · pipewire · pipewire-pulse · playerctl
matugen · awww · brightnessctl · upower
wl-clipboard · cliphist · grim · slurp · hyprshot
xdg-desktop-portal-hyprland · gvfs · udisks2 · polkit · gnome-keyring
```

## Install

```bash
# Install dependencies
yay -S quickshell-git hyprland hyprpaper qt6-base qt6-declarative qt6-svg \
  networkmanager bluez bluez-utils pipewire pipewire-pulse playerctl \
  matugen awww brightnessctl upower \
  wl-clipboard cliphist grim slurp hyprshot \
  xdg-desktop-portal-hyprland gvfs udisks2 polkit gnome-keyring

# Install apps
yay -S kitty fish nautilus brave-bin visual-studio-code-bin \
  discord ferdium-bin btop cava ranger obs-studio

# Enable services
sudo systemctl enable --now NetworkManager bluetooth
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Clone config
git clone https://github.com/ranggaluthfiendi/Stellix.git ~/.config/quickshell
qs
```

## Keybinds

| Shortcut | Action |
|:---|:---|
| `Super + R` / `Alt + Space` | 🔍 App Launcher |
| `Super + I` | ⚙️ Settings |
| `Super + V` | 📋 Clipboard |
| `Super + /` | 📖 Shortcut Guide |
| `Super + Tab` | 🔄 Workspace Switcher |
| `Super + Alt (L/R)` | 🎛️ Rightbar Panel |

## Credits

Developed by **Rangga Luthfiendi** 

---
Stellix Shell
