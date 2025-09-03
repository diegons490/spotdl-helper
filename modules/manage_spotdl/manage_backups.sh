#!/bin/bash
# modules/manage_spotdl/manage_backups.sh
# Lista backups e permite interação para deletar

manage_backups() {
	clear
	fmt_header "$(get_msg menu_list_backups)"

	# Garante que BASE_DIR esteja definido
	if [[ -z "$BASE_DIR" ]]; then
		BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
	fi

	# Define BACKUP_DIR se não vier do ambiente
	BACKUP_DIR="${BACKUP_DIR:-$BASE_DIR/bkp_spotdl}"

	# Define APP_NAME e FILE_SUFFIX se não vierem do ambiente
	APP_NAME="${APP_NAME:-spotdl}"
	FILE_SUFFIX="${FILE_SUFFIX:-linux}"

	if [[ ! -d "$BACKUP_DIR" ]]; then
		fmt_error "$(get_msg no_backups_dir)\n"
		prompt_enter_continue
		return 1
	fi

	local files=()
	mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -r)

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

		fmt_info "$(get_msg enter_backup_number_to_delete)\n"
		fmt_info "$(get_msg press_0_to_cancel)\n"
		read -n 1 -r -s choice

		if [[ "$choice" == "0" ]]; then
			return 0
		fi

		if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && ((choice <= ${#files[@]})); then
			local selected_file="${files[$((choice - 1))]}"
			if prompt_yes_no "$(get_msg confirm_delete_backup) '$(basename "$selected_file")'?\n"; then
				rm -f "$selected_file"
				if [[ $? -eq 0 ]]; then
					fmt_success "$(get_msg backup_deleted)\n"
					mapfile -t files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${APP_NAME}-*${FILE_SUFFIX}" 2>/dev/null | sort -r)
					if [[ ${#files[@]} -eq 0 ]]; then
						fmt_warning "$(get_msg no_backups_found)\n"
						break
					fi
				else
					fmt_error "$(get_msg error_deleting_backup)\n"
					return 1
				fi
			else
				fmt_error "$(get_msg operation_canceled)\n"
			fi
		else
			fmt_error "$(get_msg invalid_choice)\n"
			sleep 1
		fi
	done
}
