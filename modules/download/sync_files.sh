#!/bin/bash
# modules/download/sync_files.sh
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
