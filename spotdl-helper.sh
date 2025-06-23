#!/bin/bash
set -euo pipefail

# Caminhos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.spotdl/config.json"
DOWNLOADS_DIR=$(xdg-user-dir DOWNLOAD)
FINAL_DIR="$DOWNLOADS_DIR/SpotDL"

# Configurações de internacionalização
LANG_DIR="$SCRIPT_DIR/lang"
DEFAULT_LANG="en_US"
CURRENT_LANG="$DEFAULT_LANG"

# Cores
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
RED="\033[31;1m"
CYAN="\033[36;1m"
BLUE="\033[34;1m"
BOLD="\033[1m"
RESET="\033[0m"

# Função para carregar strings de idioma
carregar_idioma() {
    local lang_file="$LANG_DIR/$1.lang"
    if [[ -f "$lang_file" ]]; then
        source "$lang_file"
    else
        printf "\n${RED}Language file not found: %s${RESET}\n" "$lang_file"
        printf "\n${YELLOW}Using default language: %s...${RESET}\n" "$DEFAULT_LANG"
        lang_file="$LANG_DIR/$DEFAULT_LANG.lang"
        if [[ -f "$lang_file" ]]; then
            source "$lang_file"
        else
            printf "\n${RED}Default language file not found: %s${RESET}\n" "$lang_file"
            exit 1
        fi
    fi
}

# Verificar se todos os arquivos de idioma obrigatórios existem
required_langs=("pt_BR" "en_US" "es_ES")
for lang_code in "${required_langs[@]}"; do
    lang_path="$LANG_DIR/${lang_code}.lang"
    if [[ ! -f "$lang_path" ]]; then
        printf "${RED}Missing language file: ${lang_path}${RESET}\n"
        printf "${YELLOW}Please ensure all required language files are present before running the script.${RESET}\n"
        exit 1
    fi
done

# Carrega o idioma inicial
carregar_idioma "$CURRENT_LANG"

print_header() {
    local titulo="$1"
    printf "\n${CYAN}===========================================${RESET}\n"
    printf "${BOLD}${CYAN}%s${RESET}\n" "$titulo"
    printf "${CYAN}===========================================${RESET}\n"
}

# Verificar dependência: ffmpeg
if ! command -v ffmpeg &>/dev/null; then
    printf "\n${RED}${error_ffmpeg_not_found}${RESET}\n"
    printf "\n${YELLOW}${attempt_detect_pkg_manager}${RESET}\n"

    if command -v pacman &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo pacman -S ffmpeg${RESET}\n"
    elif command -v apt &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo apt update && sudo apt install ffmpeg${RESET}\n"
    elif command -v dnf &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo dnf install ffmpeg${RESET}\n"
    elif command -v zypper &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo zypper install ffmpeg${RESET}\n"
    elif command -v emerge &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo emerge media-video/ffmpeg${RESET}\n"
    elif command -v apk &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo apk add ffmpeg${RESET}\n"
    else
        printf "\n${RED}${error_pkg_manager_not_found}${RESET}\n"
        printf "\n${YELLOW}${please_install_manually}${RESET}\n"
    fi

    exit 1
fi

# Verificar dependência: jq
if ! command -v jq &>/dev/null; then
    printf "\n${RED}${error_jq_not_found}${RESET}\n"
    printf "\n${YELLOW}${attempt_detect_pkg_manager}${RESET}\n"

    if command -v pacman &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo pacman -S jq${RESET}\n"
    elif command -v apt &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo apt update && sudo apt install jq${RESET}\n"
    elif command -v dnf &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo dnf install jq${RESET}\n"
    elif command -v zypper &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo zypper install jq${RESET}\n"
    elif command -v emerge &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo emerge dev-util/jq${RESET}\n"
    elif command -v apk &>/dev/null; then
        printf "\n${BOLD}${install_with}:${RESET} ${CYAN}sudo apk add jq${RESET}\n"
    else
        printf "\n${RED}${error_pkg_manager_not_found}${RESET}\n"
        printf "\n${YELLOW}${please_install_manually}${RESET}\n"
    fi

    exit 1
