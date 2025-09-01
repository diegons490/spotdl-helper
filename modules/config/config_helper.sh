#!/bin/bash
# modules/config_helper.sh
# Funções para carregar e salvar configurações do helper (linguagem, backups).

# Carrega configurações do helper
load_helper_config() {
	if [[ -f "$HELPER_CONFIG_PATH" ]]; then
		CURRENT_LANG=$(jq -r '.language // empty' "$HELPER_CONFIG_PATH")
		MAX_BACKUPS=$(jq -r '.max_backups // empty' "$HELPER_CONFIG_PATH")
	fi

	[[ -z "$CURRENT_LANG" ]] && CURRENT_LANG="en_US"
	[[ -z "$MAX_BACKUPS" ]] && MAX_BACKUPS=5

	if [[ ! -f "$HELPER_CONFIG_PATH" ]]; then
		save_helper_config
	fi
}

# Salva configurações do helper
save_helper_config() {
	mkdir -p "$HELPER_CONFIG_DIR"
	cat >"$HELPER_CONFIG_PATH" <<EOF
{
    "language": "$CURRENT_LANG",
    "max_backups": $MAX_BACKUPS
}
EOF
}

# Edita o idioma atual do helper
edit_language() {
	while true; do
		clear
		fmt_header "$(get_msg "label_language")"

		local i=0
		local lang_options=(
			"pt_BR:Português Brasil   (pt_BR)"
			"en_US:English            (en_US)"
			"es_ES:Español            (es_ES)"
		)

		for option in "${lang_options[@]}"; do
			local lang_code="${option%%:*}"
			local label="${option#*:}"
			((i++))

			[[ "$CURRENT_LANG" == "$lang_code" ]] && marker="[x]" || marker="[ ]"
			fmt_option "$i" "$marker $label"
		done

		newline
		fmt_option "0" "$(get_msg "menu_return")"
		newline
		fmt_prompt "$(get_msg "choose_language") (0-${i}):"
		read -n 1 -r lang_choice

		case "$lang_choice" in
		1 | 2 | 3)
			local selected_option="${lang_options[$((lang_choice - 1))]}"
			new_lang="${selected_option%%:*}"

			if [[ "$CURRENT_LANG" != "$new_lang" ]]; then
				CURRENT_LANG="$new_lang"
				save_helper_config
				load_ui_strings "$CURRENT_LANG"
				newline 2
				fmt_success "$(printf "$(get_msg "language_set")" "$CURRENT_LANG")"
				newline
				fmt_prompt "$(get_msg "press_enter_continue")"
				read -r
				return 0
			else
				newline 2
				fmt_info "$(get_msg "config_kept_suffix")"
				newline
				fmt_prompt "$(get_msg "press_enter_continue")"
				read -r
				return 0
			fi
			;;
		0)
			return 0
			;;
		"")
			newline
			fmt_info "$(get_msg "config_kept_suffix")"
			newline
			fmt_prompt "$(get_msg "press_enter_continue")"
			read -r
			return 0
			;;
		*)
			newline 2
			fmt_error "$(get_msg "invalid_option")"
			sleep 1.5
			;;
		esac
	done
}

# Edita o número máximo de backups
edit_max_backups() {
	while true; do
		clear
		fmt_header "$(get_msg "config_menu_max_backups")"

		fmt_prompt "$(get_msg enter_max_backups_or_0) [${MAX_BACKUPS}]:"
		read -r new_max_backups

		if [[ "$new_max_backups" == "0" ]]; then
			return 0
		fi

		if [[ -z "$new_max_backups" ]]; then
			newline
			fmt_info "$(get_msg "config_kept_suffix")"
			break
		elif [[ "$new_max_backups" =~ ^[1-9][0-9]*$ ]]; then
			MAX_BACKUPS="$new_max_backups"
			save_helper_config
			newline
			fmt_success "$(get_msg "max_backups_updated"): $new_max_backups"
			break
		else
			newline
			fmt_error "$(get_msg "invalid_number")"
		fi

		newline
		fmt_prompt "$(get_msg "press_enter_continue")"
		read -r
	done

	newline
	fmt_prompt "$(get_msg "press_enter_continue")"
	read -r
}
