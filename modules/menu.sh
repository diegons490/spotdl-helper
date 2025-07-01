#!/bin/bash
# modules/menu.sh

# Menu principal refatorado
menu() {
    while true; do
        clear
        # Cabeçalho do menu
        printf "${CYAN}===========================================${RESET}\n"
        printf "${BOLD}${YELLOW} %s${RESET}\n" "$(get_msg app_title)"
        printf "${CYAN}===========================================${RESET}\n\n"
        
        # Opções do menu com cores (refatoradas)
        printf "${YELLOW}1)${RESET} $(get_msg menu_option1)\n"
        printf "${YELLOW}2)${RESET} $(get_msg menu_option2)\n"
        printf "${YELLOW}3)${RESET} $(get_msg menu_option3)\n"
        printf "${YELLOW}4)${RESET} $(get_msg menu_option4)\n"
        printf "${YELLOW}5)${RESET} $(get_msg menu_option5)\n"
        printf "${YELLOW}6)${RESET} $(get_msg menu_option6)\n"
        printf "${YELLOW}0)${RESET} $(get_msg menu_option0)\n"
        
        # Prompt de seleção
        printf "\n${BOLD}${GREEN}$(get_msg choose_option):${RESET} "
        read -n 1 -r option

        # Validação de entrada
        if ! [[ "$option" =~ ^[0-6]$ ]]; then
            printf "\n${RED}$(get_msg invalid_option)${RESET}\n"
            printf "${YELLOW}$(get_msg press_enter_continue)${RESET}"
            read -n 1 -r
            continue
        fi

        # Processamento das opções refatoradas
        case "$option" in
            1) 
                download_music 
                ;;
            2) 
                download_playlists
                ;;
            3) 
                download_artist_albums 
                ;;
            4) 
                sync_files 
                ;;
            5) 
                edit_config_interactively 
                ;;
            6) 
                manage_spotdl_menu
                ;;
            0)
                printf "\n${GREEN}$(get_msg exiting)...${RESET}\n"
                sleep 1
                exit 0
                ;;
        esac
    done
}

# Menu de gerenciamento do SpotDL (refatorado)
manage_spotdl_menu() {
    while true; do
        clear
        print_section_header "$(get_msg menu_option6)"  # Usa a string do menu principal

        echo "1) $(get_msg menu_update_spotdl)"
        echo "2) $(get_msg menu_restore_backup)"
        echo "3) $(get_msg menu_list_backups)"
        echo "0) $(get_msg menu_return_main)"
        echo
        printf "${YELLOW}%s:${RESET} " "$(get_msg choose_option)"
        read -n 1 -r choice
        echo

        case "$choice" in
            1) 
                update_spotdl 
                ;;
            2) 
                restore_backup
                ;;
            3)
                manage_backups                
                ;;
            0) return ;;
            *) 
                printf "\n${RED}%s${RESET}\n" "$(get_msg invalid_option)"
                sleep 1 
                ;;
        esac
    done
}

# Função auxiliar para mostrar cabeçalhos de seção
print_section_header() {
    local title="$1"
    printf "\n${CYAN}===========================================${RESET}\n"
    printf "${BOLD}${CYAN} %-40s${RESET}\n" "$title"
    printf "${CYAN}===========================================${RESET}\n\n"
}