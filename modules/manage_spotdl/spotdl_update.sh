#!/bin/bash
# modules/manage_spotdl/update_spotdl.sh
# Função de atualização do SpotDL

spotdl_update() {
	while true; do
		clear
		fmt_header "$(get_msg menu_update_spotdl)"
		mkdir -p "$BIN_DIR" "$BACKUP_DIR"

		local API_URL="https://api.github.com/repos/spotDL/spotify-downloader/releases/latest"
		local response
		response=$(curl -s "$API_URL")

		local remote_version
		remote_version=$(echo "$response" | grep '"tag_name":' | cut -d '"' -f4 | sed 's/^v//')
		local changelog
		changelog=$(echo "$response" | jq -r '.body' | sed 's/\\r\\n/\n/g')

		new_file="${APP_NAME}-${remote_version}${FILE_SUFFIX}"

		if [[ -z "${SPOTDL_CMD:-}" || ! -x "$SPOTDL_CMD" ]]; then
			fmt_error "$(get_msg no_local_spotdl)"
			newline
			fmt_warning "$(get_msg run_script_again)"
			newline
			return 1
		fi

		local local_version
		local_version=$("$SPOTDL_CMD" --version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

		if [[ "$local_version" == "$remote_version" ]]; then
			fmt_success "$(get_msg spotdl_already_updated): $local_version"
			newline
			prompt_enter_continue
			return 0
		fi

		fmt_warning "$(get_msg new_version_available): $local_version → $remote_version"
		newline

		local backup_limit backup_count
		backup_limit=$(get_backup_limit)
		backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | wc -l)

		if ((backup_count >= backup_limit)); then
			fmt_error "$(get_msg max_backups_reached) (${backup_count}/${backup_limit})"
			newline
			fmt_warning "$(get_msg delete_backup_to_update)"
			newline

			if prompt_yes_no_ansi "$(get_msg ask_manage_backups)"; then
				manage_backups
				continue
			else
				fmt_error "$(get_msg update_canceled)"
				newline
				return 1
			fi
		fi

		if prompt_yes_no_ansi "$(get_msg update_now)"; then
			newline
			fmt_info "$(get_msg moving_old_version)"
			newline
			mv "$SPOTDL_CMD" "$BACKUP_DIR/$(basename "$SPOTDL_CMD")"

			fmt_info "$(get_msg backup_created)"
			newline

			fmt_info "$(get_msg downloading_new_version)..."
			newline

			if curl -fLo "$BIN_DIR/$new_file" "https://github.com/spotDL/spotify-downloader/releases/download/v${remote_version}/${new_file}"; then
				chmod +x "$BIN_DIR/$new_file"
				SPOTDL_CMD="$BIN_DIR/$new_file"
				newline
				fmt_success "$(printf "$(get_msg update_completed)" "$remote_version")"
				newline

				if [[ -n "$changelog" && "$changelog" != "null" ]]; then
					newline
					fmt_header "$(get_msg changelog_title)"
					fmt_info "$changelog"
					newline
					fmt_separator
				fi

				fmt_error "$(get_msg reboot_script)"
				newline

				prompt_enter_continue
				return 0
			else
				fmt_error "$(get_msg error_downloading_version) $remote_version"
				newline
				return 1
			fi
		else
			fmt_error "$(get_msg update_canceled)."
			newline
			return 0
		fi
	done
}
