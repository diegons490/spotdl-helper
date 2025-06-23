#!/bin/bash
set -e

REPO_URL="https://github.com/diegons490/spotdl-helper"
INSTALL_DIR="$HOME/.local/bin/spotdl-helper"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_NAME="spotdl-helper.icon"
SCRIPT_NAME="spotdl-helper.sh"
LAUNCHER_NAME="spotdl-helper.desktop"

echo "Installing SpotDL Helper..."

# Criar diretórios necessários
mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR"

# Copiar arquivos locais ou clonar repo
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

# Tornar script executável
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Detectar terminal instalado
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

if [[ -z "$TERMINAL" ]]; then
    echo "Warning: No terminal emulator found, defaulting to xterm."
    TERMINAL="xterm"
fi

case "$(basename "$TERMINAL")" in
    gnome-terminal|xfce4-terminal|mate-terminal|tilix)
        TERMINAL_CMD="--"
        ;;
    konsole)
        TERMINAL_CMD="-e"
        ;;
    *)
        TERMINAL_CMD="-e"
        ;;
esac

# Criar atalho .desktop com PATH e terminal correto, sem link simbólico
cat > "$DESKTOP_DIR/$LAUNCHER_NAME" <<EOF
[Desktop Entry]
Name=SpotDL Helper
Exec=$TERMINAL $TERMINAL_CMD bash -c "$INSTALL_DIR/$SCRIPT_NAME; exec bash"
Icon=$INSTALL_DIR/$ICON_NAME
Terminal=true
Type=Application
Categories=AudioVideo;Utility;
EOF


chmod +x "$DESKTOP_DIR/$LAUNCHER_NAME"

echo "Installation complete!"
echo "You can launch SpotDL Helper from your application menu."
echo "To run from terminal, execute:"
echo "  bash \"$INSTALL_DIR/$SCRIPT_NAME\""
