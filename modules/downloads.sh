#!/bin/bash
# modules/downloads.sh
# Sistema de downloads completo e configurável - REFATORADO

# Carrega configurações essenciais
OUTPUT_TEMPLATE=$(jq -r '.output' "$SPOTDL_CONFIG_PATH")
OVERWRITE_MODE=$(jq -r '.overwrite // "skip"' "$SPOTDL_CONFIG_PATH")
THREADS=$(jq -r '.threads // 3' "$SPOTDL_CONFIG_PATH")
GENERATE_LRC=$(jq -r '.generate_lrc // "true"' "$SPOTDL_CONFIG_PATH")
SYNC_WITHOUT_DELETING=$(jq -r '.sync_without_deleting // "true"' "$SPOTDL_CONFIG_PATH")

# Função para recarregar configurações em tempo real
reload_download_config() {
	# Recarregar configurações do spotDL
	if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
		# Atualizar variáveis do spotDL
		OUTPUT_TEMPLATE=$(jq -r '.output' "$SPOTDL_CONFIG_PATH")
		OVERWRITE_MODE=$(jq -r '.overwrite // "skip"' "$SPOTDL_CONFIG_PATH")
		THREADS=$(jq -r '.threads // 3' "$SPOTDL_CONFIG_PATH")
		GENERATE_LRC=$(jq -r '.generate_lrc // "true"' "$SPOTDL_CONFIG_PATH")
		SYNC_WITHOUT_DELETING=$(jq -r '.sync_without_deleting // "true"' "$SPOTDL_CONFIG_PATH")

		# Atualizar configurações editáveis
		for key in "${!EDITABLE_CONFIG[@]}"; do
			local value
			value=$(jq -r --arg k "$key" '.[$k] // empty' "$SPOTDL_CONFIG_PATH" 2>/dev/null)
			if [[ -n "$value" && "$value" != "null" ]]; then
				EDITABLE_CONFIG["$key"]="$value"
			fi
		done

		# Recarregar estrutura de diretórios
		local full_template
		full_template=$(jq -r '.output // empty' "$SPOTDL_CONFIG_PATH")
		if [[ -n "$full_template" && "$full_template" != "null" ]]; then
			FINAL_DIR="${full_template%%\{*}"
			FINAL_DIR="${FINAL_DIR%/}"
			OUTPUT_STRUCTURE="${full_template#${FINAL_DIR}/}"
		fi
	fi

	# Recarregar configurações do helper
	if [[ -f "$HELPER_CONFIG_PATH" ]]; then
		MAX_BACKUPS=$(jq -r '.max_backups // 5' "$HELPER_CONFIG_PATH")
	fi

	# Recarregar provedores de letras
	CURRENT_LYRIC_PROVIDERS=()
	if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
		while IFS= read -r provider; do
			[[ -n "$provider" && "$provider" != "null" ]] && CURRENT_LYRIC_PROVIDERS+=("$provider")
		done < <(jq -r '.lyrics_providers[]?' "$SPOTDL_CONFIG_PATH" 2>/dev/null)
	fi
}

# Validações de links
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

