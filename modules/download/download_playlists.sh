#!/bin/bash
# modules/download/download_playlists.sh
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
