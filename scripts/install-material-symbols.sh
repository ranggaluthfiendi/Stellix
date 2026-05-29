#!/bin/bash
# Material Symbols Font Installer
# Downloads and installs all Material Symbols font variants from Google Fonts

set -e

FONT_DIR="/usr/share/fonts/material-symbols"
TEMP_DIR="/tmp/material-symbols-install"

echo "=== Material Symbols Font Installer ==="
echo ""

# Create directories
sudo mkdir -p "$FONT_DIR"
mkdir -p "$TEMP_DIR"

# Material Symbols font variants to download
declare -A FONTS=(
    ["MaterialSymbolsOutlined"]="https://fonts.google.com/download?family=Material+Symbols+Outlined"
    ["MaterialSymbolsRounded"]="https://fonts.google.com/download?family=Material+Symbols+Rounded"
    ["MaterialSymbolsSharp"]="https://fonts.google.com/download?family=Material+Symbols+Sharp"
)

for name in "${!FONTS[@]}"; do
    url="${FONTS[$name]}"
    echo "Downloading $name..."
    
    # Download the zip file
    curl -fsSL "$url" -o "$TEMP_DIR/${name}.zip"
    
    # Extract
    echo "Extracting $name..."
    unzip -o "$TEMP_DIR/${name}.zip" -d "$TEMP_DIR/${name}" > /dev/null 2>&1
    
    # Find and copy TTF/OTF files
    find "$TEMP_DIR/${name}" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.TTF" -o -name "*.OTF" \) | while read -r font_file; do
        base_name=$(basename "$font_file")
        echo "  Installing: $base_name"
        sudo cp "$font_file" "$FONT_DIR/$base_name"
    done
    
    # Clean up extracted files
    rm -rf "$TEMP_DIR/${name}"
done

# Clean up zip files
rm -f "$TEMP_DIR"/*.zip

# Update font cache
echo ""
echo "Updating font cache..."
sudo fc-cache -fv

# Verify installation
echo ""
echo "=== Verification ==="
fc-list | grep -i "Material Symbols" | while read -r line; do
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
