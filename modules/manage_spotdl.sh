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
        fmt_warning "$(get_msg no_local_spotdl)\n"
        
        if prompt_yes_no "$(get_msg download_latest_version)\n"; then
            fmt_info "$(get_msg downloading_latest)\n"
            
            local response
            response=$(curl -s -w "%{http_code}" -o /dev/null https://api.github.com/repos/spotDL/spotify-downloader/releases/latest)
            local status_code=${response: -3}
            
            if [[ "$status_code" != "200" ]]; then
                fmt_error "$(printf "$(get_msg github_api_error)" "$status_code")\n"
                fmt_warning "$(get_msg try_again_later)\n"
                sleep 5
                return 1
            fi

            LATEST_URL=$(curl -s https://api.github.com/repos/spotDL/spotify-downloader/releases/latest | \
                         jq -r '.assets[] | select(.name | test("spotdl-.*-linux")) | .browser_download_url' | head -n1)

            if [[ -z "$LATEST_URL" ]]; then
                fmt_error "$(get_msg could_not_find_link)\n"
                return 1
            fi

            mkdir -p "$BIN_DIR"
            DOWNLOADED_FILE="$BIN_DIR/$(basename "$LATEST_URL")"
            
            if ! curl -L -o "$DOWNLOADED_FILE" "$LATEST_URL"; then
                fmt_error "$(get_msg download_failed)\n"
                fmt_warning "$(get_msg check_connection_or_permissions)\n"
                rm -f "$DOWNLOADED_FILE" 2>/dev/null
                return 1
            fi

            if ! chmod +x "$DOWNLOADED_FILE"; then
                fmt_error "$(get_msg permission_error)\n"
                return 1
            fi

            SPOTDL_CMD="$DOWNLOADED_FILE"

            if DOWNLOADED_VERSION=$("$SPOTDL_CMD" --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'); then
                fmt_success "$(get_msg download_completed): $DOWNLOADED_VERSION\n"
            else
                fmt_warning "$(get_msg version_check_failed)\n"
            fi

            rm -f "$CONFIG_FILE"

            fmt_prompt "$(get_msg press_enter_continue)\n"
            read -n 1 -r -s
        else
            fmt_error "$(get_msg operation_canceled)! $(get_msg no_local_version_available)\n"
            sleep 2
            exit 1
        fi
    fi
}

# Função de atualização do SpotDL
update_spotdl() {
    while true; do
        clear
        fmt_header "$(get_msg menu_update_spotdl)"
        mkdir -p "$BIN_DIR" "$BACKUP_DIR"

        local API_URL="https://api.github.com/repos/spotDL/spotify-downloader/releases/latest"
        local response
        response=$(curl -s "$API_URL")
        
        local remote_version
        remote_version=$(echo "$response" | grep '"tag_name":' | cut -d '"' -f4 | sed 's/^v//')
        local changelog
        changelog=$(echo "$response" | jq -r '.body' | sed 's/\\r\\n/\n/g')
        
        new_file="${APP_NAME}-${remote_version}${FILE_SUFFIX}"

        if [[ -z "${SPOTDL_CMD:-}" || ! -x "$SPOTDL_CMD" ]]; then
            fmt_error "$(get_msg no_local_spotdl)\n"
            fmt_warning "$(get_msg run_script_again)\n"
            return 1
        fi

        local local_version
        local_version=$("$SPOTDL_CMD" --version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

        if [[ "$local_version" == "$remote_version" ]]; then
            fmt_success "$(get_msg spotdl_already_updated): $local_version\n"
            prompt_enter_continue
            return 0
        fi

        fmt_warning "$(get_msg new_version_available): $local_version → $remote_version\n"
        
        local backup_limit backup_count
        backup_limit=$(get_backup_limit)
        backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | wc -l)

        if (( backup_count >= backup_limit )); then
            fmt_error "$(get_msg max_backups_reached) (${backup_count}/${backup_limit})\n"
            fmt_warning "$(get_msg delete_backup_to_update)\n"
            
            if prompt_yes_no "$(get_msg ask_manage_backups)\n"; then
                manage_backups  
                continue
            else
                fmt_error "$(get_msg update_canceled)\n"
                return 1
            fi
        fi

        if prompt_yes_no "$(get_msg update_now)\n"; then
            fmt_info "$(get_msg moving_old_version)\n"
            mv "$SPOTDL_CMD" "$BACKUP_DIR/$(basename "$SPOTDL_CMD")"
            
            fmt_info "$(get_msg backup_created)\n"

            fmt_info "$(get_msg downloading_new_version)...\n"
            
            if curl -fLo "$BIN_DIR/$new_file" "https://github.com/spotDL/spotify-downloader/releases/download/v${remote_version}/${new_file}"; then
                chmod +x "$BIN_DIR/$new_file"
                SPOTDL_CMD="$BIN_DIR/$new_file"
                
                fmt_success "$(printf "$(get_msg update_completed)" "$remote_version")\n"
                
                if [[ -n "$changelog" && "$changelog" != "null" ]]; then
                    newline
                    fmt_header "$(get_msg changelog_title)"
                    echo -e "$changelog\n"
                    fmt_separator
                fi
                
                fmt_error "$(get_msg reboot_script)\n"
                
                prompt_enter_continue
                return 0
            else
                fmt_error "$(get_msg error_downloading_version) $remote_version\n"
                return 1
            fi
        else
            fmt_error "$(get_msg update_canceled).\n"
            return 0
        fi
    done
}

# Obtém o limite máximo de backups do arquivo de configuração
get_backup_limit() {
    local config_file="$HOME/.spotdl-helper/helper-config.json"
    local default_limit=5
    
    if [[ ! -f "$config_file" ]]; then
        fmt_error "$(printf "$(get_msg config_file_not_found)" "$config_file")\n"
        echo "$default_limit"
        return
    fi
    
    local config_value=$(jq -r '.max_backups' "$config_file" 2>/dev/null)
    
    if [[ "$config_value" =~ ^[1-9][0-9]*$ ]]; then
        echo "$config_value"
    else
        fmt_error "$(printf "$(get_msg invalid_max_backups)" "$config_value")\n"
        echo "$default_limit"
    fi
}

# Lista backups e permite interação para deletar
manage_backups() {
    clear
    fmt_header "$(get_msg menu_list_backups)"
    if [[ ! -d "$BACKUP_DIR" ]]; then
        fmt_error "$(get_msg no_backups_dir)\n"
        prompt_enter_continue
        return 1
    fi

    local files=()
    mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -r)
    
    if [[ ${#files[@]} -eq 0 ]]; then
        fmt_error "$(get_msg no_backups_found)\n"
        prompt_enter_continue
        return 1
    fi

    while true; do
        fmt_info "$(get_msg available_backups)\n"
        local i=1
        for file in "${files[@]}"; do
            fmt_option "$i" "$(basename "$file")\n"
            ((i++))
        done

        fmt_info "$(get_msg enter_backup_number_to_delete)\n"
        fmt_info "$(get_msg press_0_to_cancel)\n"
        read -n 1 -r -s choice

        if [[ "$choice" == "0" ]]; then
            return 0
        fi

        if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice <= ${#files[@]} )); then
            local selected_file="${files[$((choice-1))]}"
            if prompt_yes_no "$(get_msg confirm_delete_backup) '$(basename "$selected_file")'?\n"; then
                rm -f "$selected_file"
                if [[ $? -eq 0 ]]; then
                    fmt_success "$(get_msg backup_deleted)\n"
                    mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -r)
                    if [[ ${#files[@]} -eq 0 ]]; then
                        fmt_warning "$(get_msg no_backups_found)\n"
                        break
                    fi
                else
                    fmt_error "$(get_msg error_deleting_backup)\n"
                    return 1
                fi
            else
                fmt_error "$(get_msg operation_canceled)\n"
            fi
        else
            fmt_error "$(get_msg invalid_choice)\n"
            sleep 1
        fi
    done
}

# Restaura backup selecionado
restore_backup() {
    clear
    fmt_header "$(get_msg menu_restore_backup)"
    if [[ ! -d "$BACKUP_DIR" ]]; then
        fmt_error "$(get_msg no_backups_dir)\n"
        prompt_enter_continue
        return 1
    fi

    local files=()
    mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -Vr)

    if [[ ${#files[@]} -eq 0 ]]; then
        fmt_error "$(get_msg no_backups_found)\n"
        prompt_enter_continue
        return 1
    fi

    while true; do
        fmt_info "$(get_msg available_backups)\n"
        
        local i=1
        for file in "${files[@]}"; do
            fmt_option "$i" "$(basename "$file")\n"
            ((i++))
        done

        fmt_info "$(get_msg enter_backup_number) (1-${#files[@]})\n"
        fmt_prompt "$(get_msg press_0_to_cancel)\n"
        
        read -n 1 -r -s choice
        printf "\n"
        
        if [[ "$choice" == "0" ]]; then
            fmt_error "$(get_msg restore_cancelled)\n"
            return 1
        fi

        if [[ "$choice" =~ ^[1-9]$ ]] && (( choice <= ${#files[@]} )); then
            local selected_file="${files[$((choice-1))]}"
            local bin_file="$(basename "$selected_file")"
            local bin_path="$BIN_DIR/$bin_file"

            fmt_info "$(get_msg cleaning_bin)\n"
            rm -f "$BIN_DIR"/* 2>/dev/null || true

            fmt_info "$(get_msg moving_backup)\n"
            mv "$selected_file" "$bin_path"
            chmod +x "$bin_path"

            fmt_success "$(get_msg backup_restored)\n"
            fmt_error "$(get_msg reboot_script)\n"
            
            prompt_enter_continue
            return 0
        else
            fmt_error "$(get_msg invalid_choice)\n"
            sleep 1
        fi
    done
}
