#!/bin/bash
# modules/download/download_artist_albums.sh
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
