#!/bin/bash
set -euo pipefail

# Cores
GREEN="\e[32;1m"
YELLOW="\e[33;1m"
RED="\e[31;1m"
CYAN="\e[36;1m"
BLUE="\e[34;1m"
RESET="\e[0m"

# Caminhos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
CONFIG_LINK="$HOME/.spotdl/config.json"
FINAL_DIR="$SCRIPT_DIR/downloaded"

# Configurações editáveis
declare -A config_editaveis=(
    [format]="mp3"
    [bitrate]="256k"
    [generate_lrc]="true"
    [skip_album_art]="false"
    [threads]="8"
    [sync_without_deleting]="false"
    [sync_remove_lrc]="false"
)


verificar_spotdl() {
    if ! command -v spotdl &>/dev/null; then
        echo -e "${RED}Erro: spotdl não está instalado.${RESET}"
        exit 1
    fi
}

criar_link_config() {
    mkdir -p "$(dirname "$CONFIG_LINK")"

    if [[ -e "$CONFIG_LINK" && ! -L "$CONFIG_LINK" ]]; then
        echo -e "${YELLOW}Arquivo de config padrão existe e não é link, fazendo backup...${RESET}"
        mv "$CONFIG_LINK" "${CONFIG_LINK}.backup.$(date +%s)"
    fi

    if [[ -L "$CONFIG_LINK" || -e "$CONFIG_LINK" ]]; then
        rm -f "$CONFIG_LINK"
    fi

    ln -s "$CONFIG_FILE" "$CONFIG_LINK"
    echo -e "${GREEN}Link simbólico criado/atualizado:${RESET} $CONFIG_LINK -> $CONFIG_FILE"
}

carregar_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        for chave in "${!config_editaveis[@]}"; do
            valor=$(jq -r --arg k "$chave" '.[$k] // empty' "$CONFIG_FILE")
            if [[ -n "$valor" && "$valor" != "null" ]]; then
                config_editaveis[$chave]="$valor"
            fi
        done
    fi
}

salvar_config() {
    mkdir -p "$FINAL_DIR"

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
    "output": "downloaded/{artist}/{album}/{title}.{output-ext}"
}
EOF
    echo -e "${GREEN}Configuração salva em $CONFIG_FILE${RESET}"
}

editar_config_interativa() {
    clear
    echo -e "${CYAN}Editar configurações básicas do spotdl:${RESET}"

    read -rp "Formato (mp3, flac, opus, wav, m4a) [${config_editaveis[format]}]: " entrada
    [[ -n "$entrada" ]] && config_editaveis[format]="$entrada"

    read -rp "Bitrate (auto, 128k, 256k, 320k, etc) [${config_editaveis[bitrate]}]: " entrada
    [[ -n "$entrada" ]] && config_editaveis[bitrate]="$entrada"

    read -rp "Número de downloads simultâneos (threads) [${config_editaveis[threads]}]: " entrada
    if [[ "$entrada" =~ ^[0-9]+$ ]]; then
        config_editaveis[threads]="$entrada"
    fi

    read -rp "Gerar letras sincronizadas? (s/n) [$( [[ ${config_editaveis[generate_lrc]} == true ]] && echo s || echo n )]: " entrada
    if [[ "$entrada" =~ ^[sS]$ ]]; then
        config_editaveis[generate_lrc]=true
    elif [[ "$entrada" =~ ^[nN]$ ]]; then
        config_editaveis[generate_lrc]=false
    fi

    read -rp "Pular download da capa do álbum? (s/n) [$( [[ ${config_editaveis[skip_album_art]} == true ]] && echo s || echo n )]: " entrada
    if [[ "$entrada" =~ ^[sS]$ ]]; then
        config_editaveis[skip_album_art]=true
    elif [[ "$entrada" =~ ^[nN]$ ]]; then
        config_editaveis[skip_album_art]=false
    fi

    read -rp "Manter arquivos antigos ao sincronizar? (sync_without_deleting) (s/n) [$( [[ ${config_editaveis[sync_without_deleting]} == true ]] && echo s || echo n )]: " entrada
    if [[ "$entrada" =~ ^[sS]$ ]]; then
        config_editaveis[sync_without_deleting]=true
    elif [[ "$entrada" =~ ^[nN]$ ]]; then
        config_editaveis[sync_without_deleting]=false
    fi

    read -rp "Remover letras sincronizadas durante sync? (sync_remove_lrc) (s/n) [$( [[ ${config_editaveis[sync_remove_lrc]} == true ]] && echo s || echo n )]: " entrada
    if [[ "$entrada" =~ ^[sS]$ ]]; then
        config_editaveis[sync_remove_lrc]=true
    elif [[ "$entrada" =~ ^[nN]$ ]]; then
        config_editaveis[sync_remove_lrc]=false
    fi

    salvar_config
}

