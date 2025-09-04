#!/bin/bash
# modules/menu/spotdl_menu.sh
# Menu de gerenciamento do SpotDL

spotdl_menu() {
	while true; do
		clear
		fmt_header "$(get_msg menu_option6)"

		fmt_option "1" "$(get_msg menu_update_spotdl)"
		fmt_option "2" "$(get_msg menu_restore_backup)"
		fmt_option "3" "$(get_msg menu_list_backups)"
		printf "\n"
		fmt_option "0" "$(get_msg menu_return)"

		fmt_prompt "\n$(get_msg choose_option_menu)"
		read -n 1 -r choice
		echo

		case "$choice" in
		1) spotdl_update ;;
		2) backup_restore ;;
		3) backup_manage ;;
		0) return ;;
		*)
			newline
			fmt_error "$(get_msg invalid_option)"
			sleep 1
			;;
		esac
	done
}
