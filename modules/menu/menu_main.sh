#!/bin/bash
# modules/menu/menu_main.sh
# Menu principal

menu_main() {
	while true; do
		clear
		fmt_header "$(get_msg app_title)"

		fmt_option "1" "$(get_msg menu_option1)"
		fmt_option "2" "$(get_msg menu_option2)"
		fmt_option "3" "$(get_msg menu_option3)"
		fmt_option "4" "$(get_msg menu_option4)"
		fmt_option "5" "$(get_msg menu_option5)"
		fmt_option "6" "$(get_msg menu_option6)"
		printf "\n"
		fmt_option "0" "$(get_msg menu_option0)"

		fmt_prompt "\n$(get_msg choose_option_menu)"
		read -n 1 -r option

		if ! [[ "$option" =~ ^[0-6]$ ]]; then
			newline 2
			fmt_error "$(get_msg invalid_option)"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -n 1 -r
			continue
		fi

		case "$option" in
		1) download_music ;;
		2) download_playlists ;;
		3) download_artist_albums ;;
		4) sync_files ;;
		5) config_main ;;
		6) spotdl_menu ;;
		0)
			newline 2
			fmt_info "$(get_msg exiting)..."
			sleep 1
			exit 0
			;;
		esac
	done
}