fi

# Função reutilizável para perguntas
perguntar() {
    local prompt_msg="$1"
    local resposta

    while true; do
        printf "\n${BOLD}%s (${yes_char}/${no_char}): ${RESET}" "$prompt_msg"
        read -r resposta
        case "${resposta,,}" in
            "${yes_char,,}") return 0 ;;  # true
            "${no_char,,}") return 1 ;;   # false
            *) printf "\n${RED}%s '${yes_char}' ${or_char} '${no_char}'.${RESET}\n" "$invalid_choice_msg\n" ;;
        esac
    done
}

# Verificar se existe versão local do SpotDL
BINARIO_LOCAL=$(ls "$SCRIPT_DIR"/spotdl-*-linux 2>/dev/null | sort -V | tail -n1 || true)

if [[ -x "$BINARIO_LOCAL" ]]; then
    SPOTDL_CMD="$BINARIO_LOCAL"
else
    clear
    printf "\n${YELLOW}${no_local_spotdl}${RESET}\n"
    if perguntar "\n${download_latest_version}\n"; then
        printf "${CYAN}\n${downloading_latest}${RESET}\n"
        URL_LATEST=$(curl -s https://api.github.com/repos/spotDL/spotify-downloader/releases/latest | \
                     jq -r '.assets[] | select(.name | test("spotdl-.*-linux")) | .browser_download_url' | head -n1)

        if [[ -z "$URL_LATEST" ]]; then
            printf "\n${RED}${could_not_find_link}${RESET}\n"
            exit 1
        fi

        ARQ_BAIXADO="$SCRIPT_DIR/$(basename "$URL_LATEST")"
        curl -L -o "$ARQ_BAIXADO" "$URL_LATEST"
        chmod +x "$ARQ_BAIXADO"
        SPOTDL_CMD="$ARQ_BAIXADO"

        # Extrair versão do binário baixado
        VERSAO_BAIXADA=$("$SPOTDL_CMD" --version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

        printf "\n${GREEN}${download_completed}: %s${RESET}\n" "$VERSAO_BAIXADA"
        rm -f "$CONFIG_FILE"
        printf "\n${YELLOW}${press_enter_continue_msg}${RESET}"
        read -r
    else
        printf "\n${RED}${operation_canceled}! ${no_local_version_available}${RESET}\n"
        exit 1
    fi
fi

# Configurações editáveis
declare -A config_editaveis=(
    [format]="mp3"
    [bitrate]="256k"
    [generate_lrc]="true"
    [skip_album_art]="false"
    [threads]="3"
    [sync_without_deleting]="true"
    [sync_remove_lrc]="false"
    [language]="$DEFAULT_LANG"
    [download_path]="$FINAL_DIR"
)

# Carregar configuração
carregar_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        for chave in "${!config_editaveis[@]}"; do
            valor=$(jq -r --arg k "$chave" '.[$k] // empty' "$CONFIG_FILE")
            if [[ -n "$valor" && "$valor" != "null" ]]; then
                config_editaveis[$chave]="$valor"
            fi
        done
    fi
    CURRENT_LANG="${config_editaveis[language]}"
}

