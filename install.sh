#!/bin/bash
set -euo pipefail

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"
BOLD="\033[1m"

# Main directories
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/spotdl-helper"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$INSTALL_DIR/icons"
ICON_NAME="spotdl-helper.icon"
DESKTOP_FILE="$DESKTOP_DIR/spotdl-helper.desktop"
LAUNCHER_SOURCE="$INSTALL_DIR/launcher.sh"

printf "${BOLD}${CYAN}Installing SpotDL Helper...${RESET}\n"

# Create destination directories
mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$ICON_DIR"

# Copy all files
cp -r "$SRC_DIR/"* "$INSTALL_DIR/"

# Check essential files
if [[ ! -f "$LAUNCHER_SOURCE" ]]; then
    printf "${RED}Error:${RESET} Launcher not found at $LAUNCHER_SOURCE\n"
    exit 1
fi

# Adjust permissions
chmod +x "$LAUNCHER_SOURCE"
chmod +x "$INSTALL_DIR/uninstall.sh"
find "$INSTALL_DIR/modules" -name '*.sh' -exec chmod +x {} \;

# SpotDL binaries
if [[ -d "$INSTALL_DIR/bin" ]]; then
    find "$INSTALL_DIR/bin" -type f -exec chmod +x {} \;
fi
if [[ -d "$INSTALL_DIR/bkp_spotdl" ]]; then
    find "$INSTALL_DIR/bkp_spotdl" -type f -exec chmod +x {} \;
fi
for file in "$INSTALL_DIR"/spotdl-*; do
    if [[ -f "$file" ]]; then
        chmod +x "$file"
    fi
done

# Create .desktop shortcut (without opening extra terminal)
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=SpotDL Helper
Comment=Download your music with SpotDL
Exec=bash -c '$LAUNCHER_SOURCE > /dev/null 2>&1'
Icon=$ICON_DIR/$ICON_NAME
Terminal=false
Categories=Audio;Utility;
EOF

chmod +x "$DESKTOP_FILE"

# Done
printf "\n${BOLD}${GREEN}Installation completed successfully!${RESET}\n"
printf "${CYAN}Application files:${RESET}        %s\n" "$INSTALL_DIR"
printf "${CYAN}Desktop shortcut created:${RESET} %s\n" "$DESKTOP_FILE"
printf "${CYAN}Icon referenced:${RESET}          %s/%s\n" "$ICON_DIR" "$ICON_NAME"
