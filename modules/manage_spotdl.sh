#!/bin/bash
# modules/manage_spotdl.sh
# Gerenciamento do SpotDL refatorado

# Paths e variáveis importantes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/bkp_spotdl"
BIN_DIR="$PROJECT_ROOT/bin"
APP_NAME="spotdl"
FILE_SUFFIX="-linux"

# Função para verificar o spotDL
check_spotdl() {
    local project_root
    project_root="$(dirname "$SCRIPT_DIR")"
    LOCAL_BINARY=$(ls "$project_root/bin"/spotdl-*-linux 2>/dev/null | sort -V | tail -n1 || true)

    if [[ -x "$LOCAL_BINARY" ]]; then
        SPOTDL_CMD="$LOCAL_BINARY"
    else
        clear
        printf "\n${YELLOW}%s${RESET}\n" "$(get_msg no_local_spotdl)"
        
        if prompt_yes_no "$(get_msg download_latest_version)"; then
            printf "${CYAN}\n%s${RESET}\n" "$(get_msg downloading_latest)"
            
            # Tentar obter URL do release com tratamento de erros
            local response
            response=$(curl -s -w "%{http_code}" -o /dev/null https://api.github.com/repos/spotDL/spotify-downloader/releases/latest)
            local status_code=${response: -3}  # Últimos 3 caracteres são o código HTTP
            
            # Verificar se a API está respondendo
            if [[ "$status_code" != "200" ]]; then
                printf "\n${RED}%s${RESET}\n" "$(printf "$(get_msg github_api_error)" "$status_code")"
                printf "${YELLOW}%s${RESET}\n\n" "$(get_msg try_again_later)"
                sleep 5
                return 1
            fi

            # Obter URL de download
            LATEST_URL=$(curl -s https://api.github.com/repos/spotDL/spotify-downloader/releases/latest | \
                         jq -r '.assets[] | select(.name | test("spotdl-.*-linux")) | .browser_download_url' | head -n1)

            if [[ -z "$LATEST_URL" ]]; then
                printf "\n${RED}%s${RESET}\n" "$(get_msg could_not_find_link)"
                return 1
            fi

            # Criar diretório e baixar
            mkdir -p "$BIN_DIR"
            DOWNLOADED_FILE="$BIN_DIR/$(basename "$LATEST_URL")"
            
            # Tentar download com tratamento de erros
            if ! curl -L -o "$DOWNLOADED_FILE" "$LATEST_URL"; then
                printf "\n${RED}%s${RESET}\n" "$(get_msg download_failed)"
                printf "${YELLOW}%s${RESET}\n\n" "$(get_msg check_connection_or_permissions)"
                rm -f "$DOWNLOADED_FILE" 2>/dev/null
                return 1
            fi

            # Tornar executável
            if ! chmod +x "$DOWNLOADED_FILE"; then
                printf "\n${RED}%s${RESET}\n" "$(get_msg permission_error)"
                return 1
            fi

            SPOTDL_CMD="$DOWNLOADED_FILE"

            # Verificar versão instalada
            if DOWNLOADED_VERSION=$("$SPOTDL_CMD" --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'); then
                printf "\n${GREEN}%s: %s${RESET}\n" "$(get_msg download_completed)" "$DOWNLOADED_VERSION"
            else
                printf "\n${YELLOW}%s${RESET}\n" "$(get_msg version_check_failed)"
            fi

            rm -f "$CONFIG_FILE"

            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -n 1 -r -s
            printf "\n"
        else
            printf "\n${RED}%s! %s${RESET}\n\n" "$(get_msg operation_canceled)" "$(get_msg no_local_version_available)"
            sleep 2
            exit 1
        fi
    fi
}

update_spotdl() {
    while true; do
        clear
        print_section_header "$(get_msg menu_update_spotdl)"
        mkdir -p "$BIN_DIR" "$BACKUP_DIR"

        # Obter versão remota
        local API_URL="https://api.github.com/repos/spotDL/spotify-downloader/releases/latest"
        local remote_version new_file
        remote_version=$(curl -s "$API_URL" | grep '"tag_name":' | cut -d '"' -f4 | sed 's/^v//')
        new_file="${APP_NAME}-${remote_version}${FILE_SUFFIX}"

        # Verificar binário local
        if [[ -z "${SPOTDL_CMD:-}" || ! -x "$SPOTDL_CMD" ]]; then
            printf "\n${RED}%s${RESET}\n" "$(get_msg no_local_spotdl)"
            printf "\n${YELLOW}%s${RESET}\n" "$(get_msg run_script_again)"
            return 1
        fi

        # Comparar versões
        local local_version
        local_version=$("$SPOTDL_CMD" --version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

        if [[ "$local_version" == "$remote_version" ]]; then
            printf "\n${GREEN}%s: %s${RESET}\n" "$(get_msg spotdl_already_updated)" "$local_version"
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -n 1 -r -s
            printf "\n"
            return 0
        fi

        printf "\n${YELLOW}%s:${RED} %s ${YELLOW}---> ${GREEN}%s${RESET}\n" \
            "$(get_msg new_version_available)" "$local_version" "$remote_version"

        # Verificar limite de backups
        local backup_limit backup_count
        backup_limit=$(get_backup_limit)
        backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | wc -l)

        if (( backup_count >= backup_limit )); then
            printf "\n${RED}%s (${backup_count}/${backup_limit})${RESET}\n" "$(get_msg max_backups_reached)"
            printf "${YELLOW}%s${RESET}\n" "$(get_msg delete_backup_to_update)"
            
            if prompt_yes_no "$(get_msg ask_manage_backups)"; then
                manage_backups  
                continue
            else
                printf "\n${RED}%s${RESET}\n" "$(get_msg update_canceled)"
                return 1
            fi
        fi

        if prompt_yes_no "$(get_msg update_now)"; then
            # Mover versão atual para backup
            printf "\n${BLUE}%s${RESET}\n" "$(get_msg moving_old_version)"
            mv "$SPOTDL_CMD" "$BACKUP_DIR/$(basename "$SPOTDL_CMD")"
            
            # CORREÇÃO: Mensagem de backup criado
            printf "\n${YELLOW}%s${RESET}\n" "$(get_msg backup_created)"

            # Baixar nova versão
            printf "\n${YELLOW}%s...${RESET}\n\n" "$(get_msg downloading_new_version)"
            
            if curl -fLo "$BIN_DIR/$new_file" "https://github.com/spotDL/spotify-downloader/releases/download/v${remote_version}/${new_file}"; then
                chmod +x "$BIN_DIR/$new_file"
                SPOTDL_CMD="$BIN_DIR/$new_file"
                
                # CORREÇÃO: Mensagem de atualização concluída
                printf "\n${GREEN}%s${RESET}\n" "$(printf "$(get_msg update_completed)" "$remote_version")"
                printf "\n${RED}%s${RESET}\n" "$(get_msg reboot_script)"
                
                printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
                read -n 1 -r -s
                printf "\n"
                return 0
            else
                printf "\n${RED}%s %s${RESET}\n" "$(get_msg error_downloading_version)" "$remote_version"
                return 1
            fi
        else
            printf "\n${RED}%s.${RESET}\n" "$(get_msg update_canceled)"
            return 0
        fi
    done
}

# Obtém o limite máximo de backups do arquivo de configuração
get_backup_limit() {
    # Caminho absoluto e correto do arquivo de configuração
    local config_file="$HOME/.spotdl-helper/helper-config.json"
    local default_limit=5
    
    # Verifica se o arquivo existe
    if [[ ! -f "$config_file" ]]; then
        printf "Arquivo de configuração não encontrado: %s\n" "$config_file" >&2
        echo "$default_limit"
        return
    fi
    
    # Tenta extrair o valor
    local config_value=$(jq -r '.max_backups' "$config_file" 2>/dev/null)
    
    # Valida se é número positivo
    if [[ "$config_value" =~ ^[1-9][0-9]*$ ]]; then
        echo "$config_value"
    else
        printf "Valor inválido para max_backups: '%s'\n" "$config_value" >&2
        echo "$default_limit"
    fi
}

# Lista backups e permite interação para deletar
manage_backups() {
    print_section_header "$(get_msg menu_update_spotdl)"
    # Verificar se o diretório existe
    if [[ ! -d "$BACKUP_DIR" ]]; then
        printf "\n${RED}%s${RESET}\n" "$(get_msg no_backups_dir)"
        # Substituição do prompt_enter_continue
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -n 1 -r -s
        printf "\n"
        return 1
    fi

    # Listar arquivos de backup
    local files=()
    mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -r)
    
    if [[ ${#files[@]} -eq 0 ]]; then
        printf "\n${RED}%s${RESET}\n" "$(get_msg no_backups_found)"
        # Substituição do prompt_enter_continue
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -n 1 -r -s
        printf "\n"
        return 1
    fi

    while true; do
        clear
        printf "\n${CYAN}%s${RESET}\n" "$(get_msg available_backups)"
        local i=1
        for file in "${files[@]}"; do
            printf "  ${YELLOW}%d)${RESET} %s\n" "$i" "$(basename "$file")"
            ((i++))
        done

        printf "\n${CYAN}%s${RESET}\n" "$(get_msg enter_backup_number_to_delete)"
        printf "${CYAN}%s${RESET}\n" "$(get_msg press_0_to_cancel)"
        read -n 1 -r -s choice

        if [[ "$choice" == "0" ]]; then
            return 0
        fi

        if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice <= ${#files[@]} )); then
            local selected_file="${files[$((choice-1))]}"
            if prompt_yes_no "$(get_msg confirm_delete_backup) '$(basename "$selected_file")'?"; then
                rm -f "$selected_file"
                if [[ $? -eq 0 ]]; then
                    printf "\n${GREEN}%s${RESET}\n" "$(get_msg backup_deleted)"
                    # Atualizar a lista após deletar
                    mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -r)
                    if [[ ${#files[@]} -eq 0 ]]; then
                        printf "\n${YELLOW}%s${RESET}\n" "$(get_msg no_backups_found)"
                        break
                    fi
                else
                    printf "\n${RED}%s${RESET}\n" "$(get_msg error_deleting_backup)"
                    return 1
                fi
            else
                printf "\n${RED}%s${RESET}\n" "$(get_msg operation_canceled)"
            fi
        else
            printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_choice)"
            sleep 1
        fi
    done
}

# Restaura backup selecionado
restore_backup() {
    print_section_header "$(get_msg menu_update_spotdl)"
    # Verificar se o diretório de backups existe
    if [[ ! -d "$BACKUP_DIR" ]]; then
        printf "\n${RED}%s${RESET}\n" "$(get_msg no_backups_dir)"
        # Substituição do prompt_enter_continue
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -n 1 -r -s
        printf "\n"
        return 1
    fi

    # Listar backups disponíveis
    local files=()
    mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -Vr)

    if [[ ${#files[@]} -eq 0 ]]; then
        printf "\n${RED}%s${RESET}\n" "$(get_msg no_backups_found)"
        # Substituição do prompt_enter_continue
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -n 1 -r -s
        printf "\n"
        return 1
    fi

    while true; do
        clear
        printf "\n${CYAN}%s${RESET}\n" "$(get_msg available_backups)"
        
        # Mostrar backups com numeração
        local i=1
        for file in "${files[@]}"; do
            printf "  ${YELLOW}%d)${RESET} %s\n" "$i" "$(basename "$file")"
            ((i++))
        done

        printf "\n${CYAN}%s ${YELLOW}(1-%d)${RESET}\n" "$(get_msg enter_backup_number)" "${#files[@]}"
        printf "${CYAN}%s ${RESET}" "$(get_msg press_0_to_cancel)"
        
        # Ler escolha do usuário
        read -n 1 -r -s choice
        printf "\n"
        
        # Verificar se o usuário quer cancelar
        if [[ "$choice" == "0" ]]; then
            printf "\n${RED}%s${RESET}\n" "$(get_msg restore_cancelled)"
            return 1
        fi

        # Validar escolha
        if [[ "$choice" =~ ^[1-9]$ ]] && (( choice <= ${#files[@]} )); then
            local selected_file="${files[$((choice-1))]}"
            local bin_file="$(basename "$selected_file")"
            local bin_path="$BIN_DIR/$bin_file"

            # Limpar diretório bin
            printf "\n${YELLOW}%s${RESET}\n" "$(get_msg cleaning_bin)"
            rm -f "$BIN_DIR"/* 2>/dev/null || true

            # Mover backup para bin
            printf "\n${YELLOW}%s${RESET}\n" "$(get_msg moving_backup)"
            mv "$selected_file" "$bin_path"
            chmod +x "$bin_path"

            # Mensagem de sucesso
            printf "\n${GREEN}%s${RESET}\n" "$(get_msg backup_restored)"
            printf "\n${RED}%s${RESET}\n" "$(get_msg reboot_script)"
            
            # Substituição do prompt_enter_continue
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -n 1 -r -s
            printf "\n"
            return 0
        else
            printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_choice)"
            sleep 1
        fi
    done
}

# Menu de gerenciamento do SpotDL
manage_spotdl_menu() {
    while true; do
        clear
        print_section_header "$(get_msg menu_option6)"

        echo "1) $(get_msg menu_update_spotdl)"
        echo "2) $(get_msg menu_restore_backup)"
        echo "3) $(get_msg menu_manage_backups)"
        echo "0) $(get_msg menu_return_main)"
        echo
        printf "${YELLOW}%s:${RESET} " "$(get_msg choose_option)"
        read -n 1 -r choice
        echo

        case "$choice" in
            1) 
                update_spotdl 
                ;;
            2) 
                restore_backup  
                ;;
            3)
                manage_backups
                ;;
            0) return ;;
            *) 
                printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option)"
                sleep 1 
                ;;
        esac
    done
}