# Salvar configurações
salvar_config() {
    mkdir -p "$HOME/.spotdl"

    # Montar template completo com caminho base
    local output_template="${config_editaveis[download_path]}/{artist}/{album}/{title}.{output-ext}"

    # Parâmetros a serem gravados no arquivo de configuração "config.json"
    cat > "$CONFIG_FILE" <<EOF
{
    "client_id": "5f573c9620494bae87890c0f08a60293",
    "client_secret": "212476d9b0f3472eaa762d90b19b0ba8",
    "auth_token": null,
    "user_auth": false,
    "headless": false,
    "no_cache": false,
    "max_retries": 3,
    "use_cache_file": false,
    "audio_providers": [
        "youtube-music"
    ],
    "lyrics_providers": [
        "genius",
        "azlyrics",
        "musixmatch"
    ],
    "genius_token": "alXXDbPZtK1m2RrZ8I4k2Hn8Ahsd0Gh_o076HYvcdlBvmc0ULL1H8Z8xRlew5qaG",
    "playlist_numbering": false,
    "playlist_retain_track_cover": false,
    "scan_for_songs": false,
    "m3u": null,
    "overwrite": "skip",
    "search_query": null,
    "ffmpeg": "ffmpeg",
    "bitrate": "${config_editaveis[bitrate]}",
    "ffmpeg_args": null,
    "format": "${config_editaveis[format]}",
    "threads": ${config_editaveis[threads]},
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
    "generate_lrc": ${config_editaveis[generate_lrc]},
    "force_update_metadata": false,
    "only_verified_results": false,
    "sync_without_deleting": ${config_editaveis[sync_without_deleting]},
    "max_filename_length": null,
    "yt_dlp_args": null,
    "detect_formats": null,
    "save_errors": null,
    "ignore_albums": null,
    "proxy": null,
    "skip_explicit": false,
    "log_format": null,
    "redownload": false,
    "skip_album_art": ${config_editaveis[skip_album_art]},
    "create_skip_file": false,
    "respect_skip_file": false,
    "sync_remove_lrc": ${config_editaveis[sync_remove_lrc]},
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
    "output": "$output_template",
    "language": "${config_editaveis[language]}",
    "download_path": "${config_editaveis[download_path]}"
}
EOF
    printf "\n${GREEN}${configuration_saved} %s${RESET}\n" "$CONFIG_FILE"
}

# Função para abrir arquivo de configuração "config.json"
verificar_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        return 0
    else
        printf "\n${RED}${error_config_not_found}${RESET}\n"
        printf "\n${BLUE}Create a first one using option 4 from the menu.${RESET}\n"
        printf "\n${YELLOW}${press_enter_continue_msg}${RESET}\n"
        read -r
        menu
    fi
}

