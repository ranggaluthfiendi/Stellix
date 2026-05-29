#!/bin/bash
# Stellix Shell - Comprehensive Installer
# Installs dependencies and configures Hyprland, Quickshell, Matugen, etc.

# Check for --check flag
CHECK_MODE=false
if [[ "$1" == "--check" || "$1" == "-c" ]]; then
    CHECK_MODE=true
fi

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ░██████   ░██████████░██████████ ░██         ░██         ░██████░██    ░██ "
echo " ░██   ░██      ░██    ░██         ░██         ░██           ░██   ░██  ░██  "
echo "░██             ░██    ░██         ░██         ░██           ░██    ░██░██   "
echo " ░████████      ░██    ░█████████  ░██         ░██           ░██     ░███    "
echo "        ░██     ░██    ░██         ░██         ░██           ░██    ░██░██   "
echo " ░██   ░██      ░██    ░██         ░██         ░██           ░██   ░██  ░██  "
echo "  ░██████       ░██    ░██████████ ░██████████ ░██████████ ░██████░██    ░██ "
echo "                                                                             "
echo "                                                                             "
echo "                                                                             "
echo -e "  Stellix Shell Installer${NC}"
echo ""

if [ "$CHECK_MODE" = true ]; then
    echo -e "${YELLOW}=== CHECK MODE - No changes will be made ===${NC}"
    echo ""
fi

# Function to check if command exists
cmd_exists() {
    command -v "$1" &>/dev/null
}

# Check if running on Arch-based system
if ! cmd_exists yay && ! cmd_exists pacman; then
    echo -e "${RED}Error: This installer supports Arch-based systems only (pacman/yay required)${NC}"
    exit 1
fi

# Use yay if available, fallback to pacman
if cmd_exists yay; then
    AUR_HELPER="yay"
else
    AUR_HELPER="pacman"
fi

