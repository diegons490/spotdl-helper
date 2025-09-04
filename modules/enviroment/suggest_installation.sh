#!/bin/bash
# modules/enviroment/suggest_installation.sh
# Sugerir comando de instalação

suggest_installation() {
	local packages=("$@")
	local manager=""
	local command=""
	local found_manager=false

	# Detectar gerenciador de pacotes
	if command -v pacman &>/dev/null; then
		manager="pacman"
		command="sudo pacman -S ${packages[*]}"
		found_manager=true
	elif command -v apt &>/dev/null; then
		manager="apt"
		command="sudo apt update && sudo apt install ${packages[*]}"
		found_manager=true
	elif command -v dnf &>/dev/null; then
		manager="dnf"
		command="sudo dnf install ${packages[*]}"
		found_manager=true
	elif command -v zypper &>/dev/null; then
		manager="zypper"
		command="sudo zypper install ${packages[*]}"
		found_manager=true
	elif command -v emerge &>/dev/null; then
		manager="emerge"
		command="sudo emerge ${packages[*]}"
		found_manager=true
	elif command -v apk &>/dev/null; then
		manager="apk"
		command="sudo apk add ${packages[*]}"
		found_manager=true
	fi

	if $found_manager; then
		fmt_info "$(get_msg install_with)"
		fmt_info "  $command"
	else
		fmt_error "$(get_msg error_pkg_manager_not_detected)"
		fmt_warning "$(get_msg please_install_manually)"

		# Instruções manuais para cada pacote
		for dep in "${packages[@]}"; do
			fmt_info "  $dep:"
			case "$dep" in
			ffmpeg)
				fmt_info "    $(get_msg ffmpeg_manual_install)"
				;;
			jq)
				fmt_info "    $(get_msg jq_manual_install)"
				;;
			esac
		done
	fi

	fmt_warning "$(get_msg after_install_instructions)"
	prompt_enter_continue
}
