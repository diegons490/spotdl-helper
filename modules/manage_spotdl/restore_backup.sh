#!/bin/bash
# modules/manage_spotdl/restore_backup.sh
# Restaura backup selecionado

restore_backup() {
	clear
	fmt_header "$(get_msg menu_restore_backup)"
	if [[ ! -d "$BACKUP_DIR" ]]; then
		fmt_error "$(get_msg no_backups_dir)\n"
		prompt_enter_continue
		return 1
	fi

	local files=()
	mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -Vr)

	if [[ ${#files[@]} -eq 0 ]]; then
		fmt_error "$(get_msg no_backups_found)\n"
		prompt_enter_continue
		return 1
	fi

	while true; do
		fmt_info "$(get_msg available_backups)\n"

		local i=1
		for file in "${files[@]}"; do
			fmt_option "$i" "$(basename "$file")\n"
			((i++))
		done

		fmt_info "$(get_msg enter_backup_number) (1-${#files[@]})\n"
		fmt_prompt "$(get_msg press_0_to_cancel)\n"

		read -n 1 -r -s choice
		printf "\n"

		if [[ "$choice" == "0" ]]; then
			fmt_error "$(get_msg restore_cancelled)\n"
			return 1
		fi

		if [[ "$choice" =~ ^[1-9]$ ]] && ((choice <= ${#files[@]})); then
			local selected_file="${files[$((choice - 1))]}"
			local bin_file="$(basename "$selected_file")"
			local bin_path="$BIN_DIR/$bin_file"

			fmt_info "$(get_msg cleaning_bin)\n"
			rm -f "$BIN_DIR"/* 2>/dev/null || true

			fmt_info "$(get_msg moving_backup)\n"
			mv "$selected_file" "$bin_path"
			chmod +x "$bin_path"

			fmt_success "$(get_msg backup_restored)\n"
			fmt_error "$(get_msg reboot_script)\n"

			prompt_enter_continue
			return 0
		else
			fmt_error "$(get_msg invalid_choice)\n"
			sleep 1
		fi
	done
}