# Executa spotdl com configurações
run_spotdl() {
	# Recarregar configurações antes de executar
	reload_download_config

	local command="$1"
	local link="$2"
	shift 2
	local extra_args=("$@")

	local base_args=(
		"--format" "${EDITABLE_CONFIG[format]}"
		"--bitrate" "${EDITABLE_CONFIG[bitrate]}"
		"--output" "$OUTPUT_TEMPLATE"
		"--overwrite" "$OVERWRITE_MODE"
		"--threads" "$THREADS"
	)

	[[ "$GENERATE_LRC" == "true" ]] && base_args+=(--generate-lrc)
	[[ "${EDITABLE_CONFIG[no_cache]}" == "true" ]] && base_args+=(--no-cache)

	# Adicionar provedores de letras se configurado
	if [ ${#CURRENT_LYRIC_PROVIDERS[@]} -gt 0 ]; then
		base_args+=(--lyrics)
		for provider in "${CURRENT_LYRIC_PROVIDERS[@]}"; do
			base_args+=("$provider")
		done
	fi

	# Monta a linha de comando para exibição
	local cmd_line="spotdl $command \"$link\""
	for arg in "${base_args[@]}" "${extra_args[@]}"; do
		cmd_line+=" \"$arg\""
	done

	fmt_cmd "$cmd_line"
	newline

	# Executa o comando com a ordem correta: comando, link, argumentos
	"$SPOTDL_CMD" "$command" "$link" "${base_args[@]}" "${extra_args[@]}"
}

# Baixar músicas ou álbuns
download_music() {
	clear
	reload_download_config
	fmt_header "$(get_msg menu_option1)"

	fmt_config_detail "$(get_msg label_download_path)" "$FINAL_DIR"
	fmt_config_detail "$(get_msg config_output_template)" "$(get_template_display_name)"

	local links=()
	local link

	while true; do
		fmt_prompt "\n$(get_msg enter_link)\n"
		read -r link
		newline

		[[ "$link" == "0" ]] && return 0
		[[ -z "$link" ]] && continue

		if ! is_valid_track_link "$link" && ! is_valid_album_link "$link"; then
			fmt_error "$(get_msg invalid_link_type)\n"
			fmt_warning "$(get_msg valid_link_types_tracks_albums)"
			continue
		fi

		links+=("$link")

		if ! prompt_yes_no_ansi "$(get_msg add_more_links)"; then
			break
		fi
	done

	newline
	fmt_success "$(get_msg starting_downloads)\n"

	for link in "${links[@]}"; do
		fmt_info "$(get_msg downloading): $link"
		newline
		fmt_warning "$(get_msg executing_label)"
		run_spotdl "download" "$link"
	done

	fmt_success "$(get_msg all_downloads_completed)\n"
	prompt_enter_continue
}

# Baixar playlists
download_playlists() {
	clear
	reload_download_config
	fmt_header "$(get_msg menu_option2)"

	fmt_config_detail "$(get_msg label_download_path)" "$FINAL_DIR"
	fmt_config_detail "$(get_msg config_output_template)" "$(get_template_display_name)"

	local links=()
	local link

	extract_playlist_id() {
		local url="${1%%[?#]*}"
		local patterns=(
			'open\.spotify\.com/playlist/([a-zA-Z0-9]+)'
			'spotify\.com/playlist/([a-zA-Z0-9]+)'
			'spotify:playlist:([a-zA-Z0-9]+)'
			'^([a-zA-Z0-9]{22})$'
		)

		for pattern in "${patterns[@]}"; do
			if [[ "$url" =~ $pattern ]]; then
				echo "${BASH_REMATCH[1]}"
				return 0
			fi
		done

		local last_segment="${url##*/}"
		if [[ "$last_segment" =~ ^[a-zA-Z0-9]{22}$ ]]; then
			echo "$last_segment"
			return 0
		fi

		echo "invalid"
		return 1
	}

	while true; do
		fmt_prompt "\n$(get_msg enter_link)\n"
		read -r link
		newline

		[[ "$link" == "0" ]] && return 0
		[[ -z "$link" ]] && continue

		if ! is_valid_playlist_link "$link"; then
			fmt_error "$(get_msg invalid_playlist_link)\n"
			fmt_warning "$(get_msg valid_link_types_playlists)"
			continue
		fi

		local playlist_id
		playlist_id=$(extract_playlist_id "$link")
		if [[ "$playlist_id" == "invalid" ]]; then
			fmt_error "$(get_msg invalid_playlist_link)\n"
			fmt_warning "$(printf "$(get_msg received_url)" "$link")"
			continue
		fi

		links+=("$link")
		if ! prompt_yes_no_ansi "$(get_msg add_more_links)"; then
			break
		fi
	done

	local playlists_dir="$FINAL_DIR/Playlists/Sync_files"
	local m3u_dir="$FINAL_DIR/Playlists"
	mkdir -p "$playlists_dir" "$m3u_dir" || {
		fmt_error "$(get_msg no_write_permission)\n"
		return 1
	}

	newline
	fmt_success "$(get_msg starting_downloads)"
	newline

	for link in "${links[@]}"; do
		fmt_info "$(get_msg downloading): $link"
		newline
		playlist_id=$(extract_playlist_id "$link")
		[[ "$playlist_id" == "invalid" ]] && continue

		local spotdl_file="$playlists_dir/$playlist_id.spotdl"
		local temp_m3u_file="$m3u_dir/spotdl_temp_$playlist_id.m3u8"
		local final_m3u_file=""

		(
			local work_dir
			work_dir=$(mktemp -d)
			cd "$work_dir" || exit 1

			fmt_info "$(printf "$(get_msg starting_download_temp_dir)" "$work_dir")\n"
			fmt_warning "$(get_msg executing_label)"

			# Usando run_spotdl para executar o sync
			if ! run_spotdl "sync" "$link" \
				"--save-file" "$spotdl_file" \
				"--overwrite" "metadata" \
				"--m3u" "spotdl_temp_$playlist_id.m3u8"; then

				fmt_error "$(printf "$(get_msg error_downloading_playlist)" "$link")\n"
				cd ..
				rm -rf "$work_dir"
				exit 1
			fi

			if [[ -f "spotdl_temp_$playlist_id.m3u8" ]]; then
				mv "spotdl_temp_$playlist_id.m3u8" "$temp_m3u_file"
				fmt_success "$(printf "$(get_msg temp_m3u_moved)" "$temp_m3u_file")\n"
			else
				fmt_warning "$(get_msg m3u_not_generated)\n"
			fi

			cd ..
			rm -rf "$work_dir"
		)

		if [[ -f "$temp_m3u_file" ]]; then
			local wait_time=0
			while [[ ! -s "$spotdl_file" && $wait_time -lt 10 ]]; do
				sleep 0.5
				((wait_time++))
			done

			local playlist_name=""
			if [[ -f "$spotdl_file" && -s "$spotdl_file" ]]; then
				playlist_name=$(jq -r '.songs[0].list_name // .list_name // empty' "$spotdl_file")
				fmt_success "$(printf "$(get_msg playlist_name_extracted)" "${playlist_name:-N/A}")\n"
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
				fmt_success "$(get_msg playlist_saved_as) $final_m3u_file"
			else
				fmt_warning "$(get_msg m3u_kept_as) $temp_m3u_file"
			fi
		else
			fmt_warning "$(printf "$(get_msg m3u_not_generated_for)" "$link")\n"
		fi

		fmt_separator
		newline
	done

	fmt_success "$(get_msg all_downloads_completed)\n"
	prompt_enter_continue
}

# Baixar álbuns de artistas
download_artist_albums() {
	clear
	reload_download_config
	fmt_header "$(get_msg menu_option3)"

	fmt_config_detail "$(get_msg label_download_path)" "$FINAL_DIR"
	fmt_config_detail "$(get_msg config_output_template)" "$(get_template_display_name)"
	newline

	local links=()
	local link

	while true; do
		fmt_prompt "$(get_msg enter_link)\n"
		read -r link
		newline

		[[ "$link" == "0" ]] && return 0
		[[ -z "$link" ]] && continue

		if ! is_valid_artist_link "$link"; then
			fmt_error "$(get_msg invalid_artist_link)\n"
			fmt_warning "$(get_msg valid_link_types_artists)\n"
			continue
		fi

		links+=("$link")

		if ! prompt_yes_no_ansi "$(get_msg add_more_links)"; then
			break
		fi
	done

	newline
	fmt_success "$(get_msg starting_downloads)"
	newline

	for link in "${links[@]}"; do
		fmt_info "$(get_msg downloading): $link"
		newline
		fmt_warning "$(get_msg executing_label)"
		run_spotdl "download" "$link" "--fetch-albums"
	done

	newline
	fmt_success "$(get_msg all_downloads_completed)\n"
	prompt_enter_continue
}

# Sincronizar playlists/álbuns
sync_files() {
	clear
	reload_download_config
	fmt_header "$(get_msg menu_option4)"

	fmt_config_item "$(get_msg label_download_path)" "$FINAL_DIR"
	newline

	local links=()
	local link
	local add_more=true

	while $add_more; do
		fmt_prompt "$(get_msg enter_link)\n"
		read -r link
		newline

		[[ "$link" == "0" ]] && return 0
		[[ -z "$link" ]] && continue

		if ! is_valid_playlist_link "$link" && ! is_valid_album_link "$link"; then
			fmt_error "$(get_msg invalid_sync_link)\n"
			fmt_warning "$(get_msg valid_link_types_sync)\n"
			continue
		fi

		links+=("$link")

		if ! prompt_yes_no_ansi "$(get_msg add_more_links)"; then
			add_more=false
		fi
	done

	if [ ${#links[@]} -eq 0 ]; then
		fmt_warning "$(get_msg no_links_to_sync)\n"
		prompt_enter_continue
		return
	fi

	local playlists_dir="$FINAL_DIR/playlists"
	mkdir -p "$playlists_dir" || {
		fmt_error "$(get_msg no_write_permission)\n"
		return 1
	}

	for link in "${links[@]}"; do
		local filename
		filename=$(basename "${link%%\?*}")
		local filename_safe
		filename_safe=$(echo "$filename" | sed 's/[\/:*?"<>|]/_/g')
		local spotdl_file="$playlists_dir/$filename_safe.spotdl"

		newline
		fmt_success "$(get_msg starting_downloads)"

		newline
		fmt_warning "$(get_msg executing_label)"

		# Usando run_spotdl para executar o sync
		if run_spotdl "sync" "$link" \
			"--save-file" "$spotdl_file"; then

			fmt_success "$(get_msg sync_completed)"
		else
			fmt_error "$(get_msg sync_failed)\n"
		fi

	done

	newline
	prompt_enter_continue
}