# Função para editar arquivo de configuração "config.json"
editar_config_interativa() {
    local idioma_alterado=false

    while true; do
        clear
        print_header "${menu_option4}"

        # Mensagem explicativa logo abaixo do cabeçalho, [x] em amarelo
        printf "\n${BLUE}$(printf "${info_current_config_msg}" "${YELLOW}[x]${BLUE}")${RESET}\n"

        while true; do
        local current_lang="${config_editaveis[language]:-$DEFAULT_LANG}"
        printf "\n${BOLD}$(printf "${current_language_msg}" "${YELLOW}${BOLD}[$current_lang]${RESET}${BOLD}")${RESET}\n"
        printf "\n1) Português (pt_BR)"
        printf "\n2) English (en_US)"
        printf "\n3) Español (es_ES)"
        printf "\n${BOLD}$(printf "\n${choose_language_msg}") ${RESET}"
        read -r lang_choice

        case "$lang_choice" in
            "")
                break  # Sai do loop mantendo o idioma atual
                ;;
            1)
                config_editaveis[language]="pt_BR"
                idioma_alterado=true
                break
                ;;
            2)
                config_editaveis[language]="en_US"
                idioma_alterado=true
                break
                ;;
            3)
                config_editaveis[language]="es_ES"
                idioma_alterado=true
                break
                ;;
            *)
                printf "\n${RED}$(printf "${invalid_choice_msg}" "1, 2, 3, or Enter")${RESET}\n"
                ;;
        esac
    done



        if [[ "$idioma_alterado" == true ]]; then
        CURRENT_LANG="${config_editaveis[language]}"
        carregar_idioma "$CURRENT_LANG"
        salvar_config
        printf "\n${GREEN}$(printf "${language_set_msg}" "$CURRENT_LANG")${RESET}\n"
        printf "\n${YELLOW}${press_enter_continue_msg}${RESET}"
        read -r
        idioma_alterado=false
            # Continua o loop para mostrar novamente o menu de idioma atualizado
        else
            break
        fi
    done

    # Configurar caminho base de downloads
    printf "\n${BOLD}${base_download_path_msg} ${YELLOW}[${config_editaveis[download_path]}]${RESET}: "
    read -r entrada
    if [[ -n "$entrada" ]]; then
        config_editaveis[download_path]="$entrada"
    fi

    # Função interna desse bloco para perguntas
    perguntar_editar() {
        local chave="$1"
        local descricao="$2"
        local atual
        atual=$( [[ ${config_editaveis[$chave]} == true ]] && echo "${yes_char}" || echo "${no_char}" )

        while true; do
            printf "\n${BOLD}%s (${yes_char}/${no_char}) ${YELLOW}[$atual]${RESET}: " "$descricao"
            read -r entrada
            entrada=${entrada,,}

            if [[ -z "$entrada" ]]; then
                break
            elif [[ "$entrada" == "${yes_char,,}" ]]; then
                config_editaveis[$chave]=true
                break
            elif [[ "$entrada" == "${no_char,,}" ]]; then
                config_editaveis[$chave]=false
                break
            else
                printf "\n${RED}%s '${yes_char}' ${or_char} '${no_char}'.${RESET}\n" "$invalid_choice_msg"
            fi
        done
    }

    # Formato (valores válidos)
    formatos_validos=("mp3" "flac" "opus" "wav" "m4a")
    while true; do
        printf "\n${BOLD}$(printf "${format_msg}" "${formatos_validos[*]}") ${YELLOW}[${config_editaveis[format]}]${RESET}: "
        read -r entrada
        entrada=${entrada,,}
        if [[ -z "$entrada" ]]; then
            break
        elif [[ " ${formatos_validos[*]} " =~ " $entrada " ]]; then
            config_editaveis[format]="$entrada"
            break
        else
            printf "\n${RED}$(printf "${invalid_format_msg}" "${formatos_validos[*]}")${RESET}\n"
        fi
    done

    # Bitrate (valores válidos)
    bitrates_validos=("128k" "256k" "320k" "512k")
    while true; do
        printf "\n${BOLD}$(printf "${bitrate_msg}" "${bitrates_validos[*]}") ${YELLOW}[${config_editaveis[bitrate]}]${RESET}: "
        read -r entrada
        entrada=${entrada,,}
        if [[ -z "$entrada" ]]; then
            break
        elif [[ " ${bitrates_validos[*]} " =~ " $entrada " ]]; then
            config_editaveis[bitrate]="$entrada"
            break
        else
            printf "\n${RED}$(printf "${invalid_bitrate_msg}" "${bitrates_validos[*]}")${RESET}\n"
        fi
    done

    # Downloads simultâneos
    while true; do
        printf "\n${BOLD}${simultaneous_downloads_msg} ${YELLOW}[${config_editaveis[threads]}]${RESET}: "
        read -r entrada
        if [[ -z "$entrada" ]]; then
            break
        elif [[ "$entrada" =~ ^[0-9]+$ ]]; then
            config_editaveis[threads]="$entrada"
            break
        else
            printf "\n${RED}${invalid_number_msg}${RESET}\n"
        fi
    done

    # Setor onde as configurações são feitas com a função interna de perguntas.
    perguntar_editar "generate_lrc" "$generate_lrc_msg"
    perguntar_editar "skip_album_art" "$skip_album_art_msg"
    perguntar_editar "sync_without_deleting" "$sync_without_deleting_msg"
    perguntar_editar "sync_remove_lrc" "$sync_remove_lrc_msg"

    # Salva as alterações finais
    salvar_config

    printf "\n${YELLOW}${press_enter_continue_msg}${RESET}"
    read -r
}

