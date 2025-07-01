#!/bin/bash
# modules/launcher.sh
# Responsável por abrir o script no terminal corretamente

# Diretório onde o launcher.sh está localizado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Caminho para o main.sh dentro da pasta modules
SCRIPT_PATH="$SCRIPT_DIR/modules/main.sh"

# Função para executar o script no terminal
run_in_terminal() {
    local term_cmd="$1"
    case "$term_cmd" in
        konsole)
            konsole -e bash -c "$SCRIPT_PATH"
            ;;
        yakuake)
            yakuake -e bash -c "$SCRIPT_PATH"
            ;;
        gnome-terminal)
            gnome-terminal -- bash -c "$SCRIPT_PATH"
            ;;
        kgx)
            kgx bash -c "$SCRIPT_PATH"
            ;;
        tilix)
            tilix -e bash -c "$SCRIPT_PATH"
            ;;
        xfce4-terminal)
            xfce4-terminal -e "bash -c '$SCRIPT_PATH'"
            ;;
        lxterminal)
            lxterminal -e bash -c "$SCRIPT_PATH"
            ;;
        terminator)
            terminator -x bash -c "$SCRIPT_PATH"
            ;;
        alacritty)
            alacritty -e bash -c "$SCRIPT_PATH"
            ;;
        kitty)
            kitty bash -c "$SCRIPT_PATH"
            ;;
        xterm)
            xterm -e bash -c "$SCRIPT_PATH"
            ;;
        urxvt)
            urxvt -e bash -c "$SCRIPT_PATH"
            ;;
        eterm)
            eterm -e bash -c "$SCRIPT_PATH"
            ;;
        mate-terminal)
            mate-terminal -e bash -c "$SCRIPT_PATH"
            ;;
        *)
            echo "Terminal emulator not supported: $term_cmd"
            exit 1
            ;;
    esac
}

# Lista ordenada de terminais por prioridade
TERMINALS=(
    konsole yakuake tilix
    gnome-terminal kgx
    xfce4-terminal lxterminal terminator
    alacritty kitty xterm urxvt eterm mate-terminal
)

# Verifica e executa no primeiro terminal compatível encontrado
for term in "${TERMINALS[@]}"; do
    if command -v "$term" &>/dev/null; then
        run_in_terminal "$term"
        exit 0
    fi
done

echo "No compatible terminal emulator found."
exit 1
