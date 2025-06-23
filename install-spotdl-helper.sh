#!/bin/bash
set -e

REPO_URL="https://github.com/diegons490/spotdl-helper"
INSTALL_DIR="$HOME/.local/share/spotdl-helper"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_NAME="spotdl-helper.icon"
SCRIPT_NAME="spotdl-helper.sh"
LAUNCHER_NAME="spotdl-helper.desktop"

echo "Installing SpotDL Helper..."

# Ensure required directories
mkdir -p "$BIN_DIR" "$DESKTOP_DIR"

# If already running from a git clone, copy files directly
if [[ -f "$SCRIPT_NAME" && -f "$ICON_NAME" && -d "lang" ]]; then
    echo "Using local files..."
    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    cp -r ./* "$INSTALL_DIR"
else
    echo "Downloading files from repository..."
    rm -rf "$INSTALL_DIR"
    git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# Create executable symlink
ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$BIN_DIR/spotdl-helper"
chmod +x "$BIN_DIR/spotdl-helper"

# Detect terminal
TERMINAL=$(command -v x-terminal-emulator || \
           command -v gnome-terminal || \
           command -v konsole || \
           command -v xfce4-terminal || \
           command -v mate-terminal || \
           command -v lxterminal || \
           command -v tilix || \
           command -v alacritty || \
           command -v kitty || \
           command -v xterm)

# Create .desktop launcher
cat > "$DESKTOP_DIR/$LAUNCHER_NAME" <<EOF
[Desktop Entry]
Name=SpotDL Helper
Exec=$TERMINAL -e spotdl-helper
Icon=$INSTALL_DIR/$ICON_NAME
Terminal=false
Type=Application
Categories=AudioVideo;Utility;
EOF

chmod +x "$DESKTOP_DIR/$LAUNCHER_NAME"

echo "Installation complete!"
echo "You can launch SpotDL Helper from your app menu or by running: spotdl-helper"
