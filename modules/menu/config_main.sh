#!/bin/bash
# modules/menu/config_main.sh
# Menu de configurações

config_main() {
	while true; do
		clear
		fmt_header "$(get_msg menu_option5)"

		fmt_option "1" "$(get_msg config_wizard)"
		fmt_option "2" "$(get_msg config_manual)"
		printf "\n"
		fmt_option "0" "$(get_msg menu_return)"

		fmt_prompt "\n$(get_msg choose_option_menu)"
		read -n 1 -r choice
		echo

		case "$choice" in
		1) config_wizard ;;
		2) config_manual ;;
		0) return ;;
		*)
			newline
			fmt_error "$(get_msg invalid_option)"
			sleep 1
			;;
		esac
	done
}
