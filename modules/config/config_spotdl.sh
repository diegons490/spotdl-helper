#!/bin/bash
# modules/config_spotdl.sh
# Funções para carregar, salvar e atualizar o arquivo de configuração do spotDL.

# Carrega configurações do spotDL
load_spotdl_config() {
	if [[ ! -f "$SPOTDL_CONFIG_PATH" ]]; then
		fmt_warning "Arquivo de configuração do spotDL não encontrado. Criando novo..."
		# DEFINIR VALORES PADRÃO ANTES DE SALVAR
		CURRENT_LYRIC_PROVIDERS=("genius" "musixmatch")
		save_spotdl_config
	fi

	if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
		for key in "${!EDITABLE_CONFIG[@]}"; do
			value=$(jq -r --arg k "$key" '.[$k] // empty' "$SPOTDL_CONFIG_PATH" 2>/dev/null || echo "")
			if [[ -n "$value" && "$value" != "null" ]]; then
				EDITABLE_CONFIG[$key]="$value"
			fi
		done

		# Carregar provedores de letras
		CURRENT_LYRIC_PROVIDERS=()
		if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
			while IFS= read -r provider; do
				[[ -n "$provider" && "$provider" != "null" ]] && CURRENT_LYRIC_PROVIDERS+=("$provider")
			done < <(jq -r '.lyrics_providers[]?' "$SPOTDL_CONFIG_PATH" 2>/dev/null)
		fi

		# Se não encontrar, use o padrão
		if [ ${#CURRENT_LYRIC_PROVIDERS[@]} -eq 0 ]; then
			CURRENT_LYRIC_PROVIDERS=("genius" "musixmatch")
		fi

		local full_template
		full_template=$(jq -r '.output // empty' "$SPOTDL_CONFIG_PATH")

		if [[ -z "$full_template" || "$full_template" == "null" ]]; then
			FINAL_DIR="${XDG_DOWNLOADS_DIR}/SpotDL"
			OUTPUT_STRUCTURE="{artist}/{album}/{title}.{output-ext}"
			save_spotdl_config
		else
			FINAL_DIR="${full_template%%\{*}"
			FINAL_DIR="${FINAL_DIR%/}"
			OUTPUT_STRUCTURE="${full_template#${FINAL_DIR}/}"
		fi
	fi
}

# Salva configurações do spotDL (arquivo completo)
save_spotdl_config() {
	mkdir -p "$(dirname "$SPOTDL_CONFIG_PATH")"

	[[ -z "$FINAL_DIR" ]] && FINAL_DIR="${XDG_DOWNLOADS_DIR}/SpotDL"
	[[ -z "$OUTPUT_STRUCTURE" ]] && OUTPUT_STRUCTURE="{artist}/{album}/{title}.{output-ext}"

	local full_output="${FINAL_DIR}/${OUTPUT_STRUCTURE}"
	local escaped_output_template="${full_output//\\/\\\\}"

	# Converter array de provedores de letras para formato JSON
	local lyrics_providers_json
	lyrics_providers_json=$(printf '%s\n' "${CURRENT_LYRIC_PROVIDERS[@]}" | jq -R . | jq -s .)

	cat >"$SPOTDL_CONFIG_PATH" <<EOF
{
    "client_id": "5f573c9620494bae87890c0f08a60293",
    "client_secret": "212476d9b0f3472eaa762d90b19b0ba8",
    "auth_token": null,
    "user_auth": false,
    "headless": false,
    "no_cache": ${EDITABLE_CONFIG[no_cache]},
    "max_retries": 3,
    "use_cache_file": false,
    "audio_providers": ["youtube-music"],
    "lyrics_providers": $lyrics_providers_json,
    "genius_token": "alXXDbPZtK1m2RrZ8I4k2Hn8Ahsd0Gh_o076HYvcdlBvmc0ULL1H8Z8xRlew5qaG",
    "playlist_numbering": false,
    "playlist_retain_track_cover": false,
    "scan_for_songs": false,
    "m3u": null,
    "overwrite": "${EDITABLE_CONFIG[overwrite]}",
    "search_query": null,
    "ffmpeg": "ffmpeg",
    "bitrate": "${EDITABLE_CONFIG[bitrate]}",
    "ffmpeg_args": null,
    "format": "${EDITABLE_CONFIG[format]}",
    "threads": ${EDITABLE_CONFIG[threads]},
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
    "generate_lrc": ${EDITABLE_CONFIG[generate_lrc]},
    "force_update_metadata": false,
    "only_verified_results": false,
    "sync_without_deleting": ${EDITABLE_CONFIG[sync_without_deleting]},
    "max_filename_length": null,
    "yt_dlp_args": null,
    "detect_formats": null,
    "save_errors": null,
    "ignore_albums": null,
    "proxy": null,
    "skip_explicit": false,
    "log_format": null,
    "redownload": false,
    "skip_album_art": ${EDITABLE_CONFIG[skip_album_art]},
    "create_skip_file": false,
    "respect_skip_file": false,
    "sync_remove_lrc": ${EDITABLE_CONFIG[sync_remove_lrc]},
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
    "output": "$escaped_output_template"
}
EOF
}

# Atualiza uma configuração específica
update_spotdl_config() {
	local key="$1"
	local value="$2"

	if [[ ! -f "$SPOTDL_CONFIG_PATH" ]]; then
		save_spotdl_config
		return
	fi

	local jq_filter
	case "$value" in
	true | false | null)
		jq_filter=".\"$key\" = $value"
		;;
	'' | *[!0-9]*)
		local escaped_value="${value//\"/\\\"}"
		jq_filter=".\"$key\" = \"$escaped_value\""
		;;
	*)
		jq_filter=".\"$key\" = $value"
		;;
	esac

	jq "$jq_filter" "$SPOTDL_CONFIG_PATH" >"${SPOTDL_CONFIG_PATH}.tmp" && mv "${SPOTDL_CONFIG_PATH}.tmp" "$SPOTDL_CONFIG_PATH"
}

# Salva uma única configuração
save_single_config() {
	local key="$1"
	local value="${EDITABLE_CONFIG[$key]}"

	case "$key" in
	format | bitrate | overwrite | threads | generate_lrc | skip_album_art | sync_without_deleting | sync_remove_lrc | no_cache)
		update_spotdl_config "$key" "$value"
		;;
	*)
		fmt_error "Chave desconhecida: $key" >&2
		;;
	esac
}