# Função para baixar músicas ou álbuns
baixar_musicas() {
    verificar_config
    clear
    print_header "${menu_option1}"

    # Obter caminho base padrão da configuração
    local base_path_default="${config_editaveis[download_path]}"

    # Lista de links
    links=()

    # Receber os links
    while true; do
        printf "\n${BOLD}%s${RESET}\n" "${enter_link_msg}"  # "Insira o link da música ou álbum:"
        read -r link
        links+=("$link")

        if ! perguntar "${add_more_links_msg}"; then  # "Deseja adicionar mais um link?"
            break
        fi
    done

    # MOSTRAR CAMINHO PADRÃO ATUAL e PERGUNTAR O CAMINHO
    printf "\n${CYAN}%s${RESET}\n${YELLOW}%s${RESET}\n" "$current_default_path_msg" "$base_path_default"

    while true; do
        printf "${BOLD}\n%s${RESET}\n" "$ask_output_path_msg"
        read -r pasta_saida

        # Se vazio, usa o caminho padrão
        if [[ -z "$pasta_saida" ]]; then
            pasta_saida="$base_path_default"
        fi

        # Tenta criar (caso não exista) e verifica permissão de escrita
        if mkdir -p "$pasta_saida" 2>/dev/null; then
            if [[ -w "$pasta_saida" ]]; then
                break
            else
                printf "${RED}\n%s${RESET}\n" "$no_write_permission_msg"
            fi
        else
            printf "${RED}\n%s${RESET}\n" "$invalid_path_msg"
        fi
    done

    printf "\n${GREEN}%s${RESET}\n\n" "${starting_downloads_msg}"

    for link in "${links[@]}"; do
        printf "${BLUE}%s: %s${RESET}\n" "${downloading_msg}" "$link"  # "Baixando:"

        if [[ "$link" =~ playlist ]]; then
            playlist_id=$(basename "${link%%\?*}")
            mkdir -p "$pasta_saida/playlists"
            destino_temp="$pasta_saida/playlists/$playlist_id"
            mkdir -p "$destino_temp"

            arquivo_spotdl="$pasta_saida/playlists/$playlist_id.spotdl"

            "$SPOTDL_CMD" sync "$link" --save-file "$arquivo_spotdl" --output "$destino_temp"

            if [[ -f "$arquivo_spotdl" ]]; then
                playlist_name=$(jq -r '.name // empty' "$arquivo_spotdl" | sed 's/[\/:*?"<>|]/_/g')
            else
                playlist_name=""
            fi

            if [[ -n "$playlist_name" && "$playlist_name" != "null" ]]; then
                destino_final="$pasta_saida/playlists/$playlist_name"
                mv "$destino_temp" "$destino_final"
                printf "\n${GREEN}%s: %s${RESET}" "${playlist_saved_msg}" "$destino_final"
            else
                printf "\n${YELLOW}%s: %s${RESET}" "${playlist_name_not_found_msg}" "$destino_temp"

                printf "\n"
                if perguntar "${ask_manual_playlist_name_msg}"; then
                    read -rp "${enter_playlist_name_msg}" nome_manual
                    nome_manual=$(echo "$nome_manual" | sed 's/[\/:*?"<>|]/_/g')
                    destino_final="$pasta_saida/playlists/$nome_manual"
                    mv "$destino_temp" "$destino_final"
                    printf "\n${GREEN}%s: %s${RESET}" "${playlist_renamed_msg}" "$destino_final"
                else
                    printf "\n${YELLOW}%s: %s${RESET}" "${keeping_temp_folder_msg}" "$destino_temp"
                fi
            fi

            [[ -f "$arquivo_spotdl" ]] && rm -f "$arquivo_spotdl"

        else
            "$SPOTDL_CMD" download "$link" --output "$pasta_saida/{artist}/{album}/{title}.{output-ext}"
        fi

        printf "\n"
    done

    printf "\n${GREEN}%s${RESET}\n\n" "${all_downloads_completed_msg}"
    printf "${YELLOW}%s${RESET}" "${press_enter_continue_msg}"
    read -r

}

