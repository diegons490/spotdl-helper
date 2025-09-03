#!/bin/bash
# modules/download/download_music.sh
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
