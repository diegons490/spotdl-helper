#!/bin/bash
# modules/menu/settings_manual.sh
# Menu de configuração manual

config_manual() {
	while true; do
		clear
		fmt_header "$(get_msg config_manual)"

		fmt_option "1" "$(get_msg config_open_spotdl)"
		fmt_option "2" "$(get_msg config_open_helper)"
		printf "\n"
		fmt_option "0" "$(get_msg menu_return)"

		fmt_prompt "\n$(get_msg choose_option_menu)"
		read -n 1 -r choice
		echo

		case "$choice" in
		1) open_manual_config "spotdl" ;;
		2) open_manual_config "helper" ;;
		0) return ;;
		*)
			newline
			fmt_error "$(get_msg invalid_option)"
			sleep 1
			;;
		esac
	done
}
