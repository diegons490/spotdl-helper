#!/bin/bash
# modules/downloads.sh
# Sistema de downloads completo e configurável - REFATORADO

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
load_config

# Carrega configurações essenciais
OUTPUT_TEMPLATE=$(jq -r '.output' "$SPOTDL_CONFIG")
OVERWRITE_MODE=$(jq -r '.overwrite // "skip"' "$SPOTDL_CONFIG")
THREADS=$(jq -r '.threads // 3' "$SPOTDL_CONFIG")
GENERATE_LRC=$(jq -r '.generate_lrc // "true"' "$SPOTDL_CONFIG")
SYNC_WITHOUT_DELETING=$(jq -r '.sync_without_deleting // "true"' "$SPOTDL_CONFIG")

# ========== FUNÇÕES AUXILIARES ==========

# Funções de validação de links
is_valid_track_link() {
    [[ "$1" =~ open.spotify.com/track/ ]]
}

is_valid_album_link() {
    [[ "$1" =~ open.spotify.com/album/ ]]
}

is_valid_playlist_link() {
    [[ "$1" =~ open.spotify.com/playlist/ ]]
}

is_valid_artist_link() {
    [[ "$1" =~ open.spotify.com/artist/ ]]
}

# Função para executar spotdl com configurações
run_spotdl() {
    local command="$1"
    local link="$2"
    shift 2
    local extra_args=("$@")
    
    # Argumentos base
    local base_args=(
        "--format" "${editable_config[format]}"
        "--bitrate" "${editable_config[bitrate]}"
        "--output" "$OUTPUT_TEMPLATE"
        "--overwrite" "$OVERWRITE_MODE"
        "--threads" "$THREADS"
    )
    
    # Adiciona gerar letras se configurado
    if [[ "$GENERATE_LRC" == "true" ]]; then
        base_args+=("--generate-lrc")
    fi
    
    # Adiciona argumentos extras
    local all_args=("${base_args[@]}" "${extra_args[@]}")
    
    # Formata a mensagem de log com cores
    printf "\n${BLUE}${BOLD}%s${RESET}\n" "$(get_msg executing_label)"
    printf "${BLUE}spotdl ${BOLD}$command ${YELLOW}\"$link\"${RESET}"
    
    # Formata cada argumento
    for ((i=0; i<${#all_args[@]}; i+=2)); do
        if [[ $i -lt ${#all_args[@]} && $((i+1)) -lt ${#all_args[@]} ]]; then
            printf " ${BOLD}${all_args[i]}${RESET} ${GREEN}${all_args[i+1]}${RESET}"
        fi
    done
    printf "\n\n"
    
    # Executa o comando
    "$SPOTDL_CMD" "$command" "$link" "${all_args[@]}"
}

# ========== FUNÇÕES PRINCIPAIS DE DOWNLOAD ==========

# Função para baixar músicas ou álbuns
download_music() {
    clear
    print_section_header "$(get_msg menu_option1)"

    # Informa o caminho base
    printf "\n${CYAN}%s:${RESET} ${GREEN}%s${RESET}\n\n" \
        "$(get_msg label_download_path)" "$FINAL_DIR"

    local links=()
    local link

    while true; do
        printf "\n${BOLD}%s${RESET}\n" "$(get_msg enter_link)"
        printf "${CYAN}%s${RESET}\n" "$(get_msg press_0_to_return)"
        read -r link
        
        [[ "$link" == "0" ]] && return 0
        [[ -z "$link" ]] && continue
        
        # Validação para músicas/álbuns
        if ! is_valid_track_link "$link" && ! is_valid_album_link "$link"; then
            printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_link_type)"
            printf "\n${YELLOW}%s${RESET}\n" "$(get_msg valid_link_types_tracks_albums)"
            continue
        fi
        
        links+=("$link")

        if ! prompt_yes_no "$(get_msg add_more_links)"; then
            break
        fi
    done

    printf "\n${GREEN}%s${RESET}\n\n" "$(get_msg starting_downloads)"

    for link in "${links[@]}"; do
        printf "${BLUE}%s:\n%s${RESET}\n" "$(get_msg downloading)" "$link"
        run_spotdl "download" "$link"
    done

    printf "\n${GREEN}%s${RESET}\n\n" "$(get_msg all_downloads_completed)"
    printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
    read -n 1 -r -s
}

# Função para baixar playlists
download_playlists() {
    clear
    print_section_header "$(get_msg download_playlists)"

    # Informa o caminho base
    printf "\n${CYAN}%s:${RESET} ${GREEN}%s${RESET}\n\n" \
        "$(get_msg label_download_path)" "$FINAL_DIR"

    local links=()
    local link

    # Função para extrair ID da playlist
    extract_playlist_id() {
        local url="$1"
        local clean_url="${url%%[?#]*}"
        local patterns=(
            'open\.spotify\.com/playlist/([a-zA-Z0-9]+)'
            'spotify\.com/playlist/([a-zA-Z0-9]+)'
            'spotify:playlist:([a-zA-Z0-9]+)'
            '^([a-zA-Z0-9]{22})$'
        )

        for pattern in "${patterns[@]}"; do
            if [[ "$clean_url" =~ $pattern ]]; then
                echo "${BASH_REMATCH[1]}"
                return 0
            fi
        done

        local last_segment="${clean_url##*/}"
        if [[ "$last_segment" =~ ^[a-zA-Z0-9]{22}$ ]]; then
            echo "$last_segment"
            return 0
        fi

        echo "invalid"
        return 1
    }

    while true; do
        printf "\n${BOLD}%s${RESET}\n" "$(get_msg enter_link)"
        printf "${CYAN}%s${RESET}\n" "$(get_msg press_0_to_return)"
        read -r link
        
        [[ "$link" == "0" ]] && return 0
        [[ -z "$link" ]] && continue

        # Validação específica para playlists
        if ! is_valid_playlist_link "$link"; then
            printf "${RED}%s${RESET}\n" "$(get_msg invalid_playlist_link)"
            printf "${YELLOW}%s${RESET}\n" "$(get_msg valid_link_types_playlists)"
            continue
        fi

        local playlist_id
        playlist_id=$(extract_playlist_id "$link")
        if [[ "$playlist_id" == "invalid" ]]; then
            printf "${RED}%s${RESET}\n" "$(get_msg invalid_playlist_link)"
            printf "${YELLOW}%s${RESET}\n" "$(printf "$(get_msg received_url)" "$link")"
            continue
        fi

        links+=("$link")
        if ! prompt_yes_no "$(get_msg add_more_links)"; then
            break
        fi
    done

    # Diretórios fixos baseados na configuração
    local playlists_dir="$FINAL_DIR/Playlists/Sync_files"
    local m3u_dir="$FINAL_DIR/Playlists"
    mkdir -p "$playlists_dir" "$m3u_dir" || {
        printf "${RED}%s${RESET}\n" "$(get_msg no_write_permission)"
        return 1
    }

    printf "\n${GREEN}%s${RESET}\n\n" "$(get_msg starting_downloads)"

    for link in "${links[@]}"; do
        printf "${BLUE}%s:\n%s${RESET}\n" "$(get_msg downloading)" "$link"
        local playlist_id
        playlist_id=$(extract_playlist_id "$link")
        [[ "$playlist_id" == "invalid" ]] && continue

        local spotdl_file="$playlists_dir/$playlist_id.spotdl"
        local temp_m3u_file="$m3u_dir/spotdl_temp_$playlist_id.m3u8"
        local final_m3u_file=""

        # Constrói o comando spotdl
        local spotdl_cmd=(
            "$SPOTDL_CMD" sync "$link"
            --save-file "$spotdl_file"
            --output "$OUTPUT_TEMPLATE"
            --overwrite metadata
            --threads "$THREADS"
            --m3u "spotdl_temp_$playlist_id.m3u8"
        )
        [[ "$GENERATE_LRC" == "true" ]] && spotdl_cmd+=(--generate-lrc)

        # Formatação de debug com cores
        printf "\n${BLUE}${BOLD}%s${RESET}\n" "$(get_msg executing_label)"
        printf "${BLUE}%s ${BOLD}%s ${YELLOW}\"%s\"${RESET}" \
            "${spotdl_cmd[0]}" "${spotdl_cmd[1]}" "${spotdl_cmd[2]}"
        
        for ((i=3; i<${#spotdl_cmd[@]}; i+=2)); do
            if [[ $i -lt ${#spotdl_cmd[@]} && $((i+1)) -lt ${#spotdl_cmd[@]} ]]; then
                printf " ${BOLD}${spotdl_cmd[i]}${RESET} ${GREEN}${spotdl_cmd[i+1]}${RESET}"
            else
                printf " ${BOLD}${spotdl_cmd[i]}${RESET}"
            fi
        done
        printf "\n\n"

        # Execução em subshell
        (
            local work_dir
            work_dir=$(mktemp -d)
            cd "$work_dir" || exit 1

            printf "${YELLOW}%s${RESET}\n\n" "$(printf "$(get_msg starting_download_temp_dir)" "$work_dir")"
            
            if ! "${spotdl_cmd[@]}"; then
                printf "${RED}%s${RESET}\n" "$(printf "$(get_msg error_downloading_playlist)" "$link")"
                cd ..
                rm -rf "$work_dir"
                exit 1
            fi

            if [[ -f "spotdl_temp_$playlist_id.m3u8" ]]; then
                mv "spotdl_temp_$playlist_id.m3u8" "$temp_m3u_file"
                printf "${GREEN}%s${RESET}\n" "$(printf "$(get_msg temp_m3u_moved)" "$temp_m3u_file")"
            else
                printf "${YELLOW}%s${RESET}\n" "$(get_msg m3u_not_generated)"
            fi

            cd ..
            rm -rf "$work_dir"
        )

        # Processamento pós-download
        if [[ -f "$temp_m3u_file" ]]; then
            local wait_time=0
            while [[ ! -s "$spotdl_file" && $wait_time -lt 10 ]]; do
                sleep 0.5
                ((wait_time++))
            done

            local playlist_name=""
            if [[ -f "$spotdl_file" && -s "$spotdl_file" ]]; then
                playlist_name=$(jq -r '.songs[0].list_name // .list_name // empty' "$spotdl_file")
                printf "${GREEN}%s${RESET}\n" "$(printf "$(get_msg playlist_name_extracted)" "${playlist_name:-N/A}")"
            fi

            if [[ -n "$playlist_name" && "$playlist_name" != "null" ]]; then
                local playlist_name_safe
                playlist_name_safe=$(echo "$playlist_name" | 
                                    iconv -f utf-8 -t ascii//TRANSLIT//IGNORE |
                                    sed -e 's/[^a-zA-Z0-9 _-]/ /g' \
                                        -e 's/  */ /g' \
                                        -e 's/^ *//' \
                                        -e 's/ *$//')
                final_m3u_file="$m3u_dir/${playlist_name_safe}.m3u8"
            else
                final_m3u_file="$m3u_dir/Playlist_$playlist_id.m3u8"
            fi

            if mv -f "$temp_m3u_file" "$final_m3u_file"; then
                printf "\n${GREEN}%s ${CYAN}%s${RESET}\n" "$(get_msg playlist_saved_as)" "$final_m3u_file"
            else
                printf "\n${YELLOW}%s ${CYAN}%s${RESET}\n" "$(get_msg m3u_kept_as)" "$temp_m3u_file"
            fi
        else
            printf "\n${YELLOW}%s${RESET}\n" "$(printf "$(get_msg m3u_not_generated_for)" "$link")"
        fi

        printf "\n${BLUE}%s${RESET}\n" "$(get_msg separator_line)"
    done

    printf "\n${GREEN}%s${RESET}\n\n" "$(get_msg all_downloads_completed)"
    printf "${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
    read -n 1 -r -s
}

# Função para baixar álbuns de artistas
download_artist_albums() {
    clear
    print_section_header "$(get_msg menu_option3)"

    # Informa o caminho base
    printf "\n${CYAN}%s:${RESET} ${GREEN}%s${RESET}\n\n" \
        "$(get_msg label_download_path)" "$FINAL_DIR"

    local links=()
    local link

    while true; do
        printf "\n${BOLD}%s${RESET}\n" "$(get_msg enter_link)"
        printf "${CYAN}%s${RESET}\n" "$(get_msg press_0_to_return)"
        read -r link
        
        [[ "$link" == "0" ]] && return 0
        [[ -z "$link" ]] && continue
        
        # Validação específica para artistas
        if ! is_valid_artist_link "$link"; then
            printf "${RED}%s${RESET}\n" "$(get_msg invalid_artist_link)"
            printf "${YELLOW}%s${RESET}\n" "$(get_msg valid_link_types_artists)"
            continue
        fi
        
        links+=("$link")

        if ! prompt_yes_no "$(get_msg add_more_links)"; then
            break
        fi
    done

    printf "\n${GREEN}%s${RESET}\n\n" "$(get_msg starting_downloads)"

    for link in "${links[@]}"; do
        printf "${BLUE}%s:\n%s${RESET}\n" "$(get_msg downloading)" "$link"
        run_spotdl "download" "$link" --fetch-albums
    done

    printf "\n${GREEN}%s${RESET}\n\n" "$(get_msg all_downloads_completed)"
    printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
    read -n 1 -r -s
}

# Função para sincronizar playlists/álbuns
sync_files() {
    clear
    print_section_header "$(get_msg menu_option4)"

    # Informa o caminho base
    printf "\n${CYAN}%s:${RESET} ${GREEN}%s${RESET}\n\n" \
        "$(get_msg label_download_path)" "$FINAL_DIR"

    local links=()
    local link
    local add_more=true

    # Coleta múltiplos links
    while $add_more; do
        printf "\n${BOLD}%s${RESET}\n" "$(get_msg enter_link)"
        printf "${CYAN}%s${RESET}\n" "$(get_msg press_0_to_return)"
        read -r link
        
        [[ "$link" == "0" ]] && return 0
        [[ -z "$link" ]] && continue
        
        # Validação para playlists/álbums
        if ! is_valid_playlist_link "$link" && ! is_valid_album_link "$link"; then
            printf "${RED}%s${RESET}\n" "$(get_msg invalid_sync_link)"
            printf "${YELLOW}%s${RESET}\n" "$(get_msg valid_link_types_sync)"
            continue
        fi
        
        links+=("$link")

        # Pergunta se deseja adicionar mais links
        printf "${BOLD}\n%s${RESET}" "$(get_msg add_more_links) [s/N] "
        read -r resposta
        [[ ! "$resposta" =~ ^[Ss]$ ]] && add_more=false
    done

    # Se não houver links, retorna
    if [ ${#links[@]} -eq 0 ]; then
        printf "\n${YELLOW}%s${RESET}\n" "$(get_msg no_links_to_sync)"
        printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
        read -n 1 -r -s
        return
    fi

    # Diretório fixo baseado na configuração
    local playlists_dir="$FINAL_DIR/playlists"
    mkdir -p "$playlists_dir" || {
        printf "${RED}%s${RESET}\n" "$(get_msg no_write_permission)"
        return 1
    }

    # Para cada link, sincronizar
    for link in "${links[@]}"; do
        # Gera um nome de arquivo seguro a partir do link
        local filename=$(basename "${link%%\?*}")
        local filename_safe=$(echo "$filename" | sed 's/[\/:*?"<>|]/_/g')
        local spotdl_file="$playlists_dir/$filename_safe.spotdl"

        # Formata e mostra o comando que será executado
        printf "\n${BLUE}${BOLD}%s${RESET}\n" "$(get_msg executing_label)"
        printf "${BLUE}spotdl ${BOLD}sync ${YELLOW}\"$link\"${RESET}"
        printf " ${BOLD}--format${RESET} ${GREEN}${editable_config[format]}${RESET}"
        printf " ${BOLD}--bitrate${RESET} ${GREEN}${editable_config[bitrate]}${RESET}"
        printf " ${BOLD}--output${RESET} ${GREEN}$OUTPUT_TEMPLATE${RESET}"
        printf " ${BOLD}--overwrite${RESET} ${GREEN}$OVERWRITE_MODE${RESET}"
        printf " ${BOLD}--threads${RESET} ${GREEN}$THREADS${RESET}"
        printf " ${BOLD}--save-file${RESET} ${GREEN}$spotdl_file${RESET}"
        
        # Adiciona --generate-lrc se necessário
        if [[ "$GENERATE_LRC" == "true" ]]; then
            printf " ${BOLD}--generate-lrc${RESET}"
        fi
        printf "\n\n"

        # Executa o comando de sincronização
        "$SPOTDL_CMD" sync "$link" \
            --save-file "$spotdl_file" \
            --output "$OUTPUT_TEMPLATE" \
            --overwrite "$OVERWRITE_MODE" \
            --threads "$THREADS" \
            $([[ "$GENERATE_LRC" == "true" ]] && echo "--generate-lrc")
        
        # Verifica se o comando foi executado com sucesso
        if [[ $? -eq 0 ]]; then
            printf "${GREEN}%s${RESET}\n" "$(get_msg sync_completed)"
        else
            printf "${RED}%s${RESET}\n" "$(get_msg sync_failed)"
        fi
    done

    printf "\n${YELLOW}%s${RESET}" "$(get_msg press_enter_continue)"
    read -n 1 -r -s
}