# Função para procurar e baixar álbuns dos artistas
baixar_albuns() {
    verificar_config
    clear
    print_header "${menu_option2}"

    # Obter caminho base padrão da configuração
    local base_path_default="${config_editaveis[download_path]}"

    printf "\n${BOLD}%s${RESET}\n" "${enter_artist_link}"  # "Insira o link do artista:"
    read -r artista_link

    # MOSTRAR CAMINHO PADRÃO ATUAL e PERGUNTAR O CAMINHO
    printf "\n${CYAN}%s${RESET}\n${YELLOW}%s${RESET}\n" "$current_default_path_msg" "$base_path_default"

    while true; do
        printf "${BOLD}\n%s${RESET}\n" "$ask_output_path_msg"
        read -r pasta_saida

        # Se vazio, usa o caminho padrão
        if [[ -z "$pasta_saida" ]]; then
            pasta_saida="$base_path_default"
        fi

        # Tenta criar (caso não exista) e verifica permissão de escrita
        if mkdir -p "$pasta_saida" 2>/dev/null; then
            if [[ -w "$pasta_saida" ]]; then
                break
            else
                printf "${RED}\n%s${RESET}\n" "$no_write_permission_msg"
            fi
        else
            printf "${RED}\n%s${RESET}\n" "$invalid_path_msg"
        fi
    done

    printf "${GREEN}%s${RESET}\n\n" "${starting_downloads_msg}"  # "Iniciando downloads..."

    "$SPOTDL_CMD" "$artista_link" --fetch-albums --output "$pasta_saida/{artist}/{album}/{title}.{output-ext}"

    printf "\n${GREEN}%s${RESET}\n\n" "${all_downloads_completed_msg}"
    printf "${YELLOW}%s${RESET}" "${press_enter_continue_msg}"
    read -r
}

# Função de sincronização
atualizar_arquivos() {
    verificar_config
    clear
    print_header "${menu_option3}"

    printf "\n${BOLD}${enter_playlist_album_link_msg}${RESET}\n"
    read -r link

    # Obter caminho base padrão da configuração
    local base_path_default="${config_editaveis[download_path]}"
    
    # MOSTRAR CAMINHO PADRÃO ATUAL
    printf "\n${CYAN}%s${RESET}\n${YELLOW}%s${RESET}\n" "$current_default_path_msg" "$base_path_default"

    # Pergunta onde salvar/atualizar os arquivos
    while true; do
        printf "${BOLD}\n${ask_output_path_msg}${RESET}\n"
        read -r pasta_saida

        # Se vazio, usa o caminho base padrão
        if [[ -z "$pasta_saida" ]]; then
            pasta_saida="$base_path_default"
        fi

        if [[ -d "$pasta_saida" ]]; then
            break
        else
            printf "${RED}\n${invalid_path_msg}${RESET}\n"
        fi
    done

    output_template="{artist}/{album}/{title}.{output-ext}"

    PLAYLISTS_DIR="$pasta_saida/playlists"
    mkdir -p "$PLAYLISTS_DIR"

    nome_arquivo=$(basename "$link" | cut -d '?' -f1)
    caminho_spotdl="$PLAYLISTS_DIR/$nome_arquivo.spotdl"

    mkdir -p "$pasta_saida"

    full_output_path="$pasta_saida/$output_template"

    printf "${YELLOW}${sync_creating_file}${RESET}\n\n"
    "$SPOTDL_CMD" sync "$link" --save-file "$caminho_spotdl" --output "$full_output_path" --overwrite metadata

    printf "\n${GREEN}${sync_completed}.${RESET}\n"
    printf "\n${YELLOW}${press_enter_continue_msg}${RESET}"
    read -r
}

# Função para abrir o arquivo "config.json" no editor
ver_config_atual() {
    verificar_config
    clear
    print_header "${menu_option5}"

    printf "\n${BLUE}%s${RESET}\n" "$opening_config_msg"
    printf "\n${YELLOW}%s${RESET}\n" "$CONFIG_FILE"

    while true; do
        printf "\n${BOLD}%s${RESET}\n" "$inform_editor_msg"
        printf "\n${BOLD}%s${RESET} " "$press_enter_nano_msg"
        read -r editor
        editor=${editor:-nano}

        if command -v "$editor" &>/dev/null; then
            sleep 2
            "$editor" "$CONFIG_FILE"
            break
        else
            printf "\n${RED}%s '%s'. %s${RESET}\n" "$editor_not_found_msg" "$editor" "$try_again_msg"
        fi
    done
}

