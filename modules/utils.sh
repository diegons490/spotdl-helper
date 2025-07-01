#!/bin/bash
# modules/utils.sh
# Funções gerais e reutilizáveis não interativas

# Definições de cores
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
RED="\033[31;1m"
CYAN="\033[36;1m"
BLUE="\033[34;1m"
MAGENTA="\033[35;1m"
GRAY="\033[37;1m"
WHITE="\033[97;1m"
BOLD="\033[1m"
RESET="\033[0m"


# Desativa 'set -e' temporariamente para executar comandos sem encerrar o script em erro
disable_set_e() {
    set +e
    "$@"
    local status=$?
    set -e
    return $status
}

# Imprime um cabeçalho formatado
print_header() {
    local title="$1"
    printf "\n${CYAN}===========================================${RESET}\n"
    printf "${BOLD}${CYAN}%s${RESET}\n" "$title"
    printf "${CYAN}===========================================${RESET}\n"
}

# Adicione esta função no final do arquivo
prompt_yes_no() {
    local prompt_msg="$1"
    local choice

    while true; do
        printf "\n${BOLD}%s [${YELLOW}%s${RESET}/${YELLOW}%s${RESET}]: " \
            "$prompt_msg" "$(get_msg yes_char)" "$(get_msg no_char)"
        read -r choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            "$(get_msg yes_char)")
                return 0
                ;;
            "$(get_msg no_char)")
                return 1
                ;;
            *)
                printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option_msg)"
                ;;
        esac
    done
}

# Função auxiliar para perguntas sim/não
ask_to_edit() {
    local key="$1"
    local prompt_msg="$2"
    local current_value="${editable_config[$key]}"
    local current_char
    
    # Converter true/false para s/n
    [[ "$current_value" == "true" ]] && current_char="s" || current_char="n"
    
    while true; do
        printf "\n${BOLD}%s ${YELLOW}[%s]${RESET}: " "$prompt_msg" "$current_char"
        read -n 1 -r input
        
        # Se pressionar Enter, mantém o valor atual
        if [[ -z "$input" ]]; then
            break
        fi
        
        input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
        
        case "$input" in
            "s")
                editable_config[$key]="true"
                break
                ;;
            "n")
                editable_config[$key]="false"
                break
                ;;
            *)
                printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option_msg)"
                ;;
        esac
    done
}