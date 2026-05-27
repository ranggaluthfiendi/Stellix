#!/bin/bash
# chmod script for Stellix Shell
# Makes all shell scripts executable

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Setting executable permissions for Stellix Shell scripts..."

# Quickshell scripts
chmod +x "$SCRIPT_DIR/scripts/cava_daemon.sh"
chmod +x "$SCRIPT_DIR/scripts/vb-control.sh"

# Matugen scripts
chmod +x "$HOME/.config/matugen/apply-theme.sh" 2>/dev/null || echo "Matugen apply-theme.sh not found"
chmod +x "$HOME/.config/matugen/generate-all-schemes.sh" 2>/dev/null || echo "Matugen generate-all-schemes.sh not found"

# Install script
chmod +x "$SCRIPT_DIR/install.sh"

echo "All scripts are now executable."
