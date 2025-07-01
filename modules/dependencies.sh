#!/bin/bash
# modules/dependencies.sh
# Verificação de dependências refatorada para novo sistema de idiomas

# Função principal para verificar dependências
check_dependencies() {
    local dependencies=("ffmpeg" "jq") 
    local missing=()
    
    # Verificar cada dependência
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    # Se houver dependências faltantes
    if [[ ${#missing[@]} -gt 0 ]]; then
        printf "\n${RED}%s${RESET}\n" "$(get_msg missing_dependencies_header)"
        printf "${YELLOW}%s${RESET}\n\n" "$(get_msg missing_dependencies)"
        
        # Mensagem específica para cada dependência faltante
        for dep in "${missing[@]}"; do
            case "$dep" in
                "ffmpeg")
                    printf "  ${RED}➔${RESET} ${BOLD}ffmpeg:${RESET} %s\n" "$(get_msg error_ffmpeg_not_found)"
                    ;;
                "jq")
                    printf "  ${RED}➔${RESET} ${BOLD}jq:${RESET} %s\n" "$(get_msg error_jq_not_found)"
                    ;;
            esac
        done
        
        printf "\n${YELLOW}%s${RESET}\n" "$(get_msg attempt_detect_pkg_manager)"
        suggest_installation "${missing[@]}"
        return 1
    fi
    
    return 0
}

# Sugerir comando de instalação
suggest_installation() {
    local packages=("$@")
    local manager=""
    local command=""
    local found_manager=false

    # Detectar gerenciador de pacotes
    if command -v pacman &>/dev/null; then
        manager="pacman"
        command="sudo pacman -S ${packages[*]}"
        found_manager=true
    elif command -v apt &>/dev/null; then
        manager="apt"
        command="sudo apt update && sudo apt install ${packages[*]}"
        found_manager=true
    elif command -v dnf &>/dev/null; then
        manager="dnf"
        command="sudo dnf install ${packages[*]}"
        found_manager=true
    elif command -v zypper &>/dev/null; then
        manager="zypper"
        command="sudo zypper install ${packages[*]}"
        found_manager=true
    elif command -v emerge &>/dev/null; then
        manager="emerge"
        command="sudo emerge ${packages[*]}"
        found_manager=true
    elif command -v apk &>/dev/null; then
        manager="apk"
        command="sudo apk add ${packages[*]}"
        found_manager=true
    fi

    # Se encontrou um gerenciador
    if $found_manager; then
        printf "\n${BOLD}%s${RESET}\n" "$(get_msg install_with)"
        printf "  ${GREEN}${BOLD}%s${RESET}\n\n" "$command"
    else
        printf "\n${RED}%s${RESET}\n" "$(get_msg error_pkg_manager_not_detected)"
        printf "\n${YELLOW}%s${RESET}\n" "$(get_msg please_install_manually)"
        
        # Instruções manuais para cada pacote
        for dep in "${packages[@]}"; do
            printf "\n  ${CYAN}${BOLD}%s:${RESET}\n" "$dep"
            case "$dep" in
                "ffmpeg")
                    printf "    ${WHITE}%s${RESET}\n" "$(get_msg ffmpeg_manual_install)"
                    ;;
                "jq")
                    printf "    ${WHITE}%s${RESET}\n" "$(get_msg jq_manual_install)"
                    ;;
            esac
        done
    fi
    
    printf "\n${YELLOW}%s${RESET}\n" "$(get_msg after_install_instructions)"
    prompt_enter_continue
}