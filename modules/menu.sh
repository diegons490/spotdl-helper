#!/bin/bash
# modules/menu.sh - Menu principal e todos os submenus CLI

source "$MODULES_DIR/config.sh"
source "$MODULES_DIR/spotdl.sh"
source "$MODULES_DIR/downloads.sh"
source "$MODULES_DIR/utils.sh"

menu() {
    while true; do
        clear
        print_section_header "$(get_msg app_title)"

        printf "${YELLOW}1)${RESET} $(get_msg menu_option1)\n"
        printf "${YELLOW}2)${RESET} $(get_msg menu_option2)\n"
        printf "${YELLOW}3)${RESET} $(get_msg menu_option3)\n"
        printf "${YELLOW}4)${RESET} $(get_msg menu_option4)\n"
        printf "${YELLOW}5)${RESET} $(get_msg menu_option5)\n"
        printf "${YELLOW}6)${RESET} $(get_msg menu_option6)\n"
        printf "${YELLOW}0)${RESET} $(get_msg menu_option0)\n"

        printf "\n${BOLD}${GREEN}$(get_msg choose_option):${RESET} "
        read -n 1 -r option

        if ! [[ "$option" =~ ^[0-6]$ ]]; then
            printf "\n${RED}$(get_msg invalid_option)${RESET}\n"
            printf "${YELLOW}$(get_msg press_enter_continue)${RESET}"
            read -n 1 -r
            continue
        fi

        case "$option" in
            1) download_music ;;
            2) download_playlists ;;
            3) download_artist_albums ;;
            4) sync_files ;;
            5) settings ;;
            6) manage_spotdl_menu ;;
            0)
                printf "\n${GREEN}$(get_msg exiting)...${RESET}\n"
                sleep 1
                exit 0
                ;;
        esac
    done
}

manage_spotdl_menu() {
    while true; do
        clear
        print_section_header "$(get_msg menu_option6)"

        printf "${YELLOW}1)${RESET} $(get_msg menu_update_spotdl)\n"
        printf "${YELLOW}2)${RESET} $(get_msg menu_restore_backup)\n"
        printf "${YELLOW}3)${RESET} $(get_msg menu_list_backups)\n"
        printf "${YELLOW}0)${RESET} $(get_msg menu_return_main)\n"

        printf "\n${BOLD}${GREEN}$(get_msg choose_option):${RESET} "
        read -n 1 -r choice
        echo

        case "$choice" in
            1) update_spotdl ;;
            2) restore_backup ;;
            3) manage_backups ;;
            0) return ;;
            *) printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option)"
               sleep 1 ;;
        esac
    done
}

settings() {
    while true; do
        clear
        print_section_header "$(get_msg menu_option5)"

        printf "${YELLOW}1)${RESET} $(get_msg config_interactive)\n"
        printf "${YELLOW}2)${RESET} $(get_msg config_manual)\n"
        printf "${YELLOW}0)${RESET} $(get_msg menu_return_main)\n"

        printf "\n${BOLD}${GREEN}$(get_msg choose_option):${RESET} "
        read -n 1 -r choice
        echo

        case "$choice" in
            1) edit_config_interactively ;;
            2) settings_manual ;;
            0) return ;;
            *) printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option)"
               sleep 1 ;;
        esac
    done
}

settings_manual() {
    while true; do
        clear
        print_section_header "$(get_msg config_manual)"

        printf "${YELLOW}1)${RESET} $(get_msg config_open_spotdl)\n"
        printf "${YELLOW}2)${RESET} $(get_msg config_open_helper)\n"
        printf "${YELLOW}0)${RESET} $(get_msg menu_return_main)\n"

        printf "\n${BOLD}${GREEN}$(get_msg choose_option):${RESET} "
        read -n 1 -r choice
        echo

        case "$choice" in
            1) open_manual_config "$SPOTDL_CONFIG_MANUAL" ;;
            2) open_manual_config "$HELPER_CONFIG_MANUAL" ;;
            0) return ;;
            *) printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option)"
               sleep 1 ;;
        esac
    done
}