# Function to check if package is installed
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Function to check packages (install or dry-run)
check_packages() {
    local category="$1"
    shift
    local packages=("$@")
    local to_install=()
    local already_installed=()

    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            already_installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done

    echo -e "${CYAN}=== $category ===${NC}"
    
    if [ ${#already_installed[@]} -gt 0 ]; then
        echo -e "  ${GREEN}✓ Installed:${NC} ${already_installed[*]}"
    fi

    if [ ${#to_install[@]} -gt 0 ]; then
        echo -e "  ${RED}✗ Missing:${NC} ${to_install[*]}"
        
        if [ "$CHECK_MODE" = false ]; then
            read -p "  Install these packages? [Y/n] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                if [ "$AUR_HELPER" = "yay" ]; then
                    yay -S --noconfirm "${to_install[@]}"
                else
                    sudo pacman -S --noconfirm "${to_install[@]}"
                fi
            else
                echo -e "  ${YELLOW}Skipped${NC}"
            fi
        fi
    else
        echo -e "  ${GREEN}All packages installed${NC}"
    fi
}

# ============================================================
# CHECK MODE: Full system check without installing
# ============================================================
if [ "$CHECK_MODE" = true ]; then
    echo -e "${CYAN}=== Step 1: Core Dependencies ===${NC}"
    
    CORE_PACKAGES=(
        "hyprland" "qt6-base" "qt6-declarative" "qt6-svg"
        "networkmanager" "bluez" "bluez-utils" "pipewire" "pipewire-pulse" "wireplumber"
        "playerctl" "brightnessctl" "upower" "wl-clipboard" "cliphist"
        "grim" "slurp" "hyprshot" "hyprlock" "xdg-desktop-portal-hyprland"
        "gvfs" "udisks2" "polkit" "gnome-keyring" "bc" "curl" "cava"
        "qt6ct" "qt5ct" "fish" "nautilus" "kitty" "btop" "ranger" "obs-studio"
    )
    
    MISSING_CORE=()
    INSTALLED_CORE=()
    
    for pkg in "${CORE_PACKAGES[@]}"; do
        if is_installed "$pkg"; then
            INSTALLED_CORE+=("$pkg")
        else
            MISSING_CORE+=("$pkg")
        fi
    done
    
    echo -e "  ${GREEN}✓ Installed (${#INSTALLED_CORE[@]}):${NC} ${INSTALLED_CORE[*]}"
    if [ ${#MISSING_CORE[@]} -gt 0 ]; then
        echo -e "  ${RED}✗ Missing (${#MISSING_CORE[@]}):${NC} ${MISSING_CORE[*]}"
    else
        echo -e "  ${GREEN}All core dependencies installed${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 2: AUR Dependencies ===${NC}"
    
    AUR_PACKAGES=("quickshell-git" "matugen" "awww")
    MISSING_AUR=()
    INSTALLED_AUR=()
    
    for pkg in "${AUR_PACKAGES[@]}"; do
        if is_installed "$pkg"; then
            INSTALLED_AUR+=("$pkg")
        else
            MISSING_AUR+=("$pkg")
        fi
    done
    
    echo -e "  ${GREEN}✓ Installed (${#INSTALLED_AUR[@]}):${NC} ${INSTALLED_AUR[*]}"
    if [ ${#MISSING_AUR[@]} -gt 0 ]; then
        echo -e "  ${RED}✗ Missing (${#MISSING_AUR[@]}):${NC} ${MISSING_AUR[*]}"
    else
        echo -e "  ${GREEN}All AUR dependencies installed${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 2.5: Material Symbols Fonts ===${NC}"
    
    if fc-list | grep -q "Material Symbols"; then
        MS_COUNT=$(fc-list | grep "Material Symbols" | wc -l)
        echo -e "  ${GREEN}✓ Installed:${NC} Material Symbols ($MS_COUNT variants)"
    else
        echo -e "  ${RED}✗ Missing:${NC} Material Symbols fonts (Outlined, Rounded, Sharp)"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 3: Optional Applications ===${NC}"
    
    OPTIONAL_PACKAGES=("brave-bin" "visual-studio-code-bin" "discord" "ferdium-bin")
    MISSING_OPT=()
    INSTALLED_OPT=()
    
    for pkg in "${OPTIONAL_PACKAGES[@]}"; do
        if is_installed "$pkg"; then
            INSTALLED_OPT+=("$pkg")
        else
            MISSING_OPT+=("$pkg")
        fi
    done
    
    echo -e "  ${GREEN}✓ Installed (${#INSTALLED_OPT[@]}):${NC} ${INSTALLED_OPT[*]}"
    if [ ${#MISSING_OPT[@]} -gt 0 ]; then
        echo -e "  ${YELLOW}○ Optional (${#MISSING_OPT[@]}):${NC} ${MISSING_OPT[*]}"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 4: System Services ===${NC}"
    
    SERVICES=("NetworkManager" "bluetooth" "pipewire" "pipewire-pulse" "wireplumber")
    for svc in "${SERVICES[@]}"; do
        if systemctl --quiet is-active "$svc" 2>/dev/null || systemctl --user --quiet is-active "$svc" 2>/dev/null; then
            echo -e "  ${GREEN}✓ Active:${NC} $svc"
        else
            echo -e "  ${YELLOW}○ Inactive:${NC} $svc"
        fi
    done
    
    echo ""
    echo -e "${CYAN}=== Step 5: Stellix Configuration ===${NC}"
    
    INSTALL_DIR="$HOME/.config/quickshell/stellix"
    if [ -d "$INSTALL_DIR" ]; then
        FILE_COUNT=$(find "$INSTALL_DIR" -type f | wc -l)
        echo -e "  ${GREEN}✓ Found:${NC} $INSTALL_DIR ($FILE_COUNT files)"
    else
        echo -e "  ${RED}✗ Not found:${NC} $INSTALL_DIR"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 6: Hyprland Configuration ===${NC}"
    
    HYPRLAND_DIR="$HOME/.config/hypr"
    if [ -d "$HYPRLAND_DIR" ]; then
        FILE_COUNT=$(find "$HYPRLAND_DIR" -type f | wc -l)
        echo -e "  ${GREEN}✓ Found:${NC} $HYPRLAND_DIR ($FILE_COUNT files)"
        
        # Check key files
        for f in "hyprland.conf" "colors.conf" "hyprland/execs.conf" "hyprland/keybinds.conf"; do
            if [ -f "$HYPRLAND_DIR/$f" ]; then
                echo -e "    ${GREEN}✓${NC} $f"
            else
                echo -e "    ${RED}✗${NC} $f (missing)"
            fi
        done
    else
        echo -e "  ${RED}✗ Not found:${NC} $HYPRLAND_DIR"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 7: Matugen Configuration ===${NC}"
    
    MATUGEN_DIR="$HOME/.config/matugen"
    if [ -d "$MATUGEN_DIR" ]; then
        FILE_COUNT=$(find "$MATUGEN_DIR" -type f | wc -l)
        echo -e "  ${GREEN}✓ Found:${NC} $MATUGEN_DIR ($FILE_COUNT files)"
        
        if [ -x "$MATUGEN_DIR/apply-theme.sh" ]; then
            echo -e "    ${GREEN}✓${NC} apply-theme.sh (executable)"
        else
            echo -e "    ${YELLOW}○${NC} apply-theme.sh (not executable)"
        fi
    else
        echo -e "  ${RED}✗ Not found:${NC} $MATUGEN_DIR"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 8: Wallpaper Directory ===${NC}"
    
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    if [ -d "$WALLPAPER_DIR" ]; then
        WALLPAPER_COUNT=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | wc -l)
        echo -e "  ${GREEN}✓ Found:${NC} $WALLPAPER_DIR ($WALLPAPER_COUNT wallpapers)"
    else
        echo -e "  ${YELLOW}○ Not found:${NC} $WALLPAPER_DIR"
    fi
    
    echo ""
    echo -e "${CYAN}=== Step 9: Scripts ===${NC}"
    
    SCRIPTS=(
        "$HOME/.config/quickshell/stellix/scripts/cava_daemon.sh"
        "$HOME/.config/quickshell/stellix/scripts/vb-control.sh"
        "$HOME/.config/quickshell/stellix/install.sh"
        "$HOME/.config/matugen/apply-theme.sh"
    )
    
    for script in "${SCRIPTS[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                echo -e "  ${GREEN}✓${NC} $script (executable)"
            else
                echo -e "  ${YELLOW}○${NC} $script (not executable)"
            fi
        else
            echo -e "  ${RED}✗${NC} $script (missing)"
        fi
    done
    
    echo ""
    echo -e "${CYAN}=== Step 10: Quickshell Autostart ===${NC}"
    
    EXECSCONF="$HOME/.config/hypr/hyprland/execs.conf"
    INSTALL_DIR_CHECK="$HOME/.config/quickshell/stellix"
    if [ -f "$EXECSCONF" ]; then
        if grep -q "qs -c $INSTALL_DIR_CHECK" "$EXECSCONF" 2>/dev/null; then
            echo -e "  ${GREEN}✓ Configured:${NC} qs -c $INSTALL_DIR_CHECK (in execs.conf)"
        else
            echo -e "  ${YELLOW}○ Not configured:${NC} Add 'exec-once = qs -c $INSTALL_DIR_CHECK' to execs.conf"
        fi
    else
        echo -e "  ${YELLOW}○ execs.conf not found${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  System Check Complete!  ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Summary
    TOTAL_MISSING=$((${#MISSING_CORE[@]} + ${#MISSING_AUR[@]}))
    if [ $TOTAL_MISSING -eq 0 ]; then
        echo -e "${GREEN}All required dependencies are installed!${NC}"
        echo "You can run Stellix with: qs -c stellix"
    else
        echo -e "${RED}Missing $TOTAL_MISSING required packages${NC}"
        echo "Run without --check flag to install: ./install.sh"
    fi
    
    exit 0
fi

# ============================================================
# NORMAL INSTALL MODE
# ============================================================

# Function to install packages
install_packages() {
    local packages=("$@")
    local to_install=()
    local already_installed=()

    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            already_installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done

    if [ ${#already_installed[@]} -gt 0 ]; then
        echo -e "${GREEN}Already installed:${NC} ${already_installed[*]}"
    fi

    if [ ${#to_install[@]} -eq 0 ]; then
        return 0
    fi

    echo -e "${YELLOW}To install:${NC} ${to_install[*]}"
    read -p "Install these packages? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Skipped installation of: ${to_install[*]}${NC}"
        return 1
    fi

    if [ "$AUR_HELPER" = "yay" ]; then
        yay -S --noconfirm "${to_install[@]}"
    else
        sudo pacman -S --noconfirm "${to_install[@]}"
    fi
}

# ============================================================
# Step 1: Check and install core dependencies
# ============================================================
echo -e "${CYAN}=== Step 1: Core Dependencies ===${NC}"

CORE_PACKAGES=(
    "hyprland"
    "qt6-base"
    "qt6-declarative"
    "qt6-svg"
    "networkmanager"
    "bluez"
    "bluez-utils"
    "pipewire"
    "pipewire-pulse"
    "wireplumber"
    "playerctl"
    "brightnessctl"
    "upower"
    "wl-clipboard"
    "cliphist"
    "grim"
    "slurp"
    "hyprshot"
    "hyprlock"
    "xdg-desktop-portal-hyprland"
    "gvfs"
    "udisks2"
    "polkit"
    "gnome-keyring"
    "bc"
    "curl"
    "cava"
    "qt6ct"
    "qt5ct"
    "fish"
    "nautilus"
    "kitty"
    "btop"
    "ranger"
    "obs-studio"
)

install_packages "${CORE_PACKAGES[@]}"

# ============================================================
# Step 2: Check and install AUR dependencies
# ============================================================
echo ""
echo -e "${CYAN}=== Step 2: AUR Dependencies ===${NC}"

AUR_PACKAGES=(
    "quickshell-git"
    "matugen"
    "awww"
)

install_packages "${AUR_PACKAGES[@]}"

# ============================================================
# Step 2.5: Install Material Symbols fonts
# ============================================================
echo ""
echo -e "${CYAN}=== Step 2.5: Material Symbols Fonts ===${NC}"

if fc-list | grep -q "Material Symbols"; then
    echo -e "${GREEN}Material Symbols fonts already installed${NC}"
else
    echo "Installing Material Symbols fonts..."
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -x "$SCRIPT_DIR/scripts/install-material-symbols-user.sh" ]; then
        bash "$SCRIPT_DIR/scripts/install-material-symbols-user.sh"
        echo -e "${GREEN}Material Symbols fonts installed${NC}"
    else
        echo -e "${YELLOW}Install script not found, skipping${NC}"
    fi
fi

# ============================================================
# Step 3: Check and install optional apps
# ============================================================
echo ""
echo -e "${CYAN}=== Step 3: Optional Applications ===${NC}"

OPTIONAL_PACKAGES=(
    "brave-bin"
    "visual-studio-code-bin"
    "discord"
    "ferdium-bin"
)

OPTIONAL_TO_INSTALL=()
OPTIONAL_EXISTING=()

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        OPTIONAL_EXISTING+=("$pkg")
    else
        OPTIONAL_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#OPTIONAL_EXISTING[@]} -gt 0 ]; then
    echo -e "${GREEN}Already installed:${NC} ${OPTIONAL_EXISTING[*]}"
fi

if [ ${#OPTIONAL_TO_INSTALL[@]} -gt 0 ]; then
    echo -e "${YELLOW}Optional packages not installed:${NC} ${OPTIONAL_TO_INSTALL[*]}"
    read -p "Install optional applications? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if [ "$AUR_HELPER" = "yay" ]; then
            yay -S --noconfirm "${OPTIONAL_TO_INSTALL[@]}"
        else
            sudo pacman -S --noconfirm "${OPTIONAL_TO_INSTALL[@]}"
        fi
    else
        echo -e "${YELLOW}Skipped optional applications${NC}"
    fi
else
    echo -e "${GREEN}All optional applications already installed${NC}"
fi

# ============================================================
# Step 4: Enable system services
# ============================================================
echo ""
echo -e "${CYAN}=== Step 4: System Services ===${NC}"

echo "Enabling system services..."
sudo systemctl enable --now NetworkManager 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
systemctl --user enable --now pipewire 2>/dev/null || true
systemctl --user enable --now pipewire-pulse 2>/dev/null || true
systemctl --user enable --now wireplumber 2>/dev/null || true

echo -e "${GREEN}System services enabled${NC}"

# ============================================================
# Step 5: Install Stellix configurations
# ============================================================
echo ""
echo -e "${CYAN}=== Step 5: Install Stellix Configurations ===${NC}"

INSTALL_DIR="$HOME/.config/quickshell/stellix"

# Check if existing Stellix config exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Existing Stellix configuration found at: $INSTALL_DIR${NC}"
    echo "What would you like to do?"
    echo "  1) Backup existing and install fresh"
    echo "  2) Merge with existing (skip existing files)"
    echo "  3) Skip Stellix config installation"
    read -p "Choose option [1/2/3]: " -r

    case $REPLY in
        1)
            BACKUP_DIR="$HOME/.config/quickshell/stellix-backup-$(date +%Y%m%d_%H%M%S)"
            echo "Backing up existing config to: $BACKUP_DIR"
            mv "$INSTALL_DIR" "$BACKUP_DIR"
            echo -e "${GREEN}Backup created${NC}"
            ;;
        2)
            echo "Will merge with existing configuration (skip existing files)"
            MERGE_MODE="skip"
            ;;
        3)
            echo "Skipping Stellix config installation"
            SKIP_STELLIX="yes"
            ;;
        *)
            echo "Invalid option, skipping Stellix config installation"
            SKIP_STELLIX="yes"
            ;;
    esac
fi

if [ "$SKIP_STELLIX" != "yes" ]; then
    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    echo "Installing Stellix configuration to: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    # Copy Quickshell config
    if [ "$MERGE_MODE" = "skip" ]; then
        cp -rn "$SCRIPT_DIR"/* "$INSTALL_DIR"/ 2>/dev/null || true
    else
        cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR"/ 2>/dev/null || true
    fi

    # Make scripts executable
    chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true

    echo -e "${GREEN}Stellix Quickshell configuration installed${NC}"
fi

# ============================================================
# Step 6: Install Hyprland configuration
# ============================================================
echo ""
echo -e "${CYAN}=== Step 6: Install Hyprland Configuration ===${NC}"

HYPRLAND_DIR="$HOME/.config/hypr"

if [ -d "$HYPRLAND_DIR" ]; then
    echo -e "${YELLOW}Existing Hyprland configuration found at: $HYPRLAND_DIR${NC}"
    echo "What would you like to do?"
    echo "  1) Backup existing and install fresh"
    echo "  2) Merge with existing (skip existing files)"
    echo "  3) Skip Hyprland config installation"
    read -p "Choose option [1/2/3]: " -r

    case $REPLY in
        1)
            BACKUP_DIR="$HOME/.config/hypr-backup-$(date +%Y%m%d_%H%M%S)"
            echo "Backing up existing config to: $BACKUP_DIR"
            mv "$HYPRLAND_DIR" "$BACKUP_DIR"
            echo -e "${GREEN}Backup created${NC}"
            ;;
        2)
            echo "Will merge with existing configuration (skip existing files)"
            HYPRLAND_MERGE="skip"
            ;;
        3)
            echo "Skipping Hyprland config installation"
            SKIP_HYPRLAND="yes"
            ;;
        *)
            echo "Invalid option, skipping Hyprland config installation"
            SKIP_HYPRLAND="yes"
            ;;
    esac
fi

if [ "$SKIP_HYPRLAND" != "yes" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    echo "Installing Hyprland configuration to: $HYPRLAND_DIR"
    mkdir -p "$HYPRLAND_DIR"

    # Copy hyprland config files
    if [ -d "$SCRIPT_DIR/hypr" ]; then
        if [ "$HYPRLAND_MERGE" = "skip" ]; then
            cp -rn "$SCRIPT_DIR/hypr"/* "$HYPRLAND_DIR"/ 2>/dev/null || true
        else
            cp -r "$SCRIPT_DIR/hypr"/* "$HYPRLAND_DIR"/ 2>/dev/null || true
        fi
    fi

    # Copy hyprpaper config
    if [ -f "$SCRIPT_DIR/hyprpaper.conf" ]; then
        if [ "$HYPRLAND_MERGE" = "skip" ] && [ -f "$HYPRLAND_DIR/hyprpaper.conf" ]; then
            echo "Skipping hyprpaper.conf (already exists)"
        else
            cp "$SCRIPT_DIR/hyprpaper.conf" "$HYPRLAND_DIR/"
        fi
    fi

    echo -e "${GREEN}Hyprland configuration installed${NC}"
fi

# ============================================================
# Step 7: Install Matugen configuration
# ============================================================
echo ""
echo -e "${CYAN}=== Step 7: Install Matugen Configuration ===${NC}"

MATUGEN_DIR="$HOME/.config/matugen"

if [ -d "$MATUGEN_DIR" ]; then
    echo -e "${YELLOW}Existing Matugen configuration found at: $MATUGEN_DIR${NC}"
    echo "What would you like to do?"
    echo "  1) Backup existing and install fresh"
    echo "  2) Merge with existing (skip existing files)"
    echo "  3) Skip Matugen config installation"
    read -p "Choose option [1/2/3]: " -r

    case $REPLY in
        1)
            BACKUP_DIR="$HOME/.config/matugen-backup-$(date +%Y%m%d_%H%M%S)"
            echo "Backing up existing config to: $BACKUP_DIR"
            mv "$MATUGEN_DIR" "$BACKUP_DIR"
            echo -e "${GREEN}Backup created${NC}"
            ;;
        2)
            echo "Will merge with existing configuration (skip existing files)"
            MATUGEN_MERGE="skip"
            ;;
        3)
            echo "Skipping Matugen config installation"
            SKIP_MATUGEN="yes"
            ;;
        *)
            echo "Invalid option, skipping Matugen config installation"
            SKIP_MATUGEN="yes"
            ;;
    esac
fi

if [ "$SKIP_MATUGEN" != "yes" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    echo "Installing Matugen configuration to: $MATUGEN_DIR"
    mkdir -p "$MATUGEN_DIR"

    if [ -d "$SCRIPT_DIR/matugen" ]; then
        if [ "$MATUGEN_MERGE" = "skip" ]; then
            cp -rn "$SCRIPT_DIR/matugen"/* "$MATUGEN_DIR"/ 2>/dev/null || true
        else
            cp -r "$SCRIPT_DIR/matugen"/* "$MATUGEN_DIR"/ 2>/dev/null || true
        fi
    fi

    # Make matugen scripts executable
    chmod +x "$MATUGEN_DIR/"*.sh 2>/dev/null || true

    echo -e "${GREEN}Matugen configuration installed${NC}"
fi

# ============================================================
# Step 8: Create wallpaper directory
# ============================================================
echo ""
echo -e "${CYAN}=== Step 8: Wallpaper Directory ===${NC}"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALLPAPER_DIR" ]; then
    mkdir -p "$WALLPAPER_DIR"
    echo -e "${GREEN}Created wallpaper directory: $WALLPAPER_DIR${NC}"
    echo -e "${YELLOW}Please add your wallpapers to this directory${NC}"
else
    echo -e "${GREEN}Wallpaper directory already exists: $WALLPAPER_DIR${NC}"
fi

# ============================================================
# Step 9: Setup hyprpaper
# ============================================================
echo ""
echo -e "${CYAN}=== Step 9: Hyprpaper Setup ===${NC}"

# Check if there are any wallpapers
WALLPAPER_COUNT=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | wc -l)

if [ "$WALLPAPER_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}No wallpapers found in $WALLPAPER_DIR${NC}"
    echo -e "${YELLOW}Please add wallpapers and run: awww img <path-to-wallpaper>${NC}"
else
    FIRST_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -1)
    echo "Found wallpapers. Setting first one as default..."
    # Update hyprpaper.conf with first wallpaper
    if [ -f "$HOME/.config/hypr/hyprpaper.conf" ]; then
        sed -i "s|preload = .*|preload = $FIRST_WALLPAPER|" "$HOME/.config/hypr/hyprpaper.conf"
        sed -i "s|wallpaper = .*|wallpaper = eDP-1,$FIRST_WALLPAPER|" "$HOME/.config/hypr/hyprpaper.conf"
        echo -e "${GREEN}Hyprpaper configured with: $FIRST_WALLPAPER${NC}"
    fi
fi

# ============================================================
# Step 10: Final setup
# ============================================================
echo ""
echo -e "${CYAN}=== Step 10: Final Setup ===${NC}"

# Create savedata directories
mkdir -p "$HOME/.config/quickshell/stellix/savedata"
mkdir -p "$HOME/.config/quickshell/stellix/savedata/cava"

# Generate initial matugen colors if wallpaper exists
if [ "$WALLPAPER_COUNT" -gt 0 ] && cmd_exists matugen; then
    echo "Generating initial Matugen colors..."
    FIRST_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -1)
    "$HOME/.config/matugen/apply-theme.sh" dark "$FIRST_WALLPAPER" "scheme-content" 2>/dev/null || true
    echo -e "${GREEN}Initial Matugen colors generated${NC}"
fi

# ============================================================
# Step 11: Add Quickshell autostart to Hyprland
# ============================================================
echo ""
echo -e "${CYAN}=== Step 11: Quickshell Autostart ===${NC}"

EXECSCONF="$HOME/.config/hypr/hyprland/execs.conf"
AUTOSTART_CMD="exec-once = qs -c $INSTALL_DIR"

if [ -f "$EXECSCONF" ]; then
    if grep -q "qs -c $INSTALL_DIR" "$EXECSCONF" 2>/dev/null; then
        echo -e "${GREEN}Quickshell autostart already configured in execs.conf${NC}"
    else
        echo "Adding Quickshell autostart to Hyprland..."
        echo "" >> "$EXECSCONF"
        echo "# Stellix Shell - Quickshell autostart" >> "$EXECSCONF"
        echo "$AUTOSTART_CMD" >> "$EXECSCONF"
        echo -e "${GREEN}Quickshell autostart added to execs.conf${NC}"
    fi
else
    echo -e "${YELLOW}execs.conf not found at: $EXECSCONF${NC}"
    echo "Please add this line manually to your Hyprland config:"
    echo -e "  ${CYAN}$AUTOSTART_CMD${NC}"
fi

# ============================================================
# Done
# ============================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Stellix Shell Installation Complete!  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "To start Stellix Shell manually, run:"
echo -e "  ${CYAN}qs -c $INSTALL_DIR${NC}"
echo ""
echo "Quickshell autostart has been added to Hyprland (execs.conf)."
echo "It will launch automatically on next Hyprland startup."
echo ""
echo "Enjoy! 🌑"
