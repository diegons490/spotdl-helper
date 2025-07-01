#!/bin/bash
# modules/config.sh
# Gerenciamento de configurações refatorado para novo sistema de arquivos

# Configurações editáveis (apenas para spotDL)
declare -A editable_config=(
    [format]="mp3"
    [bitrate]="256k"
    [generate_lrc]="true"
    [skip_album_art]="false"
    [threads]="3"
    [sync_without_deleting]="false"
    [sync_remove_lrc]="false"
    [overwrite]="skip"  # Nova opção
)

# Variáveis globais para configurações do helper
CURRENT_LANG="pt_BR"
FINAL_DIR="$DOWNLOADS_DIR/SpotDL"
MAX_BACKUPS=5

# Carrega configurações do helper
load_helper_config() {
    if [[ -f "$HELPER_CONFIG" ]]; then
        CURRENT_LANG=$(jq -r '.language // empty' "$HELPER_CONFIG")
        FINAL_DIR=$(jq -r '.download_path // empty' "$HELPER_CONFIG")
        MAX_BACKUPS=$(jq -r '.max_backups // empty' "$HELPER_CONFIG")
    fi
    
    # Valores padrão se não encontrados
    [[ -z "$CURRENT_LANG" ]] && CURRENT_LANG="pt_BR"
    [[ -z "$FINAL_DIR" ]] && FINAL_DIR="$DOWNLOADS_DIR/SpotDL"
    [[ -z "$MAX_BACKUPS" ]] && MAX_BACKUPS=5
    
    # Se o arquivo não existe, cria com valores padrão
    if [[ ! -f "$HELPER_CONFIG" ]]; then
        save_helper_config
    fi
}

# Salva configurações do helper
save_helper_config() {
    mkdir -p "$HELPER_CONFIG_DIR"
    cat > "$HELPER_CONFIG" <<EOF
{
    "language": "$CURRENT_LANG",
    "download_path": "$FINAL_DIR",
    "max_backups": $MAX_BACKUPS
}
EOF
}

# Carrega configurações do spotDL
load_spotdl_config() {
    if [[ -f "$SPOTDL_CONFIG" ]]; then
        for key in "${!editable_config[@]}"; do
            value=$(jq -r --arg k "$key" '.[$k] // empty' "$SPOTDL_CONFIG")
            if [[ -n "$value" && "$value" != "null" ]]; then
                editable_config[$key]="$value"
            fi
        done
    else
        # Se o arquivo não existe, cria com valores padrão
        save_spotdl_config
    fi
}

# Salva configurações do spotDL
save_spotdl_config() {
    mkdir -p "$(dirname "$SPOTDL_CONFIG")"
    local output_template="${FINAL_DIR}/{artist}/{album}/{title}.{output-ext}"

    # Corrige problemas de escape no JSON
    output_template=$(echo "$output_template" | sed 's/\\/\\\\/g')

    cat > "$SPOTDL_CONFIG" <<EOF
{
    "client_id": "5f573c9620494bae87890c0f08a60293",
    "client_secret": "212476d9b0f3472eaa762d90b19b0ba8",
    "auth_token": null,
    "user_auth": false,
    "headless": false,
    "no_cache": false,
    "max_retries": 3,
    "use_cache_file": false,
    "audio_providers": ["youtube-music"],
    "lyrics_providers": ["genius", "azlyrics", "musixmatch"],
    "genius_token": "alXXDbPZtK1m2RrZ8I4k2Hn8Ahsd0Gh_o076HYvcdlBvmc0ULL1H8Z8xRlew5qaG",
    "playlist_numbering": false,
    "playlist_retain_track_cover": false,
    "scan_for_songs": false,
    "m3u": null,
    "overwrite": "${editable_config[overwrite]}",
    "search_query": null,
    "ffmpeg": "ffmpeg",
    "bitrate": "${editable_config[bitrate]}",
    "ffmpeg_args": null,
    "format": "${editable_config[format]}",
    "threads": ${editable_config[threads]},
    "save_file": null,
    "filter_results": true,
    "album_type": null,
    "cookie_file": null,
    "restrict": null,
    "print_errors": false,
    "sponsor_block": true,
    "preload": false,
    "archive": null,
    "load_config": true,
    "log_level": "INFO",
    "simple_tui": false,
    "fetch_albums": false,
    "id3_separator": "/",
    "ytm_data": false,
    "add_unavailable": false,
    "generate_lrc": ${editable_config[generate_lrc]},
    "force_update_metadata": false,
    "only_verified_results": false,
    "sync_without_deleting": ${editable_config[sync_without_deleting]},
    "max_filename_length": null,
    "yt_dlp_args": null,
    "detect_formats": null,
    "save_errors": null,
    "ignore_albums": null,
    "proxy": null,
    "skip_explicit": false,
    "log_format": null,
    "redownload": false,
    "skip_album_art": ${editable_config[skip_album_art]},
    "create_skip_file": false,
    "respect_skip_file": false,
    "sync_remove_lrc": ${editable_config[sync_remove_lrc]},
    "web_use_output_dir": false,
    "port": 8800,
    "host": "localhost",
    "keep_alive": false,
    "enable_tls": false,
    "key_file": null,
    "cert_file": null,
    "ca_file": null,
    "allowed_origins": null,
    "keep_sessions": false,
    "force_update_gui": false,
    "web_gui_repo": null,
    "web_gui_location": null,
    "output": "$output_template"
}
EOF
}

