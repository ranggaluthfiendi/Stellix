#!/bin/bash
# Material Symbols Font Installer (User-level, no sudo required)
# Downloads and installs all Material Symbols font variants from Arch Linux packages

set -e

FONT_DIR="$HOME/.local/share/fonts/material-symbols"
TEMP_DIR="/tmp/material-symbols-install-$$"

echo "=== Material Symbols Font Installer (User-level) ==="
echo ""

# Create directories
mkdir -p "$FONT_DIR"
mkdir -p "$TEMP_DIR"

# Check if fonts are already installed
EXISTING=$(fc-list | grep -c "Material Symbols" || true)
if [ "$EXISTING" -gt 0 ]; then
    echo "Material Symbols fonts already installed ($EXISTING variants found)"
    read -p "Reinstall anyway? [y/N] " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping installation"
        rm -rf "$TEMP_DIR"
        exit 0
    fi
fi

# Download Arch Linux package
echo "Downloading Material Symbols fonts from Arch Linux..."
curl -fsSL "https://mirror.rackspace.com/archlinux/extra/os/x86_64/ttf-material-symbols-variable-2.874-1-any.pkg.tar.zst" -o "$TEMP_DIR/ttf-material-symbols.pkg.tar.zst"

# Extract package
echo "Extracting fonts..."
tar --zstd -xf "$TEMP_DIR/ttf-material-symbols.pkg.tar.zst" -C "$TEMP_DIR/"

# Find and copy font files
find "$TEMP_DIR" -name "*.ttf" -type f | while read -r font_file; do
    base_name=$(basename "$font_file")
    echo "  Installing: $base_name"
    cp "$font_file" "$FONT_DIR/$base_name"
done

# Clean up
rm -rf "$TEMP_DIR"

# Update font cache
echo ""
echo "Updating font cache..."
fc-cache -fv

# Verify installation
echo ""
echo "=== Verification ==="
fc-list | grep -i "Material Symbols" | sort -u | while read -r line; do
    echo "  ✓ $line"
done

echo ""
echo "=== Installation Complete ==="
echo "Material Symbols fonts are now available with font.family:"
echo '  - "Material Symbols Outlined"'
echo '  - "Material Symbols Rounded"'
echo '  - "Material Symbols Sharp"'
echo ""
echo "Usage in QML:"
echo '  Text { font.family: "Material Symbols Rounded"; text: "home" }'
