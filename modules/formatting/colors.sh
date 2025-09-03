#!/bin/bash
# modules/formatting/colors.sh
# Definição de cores de texto

# -------------------------------
# Cores foreground (texto)
# -------------------------------
get_fg_color() {
	case "$1" in
	black) tput setaf 0 ;;
	red) tput setaf 1 ;;
	green) tput setaf 2 ;;
	yellow) tput setaf 3 ;;
	blue) tput setaf 4 ;;
	magenta) tput setaf 5 ;;
	cyan) tput setaf 6 ;;
	white) tput setaf 7 ;;
	bright_black) tput setaf 8 ;;
	bright_red) tput setaf 9 ;;
	bright_green) tput setaf 10 ;;
	bright_yellow) tput setaf 11 ;;
	bright_blue) tput setaf 12 ;;
	bright_magenta) tput setaf 13 ;;
	bright_cyan) tput setaf 14 ;;
	bright_white) tput setaf 15 ;;
	esac
}

# -------------------------------
# Cores background
# -------------------------------
get_bg_color() {
	case "$1" in
	black) tput setab 0 ;;
	red) tput setab 1 ;;
	green) tput setab 2 ;;
	yellow) tput setab 3 ;;
	blue) tput setab 4 ;;
	magenta) tput setab 5 ;;
	cyan) tput setab 6 ;;
	white) tput setab 7 ;;
	bright_black) tput setab 8 ;;
	bright_red) tput setab 9 ;;
	bright_green) tput setab 10 ;;
	bright_yellow) tput setab 11 ;;
	bright_blue) tput setab 12 ;;
	bright_magenta) tput setab 13 ;;
	bright_cyan) tput setab 14 ;;
	bright_white) tput setab 15 ;;
	esac
}
