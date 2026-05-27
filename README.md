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

### Core
```
quickshell · hyprland · hyprpaper · qt6-base · qt6-declarative · qt6-svg
```

### System Services
```
networkmanager · bluez · bluez-utils · pipewire · pipewire-pulse · wireplumber
playerctl · upower · xdg-desktop-portal-hyprland · gvfs · udisks2 · polkit · gnome-keyring
```

### Tools & Utilities
```
matugen · awww · brightnessctl · wl-clipboard · cliphist
grim · slurp · hyprshot · hyprlock · cava · bc · curl
qt6ct · qt5ct
```

### Recommended Applications
```
kitty · fish · nautilus · brave-bin · visual-studio-code-bin
discord · ferdium-bin · btop · ranger · obs-studio
```

## Install

### Option 1: Automated Installer (Recommended)

The automated installer handles dependencies, services, and configuration with interactive prompts:

```bash
# Clone the repository
git clone https://github.com/ranggaluthfiendi/Stellix.git ~/.config/quickshell/stellix

# Check system status first (dry run, no changes)
~/.config/quickshell/stellix/install.sh --check

# Run the installer
~/.config/quickshell/stellix/install.sh
```

The installer will:
- Check existing packages and only install missing ones
- Ask before installing each category of packages
- Enable required system services
- Install Quickshell, Hyprland, and Matugen configurations
- **Add `qs -c ~/.config/quickshell/stellix` to Hyprland autostart (execs.conf)**
- Create wallpaper directory
- Generate initial Matugen theme colors

**Check Mode** (`--check` or `-c`):
- Lists all dependencies (installed vs missing)
- Checks configuration files
- Checks system services status
- Checks script permissions
- Does NOT install or modify anything

### Option 2: Manual Installation

```bash
# Install core dependencies
yay -S quickshell-git hyprland hyprpaper qt6-base qt6-declarative qt6-svg \
  networkmanager bluez bluez-utils pipewire pipewire-pulse wireplumber playerctl \
  matugen awww brightnessctl upower \
  wl-clipboard cliphist grim slurp hyprshot hyprlock \
  xdg-desktop-portal-hyprland gvfs udisks2 polkit gnome-keyring \
  cava bc curl qt6ct qt5ct

# Install recommended apps
yay -S kitty fish nautilus brave-bin visual-studio-code-bin \
  discord ferdium-bin btop cava ranger obs-studio

# Enable services
sudo systemctl enable --now NetworkManager bluetooth
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Clone config
git clone https://github.com/ranggaluthfiendi/Stellix.git ~/.config/quickshell/stellix

# Make scripts executable
chmod +x ~/.config/quickshell/stellix/scripts/*.sh
chmod +x ~/.config/matugen/*.sh

# Start Stellix
qs -c ~/.config/quickshell/stellix
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

## Project Structure

```
stellix/
├── shell.qml              # Main entry point
├── components/            # UI components
│   ├── elements/          # Reusable UI elements
│   ├── ui/                # Bar and UI layouts
│   ├── utils/             # Utility components (drag, rotate)
│   └── widgets/           # Widget implementations
│       ├── applauncher/   # App launcher with settings
│       ├── barpopup/      # Bar popup overlays
│       ├── media/         # Media player widgets
│       ├── misc/          # Miscellaneous widgets
│       ├── system/        # System widgets (battery, quick actions)
│       ├── systemtray/    # System tray implementation
│       └── workspaceswitcher/  # Workspace switcher
├── config/                # Design tokens (Theme, Dimens, Scales, Typography)
├── core/                  # Core services and state
│   ├── services/          # Background services (Pipewire, Mpris, etc.)
│   ├── settings/          # Settings state management
│   ├── state/             # UI state management
│   └── time/              # Time-related utilities
├── data/                  # Static data files
├── icons/                 # Custom icons
├── savedata/              # Runtime saved data (colors, pins, etc.)
├── screens/               # Screen-level components
├── scripts/               # Shell scripts
│   ├── cava_daemon.sh     # Cava audio visualizer daemon
│   └── vb-control.sh      # Volume/brightness control with IPC
├── matugen.toml           # Matugen configuration (symlink)
├── install.sh             # Automated installer
└── setup-permissions.sh   # Script permissions helper
```

## Scripts

| Script | Description |
|:---|:---|
| `install.sh` | Comprehensive installer with dependency checking |
| `setup-permissions.sh` | Makes all shell scripts executable |
| `scripts/vb-control.sh` | Volume/brightness control with Quickshell IPC indicator |
| `scripts/cava_daemon.sh` | Cava audio visualizer daemon for equalizer widget |

## Matugen Integration

Stellix uses Matugen for dynamic theming. The configuration supports:
- **Quickshell** - JSON color output for QML theme
- **GTK3/GTK4** - CSS color themes
- **KDE** - kdeglobals color scheme
- **Qt5ct/Qt6ct** - Qt color themes
- **Hyprland** - Color variables for Hyprland config
- **Kitty** - Terminal color theme
- **Fish** - Shell color theme

To reapply theme:
```bash
~/.config/matugen/apply-theme.sh dark
```

## Credits

Developed by **Rangga Luthfiendi** 

---
Stellix Shell