# Função principal para carregar configurações
load_config() {
    load_helper_config
    load_spotdl_config
    load_ui_strings "$CURRENT_LANG"
    
    # Mostrar configurações carregadas
    printf "\n${CYAN}%s${RESET}\n" "$(get_msg loaded_config)"
    printf " ${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_language)" "$CURRENT_LANG"
    printf " ${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_download_path)" "$FINAL_DIR"
    printf " ${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_max_backups)" "$MAX_BACKUPS"
    printf " ${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_audio_format)" "${editable_config[format]}"
    printf " ${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_bitrate)" "${editable_config[bitrate]}"
    printf " ${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_generate_lyrics)" "${editable_config[generate_lrc]}"
    echo -e "================================${RESET}\n"
}

# Menu de configurações interativo
edit_config_interactively() {
    local language_changed=false

    while true; do
        clear
        print_section_header "$(get_msg menu_option5)"

        printf "\n${BLUE}$(printf "$(get_msg info_current_config)" "${YELLOW}${BOLD}[x]${RESET}${BLUE}")${RESET}\n"

        # Seleção de idioma
        printf "\n${BOLD}$(printf "$(get_msg current_language)" "${YELLOW}${BOLD}[${CURRENT_LANG}]${RESET}${BOLD}")${RESET}\n"
        printf "\n${YELLOW}1)${RESET} Português Brasil   (pt_BR)"
        printf "\n${YELLOW}2)${RESET} English            (en_US)"
        printf "\n${YELLOW}3)${RESET} Español            (es_ES)"
        printf "\n\n${BOLD}%s ${RESET}" "$(get_msg choose_language)"
        read -n 1 -r lang_choice

        case "$lang_choice" in
            1) 
                CURRENT_LANG="pt_BR"
                language_changed=true
                ;;
            2) 
                CURRENT_LANG="en_US"
                language_changed=true
                ;;
            3) 
                CURRENT_LANG="es_ES"
                language_changed=true
                ;;
            "") 
                printf "\n${YELLOW}%s${RESET}\n" "$(printf "$(get_msg language_set)" "$CURRENT_LANG") $(get_msg config_kept_suffix)"
                ;;
            *) 
                printf "\n\n${RED}%s${RESET}\n" "$(get_msg invalid_choice)"
                sleep 1.5
                continue
                ;;
        esac

        if $language_changed; then
            load_ui_strings "$CURRENT_LANG"
            save_helper_config
            printf "\n${GREEN}$(printf "$(get_msg language_set)" "$CURRENT_LANG")${RESET}\n"
            language_changed=false
        fi

        # Pausa e sai do loop de idioma
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -r
        clear
        break
    done

    # Caminho de download
    print_section_header "$(get_msg menu_option5)"
    printf "\n${BOLD}%s ${YELLOW}[%s]${RESET}: " "$(get_msg base_download_path)" "$FINAL_DIR"
    read -r input
    if [[ -n "$input" ]]; then
        FINAL_DIR="$input"
        printf "\n${GREEN}$(printf "$(get_msg download_path_updated)" "$input")${RESET}\n"
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -r
    else
        printf "\n${YELLOW}$(printf "$(get_msg config_kept_path)" "$FINAL_DIR")${RESET}\n"
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -r
        clear
    fi

    # Função auxiliar para opções enumeradas
    handle_enumerated_option() {
    local kept_message="$1"
    local current_value="$2"
    local valid_options=("${!3}")
    local success_message="$4"
    local prompt_msg="$5"
    
    while true; do
        # Limpa a tela
        clear > /dev/tty
        
        # Exibir prompt e opções
        {   
            print_section_header "$(get_msg menu_option5)"
            printf "\n${BOLD}%s${RESET}\n" "$(printf "$prompt_msg" "${valid_options[*]}")"
            printf "${YELLOW}%s [%s]${RESET}\n\n" "$(get_msg current_value)" "$current_value"
            
            # Mostrar opções numeradas
            for i in "${!valid_options[@]}"; do
                printf "${YELLOW}%d)${RESET} %s\n" "$((i+1))" "${valid_options[$i]}"
            done
            
            printf "\n${BOLD}%s ${YELLOW}[1-%d]${RESET}: " "$(get_msg choose_option)" "${#valid_options[@]}"
        } > /dev/tty
        
        # Ler tecla única
        read -n 1 -r input < /dev/tty
        printf "\n" > /dev/tty
        
        # Verificar se o usuário quer manter o atual
        if [[ -z "$input" ]]; then
            printf "${YELLOW}$(printf "$kept_message" "$current_value")${RESET}\n" > /dev/tty
            echo "$current_value"
            return
        fi
        
        # Verificar se a entrada é um número válido
        if [[ "$input" =~ ^[1-9]$ ]]; then
            local selected_index=$((input-1))
            
            if [[ $selected_index -lt ${#valid_options[@]} ]]; then
                printf "\n${GREEN}$(printf "$success_message" "${valid_options[$selected_index]}")${RESET}\n" > /dev/tty
                echo "${valid_options[$selected_index]}"
                return
            fi
        fi
        
        # Tratamento para opção inválida
        printf "\n${RED}$(get_msg invalid_option)${RESET}\n" > /dev/tty
        sleep 1.5
    done
}

    # Formato de áudio
    local valid_formats=("mp3" "flac" "opus" "wav" "m4a")
    editable_config[format]=$(handle_enumerated_option \
        "$(get_msg config_kept_format)" \
        "${editable_config[format]}" \
        valid_formats[@] \
        "$(get_msg format_updated_msg)" \
        "$(get_msg format)")
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -r
        clear

    # Bitrate
    local valid_bitrates=("128k" "256k" "320k" "512k")
    editable_config[bitrate]=$(handle_enumerated_option \
        "$(get_msg config_kept_bitrate)" \
        "${editable_config[bitrate]}" \
        valid_bitrates[@] \
        "$(get_msg bitrate_updated)" \
        "$(get_msg bitrate)")
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -r
        clear

    # Comportamento de sobrescrita (nova opção)
    local valid_overwrite=("skip" "force" "metadata")
    editable_config[overwrite]=$(handle_enumerated_option \
        "$(get_msg config_kept_overwrite)" \
        "${editable_config[overwrite]}" \
        valid_overwrite[@] \
        "$(get_msg overwrite_updated)" \
        "$(get_msg overwrite)")
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -r
        clear

    # Número máximo de backups
    while true; do
        print_section_header "$(get_msg menu_option5)"
        printf "\n${BOLD}$(get_msg max_backups)${YELLOW}[${MAX_BACKUPS}]${RESET}${BOLD}:${RESET} "
        read -r new_max_backups
        
        if [[ -z "$new_max_backups" ]]; then
            printf "\n${YELLOW}$(printf "$(get_msg config_kept_max_backups)" "$MAX_BACKUPS")${RESET}\n"
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -r
            clear
            break
        fi
        
        if [[ "$new_max_backups" =~ ^[1-9][0-9]*$ ]]; then
            MAX_BACKUPS="$new_max_backups"
            printf "\n${GREEN}$(printf "$(get_msg max_backups_updated)" "${MAX_BACKUPS}")${RESET}\n"
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -r
            clear
            break
        else
            printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_number)"
            sleep 1.5
            clear
        fi
    done

    # Função auxiliar para opções booleanas
    handle_boolean_option() {
    local config_key="$1"
    local prompt_msg="$2"
    local current_value="${editable_config[$config_key]}"
    local yes_char="$(get_msg boolean_yes_display)"
    local no_char="$(get_msg boolean_no_display)"
    local display_value=""
    
    [[ "$current_value" == "true" ]] && display_value="$yes_char" || display_value="$no_char"

    while true; do
        clear
        
        # Exibir prompt
        print_section_header "$(get_msg menu_option5)"
        printf "\n${BOLD}%s ${YELLOW}[%s]${RESET}? (%s/%s): " \
               "$prompt_msg" "$display_value" "$yes_char" "$no_char"

        # Ler tecla única
        read -n 1 -r input
        input="${input,,}"

        # Enter mantém o valor atual
        if [[ -z "$input" ]]; then
            printf "\n${YELLOW}$(printf "$(get_msg config_kept_boolean)" \
                   "$prompt_msg" "$display_value")${RESET}\n"
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -r
            return
        fi

        # Verificar opção válida
        if [[ "$input" == "$yes_char" ]]; then
            editable_config[$config_key]="true"
            printf "\n\n${GREEN}$(printf "$(get_msg option_set_to_yes)" \
                   "$prompt_msg" "$yes_char")${RESET}\n"
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -r
            return
        elif [[ "$input" == "$no_char" ]]; then
            editable_config[$config_key]="false"
            printf "\n\n${GREEN}$(printf "$(get_msg option_set_to_no)" \
                   "$prompt_msg" "$no_char")${RESET}\n"
            printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
            read -r
            return
        fi

        # Opção inválida
        printf "\n\n${RED}%s${RESET}\n" "$(get_msg invalid_option)"
        sleep 1.5
    done
}

    # Demais configurações booleanas
    handle_boolean_option "generate_lrc" "$(get_msg generate_lrc)"
    handle_boolean_option "skip_album_art" "$(get_msg skip_album_art)"
    handle_boolean_option "sync_without_deleting" "$(get_msg sync_without_deleting)"
    handle_boolean_option "sync_remove_lrc" "$(get_msg sync_remove_lrc)"
    clear
    save_spotdl_config
    save_helper_config

    # Recarregar configurações e strings
    reload_application_config
    
    # Mensagem de sucesso
    printf "\n${CYAN}%s${RESET}\n" "$(get_msg loaded_config)"
    sleep 0.5
    printf "\n${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_language)" "$CURRENT_LANG"
    sleep 0.5
    printf "\n${YELLOW}%s:${RESET} ${GREEN}%s${RESET}\n" "$(get_msg label_download_path)" "$FINAL_DIR"
    sleep 0.5
    printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
    read -r
}

reload_application_config() {
    # Recarregar configurações principais
    load_helper_config
    load_spotdl_config
    
    # Recarregar strings de UI
    load_ui_strings "$CURRENT_LANG"
    
    # Recarregar configurações de download
    OUTPUT_TEMPLATE=$(jq -r '.output' "$SPOTDL_CONFIG")
    OVERWRITE_MODE=$(jq -r '.overwrite // "skip"' "$SPOTDL_CONFIG")
    THREADS=$(jq -r '.threads // 3' "$SPOTDL_CONFIG")
    GENERATE_LRC=$(jq -r '.generate_lrc // "true"' "$SPOTDL_CONFIG")
    SYNC_WITHOUT_DELETING=$(jq -r '.sync_without_deleting // "true"' "$SPOTDL_CONFIG")
}

# Visualizar arquivo de configuração do spotDL
view_current_config() {
    clear
    print_section_header "$(get_msg menu_option5)"

    printf "\n${BLUE}%s${RESET}\n" "$(get_msg opening_config)"
    printf "${YELLOW}%s${RESET}\n\n" "$SPOTDL_CONFIG"

    while true; do
        printf "\n${BOLD}%s${RESET}\n" "$(get_msg inform_editor)"
        printf "${BOLD}%s${RESET} " "$(get_msg press_enter_nano)"
        read -r editor
        editor=${editor:-nano}

        if command -v "$editor" &>/dev/null; then
            sleep 0.5
            "$editor" "$SPOTDL_CONFIG"
            break
        else
            printf "\n${RED}$(printf "$(get_msg editor_not_found_fmt)" "$editor")${RESET}\n"
        fi
    done
}