#Função para atualizar SpotDL
atualizar_spotdl() {
    verificar_config
    clear
    print_header "${menu_option6}"

    local APP_NAME="spotdl"
    local ARQUIVO_SUFFIXO="-linux"
    local API_URL="https://api.github.com/repos/spotDL/spotify-downloader/releases/latest"
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"
    #mkdir -p .old_versions

    # Obter versão remota
    local VERSAO_REMOTA
    VERSAO_REMOTA=$(curl -s "$API_URL" | grep '"tag_name":' | cut -d '"' -f4 | sed 's/^v//')
    local ARQUIVO_NOVO="${APP_NAME}-${VERSAO_REMOTA}${ARQUIVO_SUFFIXO}"

    if [[ -z "${SPOTDL_CMD:-}" || ! -x "$SPOTDL_CMD" ]]; then
        printf "\n${RED}Binário spotdl não encontrado.${RESET}"
        printf "\n${YELLOW}Rode o script novamente para baixar a versão inicial.${RESET}"
        exit 1
    fi

    # Obter dados da versão local
    local VERSAO_LOCAL
    VERSAO_LOCAL=$("$SPOTDL_CMD" --version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

    # Comparação
    if [[ "$VERSAO_LOCAL" == "$VERSAO_REMOTA" ]]; then
        printf "\n${GREEN}${spotdl_already_updated}: %s${RESET}\n" "$VERSAO_LOCAL"
        printf "\n${YELLOW}${press_enter_continue_msg}${RESET}"
        read -r
    
    # Atualizar
    else
        printf "\n${YELLOW}${new_version_available}:${RED} %s ${YELLOW}---> ${GREEN}%s${RESET}\n" "$VERSAO_LOCAL" "$VERSAO_REMOTA" 
        
        if perguntar "${update_now}"; then
            printf "\n${BLUE}${moving_old_version}${RESET}\n"
            mkdir -p old_versions
            mv "$SPOTDL_CMD" "old_versions/$(basename "$SPOTDL_CMD")"
            printf "\n${YELLOW}${downloading_new_version}...${RESET}\n\n"

            if curl -fLO "https://github.com/spotDL/spotify-downloader/releases/download/v${VERSAO_REMOTA}/${ARQUIVO_NOVO}"; then
                chmod +x "$ARQUIVO_NOVO"
                SPOTDL_CMD="$SCRIPT_DIR/$ARQUIVO_NOVO"
                printf "\n${GREEN}${update_completed}: %s${RESET}\n" "$VERSAO_REMOTA"
                printf "\n${YELLOW}%s${RESET}" "${press_enter_continue_msg}"  # "Pressione Enter para continuar..."
                read -r

            else
                printf "\n${RED}Erro no download da versão %s${RESET}" "$VERSAO_REMOTA"
                exit 1
            fi
        else
            printf "\n${RED}${update_canceled}.${RESET}\n"
            printf "\n${YELLOW}${press_enter_continue_msg}${RESET}"
            read -r
        fi
    fi
}

# Menu principal
menu() {
    while true; do
        clear
        printf "${YELLOW}1)${RESET} ${menu_option1}\n"
        printf "${YELLOW}2)${RESET} ${menu_option2}\n"
        printf "${YELLOW}3)${RESET} ${menu_option3}\n"
        printf "${YELLOW}4)${RESET} ${menu_option4}\n"
        printf "${YELLOW}5)${RESET} ${menu_option5}\n"
        printf "${YELLOW}6)${RESET} ${menu_option6}\n"
        printf "${YELLOW}0)${RESET} ${menu_option0}\n"
        printf "\n${BOLD}${choose_option_msg}:${RESET} "
        read -r opcao

        # Validar apenas números entre 0 e 6
        if ! [[ "$opcao" =~ ^[0-6]$ ]]; then
            printf "\n${RED}%s${RESET}\n" "$invalid_option_msg"
            sleep 1.5
            continue
        fi

        case "$opcao" in
            1) baixar_musicas ;;
            2) baixar_albuns ;;
            3) atualizar_arquivos ;;
            4) editar_config_interativa ;;
            5) ver_config_atual ;;
            6) atualizar_spotdl ;;
            0)
                printf "\n${GREEN}%s...${RESET}\n" "$exiting_msg"
                exit 0
                ;;
        esac
    done
}

# Execução principal
carregar_config
carregar_idioma "$CURRENT_LANG"
menu