baixar_musicas() {
    clear
    echo -e "${CYAN}Baixando músicas com base na configuração atual...${RESET}"

    criar_link_config

    # Lista de links
    links=()

    # Receber os links
    while true; do
        read -rp "$(echo -e "${BLUE}Insira o link do álbum ou música:${RESET} ")" link
        links+=("$link")

        read -rp "$(echo -e "${YELLOW}Deseja adicionar mais um link? (s/n):${RESET} ")" continuar
        [[ "$continuar" =~ ^[sS]$ ]] || break
    done

    echo -e "${GREEN}Iniciando downloads...${RESET}"

    for link in "${links[@]}"; do
        echo -e "${BLUE}Baixando: $link${RESET}"

        if [[ "$link" =~ playlist ]]; then
            playlist_id=$(basename "${link%%\?*}")
            destino_temp="$FINAL_DIR/playlists/$playlist_id"
            mkdir -p "$destino_temp"

            arquivo_spotdl="$FINAL_DIR/playlists/$playlist_id.spotdl"

            spotdl sync "$link" --save-file "$arquivo_spotdl" --output "$destino_temp"

            if [[ -f "$arquivo_spotdl" ]]; then
                playlist_name=$(jq -r '.name // empty' "$arquivo_spotdl" | sed 's/[\/:*?"<>|]/_/g')
            else
                playlist_name=""
            fi

            if [[ -n "$playlist_name" && "$playlist_name" != "null" ]]; then
                destino_final="$FINAL_DIR/playlists/$playlist_name"
                mv "$destino_temp" "$destino_final"
                echo -e "${GREEN}Playlist salva em: $destino_final${RESET}"
            else
                echo -e "${YELLOW}Não foi possível obter o nome da playlist. Mantido como: $destino_temp${RESET}"
                read -rp "Deseja digitar manualmente o nome da playlist para renomear a pasta? (s/n): " resp
                if [[ "$resp" =~ ^[sS]$ ]]; then
                    read -rp "Digite o nome desejado para a playlist: " nome_manual
                    nome_manual=$(echo "$nome_manual" | sed 's/[\/:*?"<>|]/_/g')
                    destino_final="$FINAL_DIR/playlists/$nome_manual"
                    mv "$destino_temp" "$destino_final"
                    echo -e "${GREEN}Playlist renomeada para: $destino_final${RESET}"
                else
                    echo -e "${YELLOW}Mantendo a pasta com o nome temporário: $destino_temp${RESET}"
                fi
            fi

            # Apaga o arquivo .spotdl após o uso
            if [[ -f "$arquivo_spotdl" ]]; then
                rm -f "$arquivo_spotdl"
            fi

        else
            spotdl download "$link"
        fi
        echo
    done

    echo -e "${GREEN}Todos os downloads finalizados.${RESET}"
}



atualizar_itens() {
    clear
    echo -e "${CYAN}Atualizando itens baixados (playlist/álbum)...${RESET}"
    read -rp "$(echo -e "${BLUE}Insira o link da playlist/álbum:${RESET} ")" link

    PLAYLISTS_DIR="$SCRIPT_DIR/playlists"
    mkdir -p "$PLAYLISTS_DIR"

    # Nome do arquivo de sync baseado no ID do link
    nome_arquivo=$(basename "$link" | cut -d '?' -f1)
    caminho_spotdl="$PLAYLISTS_DIR/$nome_arquivo.spotdl"

    # Pede o caminho onde baixar/sincronizar
    read -rp "$(echo -e "${YELLOW}Informe o caminho da pasta onde deseja salvar/sincronizar os arquivos:${RESET} ")" pasta_destino
    if [[ ! -d "$pasta_destino" ]]; then
        echo -e "${YELLOW}Pasta não existe. Criando...${RESET}"
        mkdir -p "$pasta_destino"
    fi

    criar_link_config

    # Executa o primeiro sync (cria arquivo .spotdl válido e baixa)
    echo -e "${YELLOW}Criando arquivo de sincronização e baixando os arquivos...${RESET}"
    spotdl sync "$link" --save-file "$caminho_spotdl" --output "$pasta_destino"

    echo -e "${GREEN}Arquivo de sincronização salvo em: $caminho_spotdl${RESET}"
    echo -e "${GREEN}Arquivos baixados em: $pasta_destino${RESET}"
}

menu() {
    while true; do
        echo -e "\n${YELLOW}========= MENU SPOTDL =========${RESET}"
        echo "1) Baixar músicas"
        echo "2) Criar ou editar configuração"
        echo "3) Atualizar playlist/álbum"
        echo "4) Ver configuração atual"
        echo "0) Sair"
        echo -n "Escolha uma opção: "
        read -r opcao

        case "$opcao" in
            1)
                if [[ -f "$CONFIG_FILE" ]]; then
                    baixar_musicas
                else
                    echo -e "${RED}Arquivo de configuração não encontrado. Crie um primeiro (opção 2).${RESET}"
                fi
                ;;
            2)
                editar_config_interativa
                ;;
            3)
                if [[ -f "$CONFIG_FILE" ]]; then
                    atualizar_itens
                else
                    echo -e "${RED}Arquivo de configuração não encontrado. Crie um primeiro (opção 2).${RESET}"
                fi
                ;;
            4)
                if [[ -f "$CONFIG_FILE" ]]; then
                    echo -e "${CYAN}Conteúdo atual de $CONFIG_FILE:${RESET}"
                    cat "$CONFIG_FILE"
                else
                    echo -e "${RED}Nenhuma configuração encontrada ainda.${RESET}"
                fi
                ;;
            0)
                echo -e "${GREEN}Saindo...${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida.${RESET}"
                ;;
        esac
    done
}

# Execução principal
clear
verificar_spotdl
carregar_config
menu
