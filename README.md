# Stellix Shell

A master-crafted, modern, and highly customizable shell environment for Linux, built with **Quickshell** and designed for **Hyprland**. Stellix Shell focuses on performance, deep system integration, and a refined "Glass & Dark" aesthetic.

## ✨ Features

- **Dynamic Theming**: Powered by **Matugen**, the entire UI colors automatically sync with your wallpaper.
- **Floating Dashboard**: A beautiful, unified control center for system settings, hardware metrics, and quick toggles.
- **Adaptive Bar**: Supports top and bottom positions with dynamic layout adjustment.
- **Deep Integration**: Native controls for Wi-Fi (nmcli), Bluetooth (bluetoothctl), Audio (Pipewire), and Media (MPRIS).
- **Global Shortcuts**: Built-in management for Hyprland keybinds directly from the settings menu.

## 🛠️ System Requirements & Dependencies

To experience the full potential of Stellix Shell, ensure the following are installed on your system.

### 1. Core Components
Install the shell engine and the recommended window manager:
```bash
# Arch Linux
sudo pacman -S quickshell hyprland qt6-base qt6-declarative
```

### 2. Services & Logic
Required for the shell's features to function (Networking, Audio, Colors):
```bash
# Core Services
sudo pacman -S networkmanager bluez bluez-utils pipewire wireplumber upower playerctl curl
```

### 3. Theming & Wallpaper
Stellix uses **Matugen** for colors and **Awww** for wallpaper transitions:
```bash
# Install Matugen (via AUR)
yay -S matugen-bin

# Install Awww (Wallpaper Daemon)
# Visit: https://github.com/out-fox/awww
yay -S awww-git
```

## 🚀 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YourUsername/quickshell-stellix.git ~/.config/quickshell
   ```

2. **Setup Matugen**:
   Ensure you have a valid `matugen.toml` in your config directory. Stellix expects `~/.config/matugen/matugen.toml` to exist for dynamic theming.

3. **Launch the Shell**:
   Simply run the `qs` command (or `quickshell` pointing to `shell.qml`):
   ```bash
   qs
   ```

## ⌨️ Default Keybinds

| Shortcut | Action |
| :--- | :--- |
| `SUPER + /` | Open Shortcut Guide |
| `SUPER + I` | Open System Settings |
| `ALT + SPACE` | Open App Launcher |
| `SUPER + V` | Open Clipboard History |
| `SUPER + TAB` | Toggle Workspace Switcher |
| `SUPER + RETURN` | Open Terminal |

## ⚙️ Customization

Most aspects of the shell can be configured through the **Stellix Control** (System Settings).
- **Appearance**: Change wallpaper, toggle Dark Mode, adjust Blur and Transparency.
- **Keybindings**: Change system shortcuts without editing config files manually.

## 🤝 Credits
- Developed by **Rangga Luthfiendi**.


---
*Stellix Shell ^_^*
