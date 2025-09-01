#!/bin/bash
# modules/config_edit_options.sh
# Funções para interface de edição de configurações individuais do spotDL.

# Dependências:
# - config_env.sh (para EDITABLE_CONFIG, FINAL_DIR, OUTPUT_STRUCTURE)
# - config_spotdl.sh (para update_spotdl_config, save_single_config)
# - Funções de formatação e i18n: fmt_*, get_msg (externas)

# Edita o caminho de download
edit_download_path() {
	while true; do
		clear
		fmt_header "$(get_msg "label_download_path")"

		fmt_section "$(get_msg "enter_new_path_or_0")"
		fmt_config_path "$(get_msg "base_download_path")" "[${FINAL_DIR}]:"
		read -r input

		if [[ "$input" == "0" ]]; then
			return 0
		fi

		if [[ -n "$input" ]]; then
			local new_dir="${input%/}"

			if [[ -d "$new_dir" && -w "$new_dir" ]]; then
				FINAL_DIR="$new_dir"
				update_spotdl_config "output" "${FINAL_DIR}/${OUTPUT_STRUCTURE}"
				newline
				fmt_success "$(printf "$(get_msg "download_path_updated")" "$new_dir")"
				newline
				fmt_prompt "$(get_msg "press_enter_continue")"
				read -r
				break
			else
				newline
				fmt_error "$(printf "$(get_msg "download_path_error")" "$new_dir")"
				newline
				fmt_info "$(printf "$(get_msg "config_kept_path")" "$FINAL_DIR")"
				newline
				fmt_prompt "$(get_msg "press_enter_continue")"
				read -r
			fi
		else
			newline
			fmt_info "$(printf "$(get_msg "config_kept_path")" "$FINAL_DIR")"
			newline
			fmt_prompt "$(get_msg "press_enter_continue")"
			read -r
			break
		fi
	done
}

# Edita o template de saída
edit_output_template() {
	while true; do
		clear
		fmt_header "$(get_msg "config_output_template_title")"

		for i in 1 2 3; do
			local marker="[ ]"
			[[ "$OUTPUT_STRUCTURE" == "{artist}/{album}/{title}.{output-ext}" && $i -eq 1 ]] && marker="[x]"
			[[ "$OUTPUT_STRUCTURE" == "{artist}/{title}.{output-ext}" && $i -eq 2 ]] && marker="[x]"
			[[ "$OUTPUT_STRUCTURE" == "{title}.{output-ext}" && $i -eq 3 ]] && marker="[x]"

			local msg_key="config_output_template_$i"
			fmt_option "$i" "$marker $(get_msg "$msg_key")"
		done

		newline
		fmt_option "0" "$(get_msg "menu_return")"
		newline
		fmt_prompt "$(get_msg "choose_option") (0-3):"
		read -n 1 -r input

		if [[ "$input" == "0" ]]; then
			return 0
		fi

		if [[ -z "$input" ]]; then
			newline
			fmt_info "$(get_msg "config_kept_suffix")"
			newline
			fmt_prompt "$(get_msg "press_enter_continue")"
			read -r
			break
		else
			case $input in
			1) new_structure="{artist}/{album}/{title}.{output-ext}" ;;
			2) new_structure="{artist}/{title}.{output-ext}" ;;
			3) new_structure="{title}.{output-ext}" ;;
			*)
				newline 2
				fmt_error "$(get_msg "invalid_option")"
				newline
				fmt_prompt "$(get_msg "press_enter_continue")"
				read -r
				continue
				;;
			esac

			OUTPUT_STRUCTURE="$new_structure"
			update_spotdl_config "output" "${FINAL_DIR}/${OUTPUT_STRUCTURE}"
			newline 2
			fmt_success "$(get_msg "config_output_template_saved"): $(get_template_display_name)"
			newline
			fmt_prompt "$(get_msg "press_enter_continue")"
			read -r
			break
		fi
	done
}

# Edita o formato de áudio
edit_audio_format() {
	local valid_formats=("mp3" "flac" "opus" "wav" "m4a")

	while true; do
		clear
		fmt_header "$(get_msg format)"
		local current="${EDITABLE_CONFIG[format]}"

		for i in "${!valid_formats[@]}"; do
			local marker="[ ]"
			[[ "${valid_formats[$i]}" == "$current" ]] && marker="[x]"
			fmt_option "$((i + 1))" "$marker ${valid_formats[$i]}"
		done

		newline
		fmt_option "0" "$(get_msg menu_return)"
		newline
		fmt_prompt "$(get_msg choose_option) (0-${#valid_formats[@]}): "
		read -n 1 -r input
		echo

		if [[ "$input" == "0" ]]; then
			return 0
		fi

		if [[ -z "$input" ]]; then
			fmt_info "$(get_msg config_kept_suffix)"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
			break
		elif [[ "$input" =~ ^[1-9]$ ]] && ((input >= 1 && input <= ${#valid_formats[@]})); then
			EDITABLE_CONFIG[format]="${valid_formats[$((input - 1))]}"
			save_single_config "format"
			newline
			fmt_success "$(get_msg format_updated): ${EDITABLE_CONFIG[format]}"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
			break
		else
			newline
			fmt_error "$(get_msg invalid_option)"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
		fi
	done
}

# Edita o bitrate
edit_bitrate() {
	local valid_bitrates=("128k" "256k" "320k" "512k")

	while true; do
		clear
		fmt_header "$(get_msg bitrate)"
		fmt_warning "$(get_msg bitrate_warning)"
		local current="${EDITABLE_CONFIG[bitrate]}"
		newline

		for i in "${!valid_bitrates[@]}"; do
			local marker="[ ]"
			[[ "${valid_bitrates[$i]}" == "$current" ]] && marker="[x]"
			fmt_option "$((i + 1))" "$marker ${valid_bitrates[$i]}"
		done

		newline
		fmt_option "0" "$(get_msg menu_return)"
		newline
		fmt_prompt "$(get_msg choose_option) (0-${#valid_bitrates[@]}):"
		read -n 1 -r input
		echo

		if [[ "$input" == "0" ]]; then
			return 0
		fi

		if [[ -z "$input" ]]; then
			fmt_info "$(get_msg config_kept_suffix)"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
			break
		elif [[ "$input" =~ ^[1-9]$ ]] && ((input >= 1 && input <= ${#valid_bitrates[@]})); then
			EDITABLE_CONFIG[bitrate]="${valid_bitrates[$((input - 1))]}"
			save_single_config "bitrate"
			newline
			fmt_success "$(get_msg bitrate_updated): ${EDITABLE_CONFIG[bitrate]}"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
			break
		else
			newline
			fmt_error "$(get_msg invalid_option)"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
		fi
	done
}

# Edita o modo de sobrescrita
edit_overwrite() {
	local valid_overwrite=("skip" "force" "metadata")

	while true; do
		clear
		fmt_header "$(get_msg overwrite)"
		local current="${EDITABLE_CONFIG[overwrite]}"

		for i in "${!valid_overwrite[@]}"; do
			local marker="[ ]"
			[[ "${valid_overwrite[$i]}" == "$current" ]] && marker="[x]"
			fmt_option "$((i + 1))" "$marker ${valid_overwrite[$i]}"
		done

		newline
		fmt_option "0" "$(get_msg menu_return)"
		newline
		fmt_prompt "$(get_msg choose_option) (0-${#valid_overwrite[@]}):"
		read -n 1 -r input
		echo

		if [[ "$input" == "0" ]]; then
			return 0
		fi

		if [[ -z "$input" ]]; then
			fmt_info "$(get_msg config_kept_suffix)"
			break
		elif [[ "$input" =~ ^[1-9]$ ]] && ((input >= 1 && input <= ${#valid_overwrite[@]})); then
			EDITABLE_CONFIG[overwrite]="${valid_overwrite[$((input - 1))]}"
			save_single_config "overwrite"
			newline
			fmt_success "$(get_msg overwrite_updated): ${EDITABLE_CONFIG[overwrite]}"
			break
		else
			newline
			fmt_error "$(get_msg invalid_option)"
		fi

		newline
		fmt_prompt "$(get_msg press_enter_continue)"
		read -r
	done

	newline
	fmt_prompt "$(get_msg press_enter_continue)"
	read -r
}

# Edita o número de threads
edit_threads() {
	while true; do
		clear
		fmt_header "$(get_msg label_threads)"
		newline
		fmt_warning "$(get_msg threads_warning)"
		newline

		fmt_prompt "$(get_msg enter_threads_or_0) [${EDITABLE_CONFIG[threads]}]:"
		read -r new_threads

		if [[ "$new_threads" == "0" ]]; then
			return 0
		fi

		if [[ -z "$new_threads" ]]; then
			newline
			fmt_info "$(get_msg config_kept_suffix)"
			break
		elif [[ "$new_threads" =~ ^[1-9][0-9]*$ ]]; then
			if ((new_threads > 5)); then
				newline
				fmt_warning "$(get_msg threads_high_warning)"
				sleep 2
			fi
			EDITABLE_CONFIG[threads]="$new_threads"
			save_single_config "threads"
			newline
			fmt_success "$(get_msg threads_updated): $new_threads"
			break
		else
			newline
			fmt_error "$(get_msg invalid_number_threads)"
		fi

		newline
		fmt_prompt "$(get_msg press_enter_continue)"
		read -r
	done

	newline
	fmt_prompt "$(get_msg press_enter_continue)"
	read -r
}

# Funções booleanas genéricas para opções true/false
# Funções booleanas genéricas para opções true/false (com suporte a Enter para manter)
handle_boolean_option() {
	local config_key="$1"
	local title="$2"
	local yes_char="$(get_msg boolean_yes_display)"
	local no_char="$(get_msg boolean_no_display)"

	while true; do
		clear
		fmt_header "$title"
		local current="${EDITABLE_CONFIG[$config_key]}"

		[[ "$current" == "true" ]] && fmt_option "1" "[x] $yes_char" || fmt_option "1" "[ ] $yes_char"
		[[ "$current" == "false" ]] && fmt_option "2" "[x] $no_char" || fmt_option "2" "[ ] $no_char"

		newline
		fmt_option "0" "$(get_msg menu_return)"
		newline
		fmt_prompt "$(get_msg choose_option) (0-2) [${EDITABLE_CONFIG[$config_key]}]:"
		read -r input

		# Tratamento para Enter pressionado (input vazio)
		if [[ -z "$input" ]]; then
			newline
			fmt_info "$(get_msg config_kept_suffix)"
			break
		elif [[ "$input" == "0" ]]; then
			return 0
		elif [[ "$input" == "1" ]]; then
			EDITABLE_CONFIG[$config_key]="true"
			save_single_config "$config_key"
			newline
			fmt_success "$(get_msg option_set_to_yes)"
			break
		elif [[ "$input" == "2" ]]; then
			EDITABLE_CONFIG[$config_key]="false"
			save_single_config "$config_key"
			newline
			fmt_success "$(get_msg option_set_to_no)"
			break
		else
			newline
			fmt_error "$(get_msg invalid_option)"
			sleep 1.5
		fi
	done

	newline
	fmt_prompt "$(get_msg press_enter_continue)"
	read -r
}

# Funções de edição para opções booleanas
edit_generate_lrc() {
	handle_boolean_option "generate_lrc" "$(get_msg generate_lrc)"
}

edit_skip_album_art() {
	handle_boolean_option "skip_album_art" "$(get_msg skip_album_art)"
}

edit_sync_without_deleting() {
	handle_boolean_option "sync_without_deleting" "$(get_msg sync_without_deleting)"
}

edit_sync_remove_lrc() {
	handle_boolean_option "sync_remove_lrc" "$(get_msg sync_remove_lrc)"
}

edit_no_cache() {
	handle_boolean_option "no_cache" "$(get_msg no_cache)"
}

# Função para editar provedores de letras
edit_lyrics_providers() {
	local options=("genius" "azlyrics" "musixmatch")
	local descriptions=(
		"$(get_msg lyrics_provider_genius)"
		"$(get_msg lyrics_provider_azlyrics)"
		"$(get_msg lyrics_provider_musixmatch)"
	)

	while true; do
		clear
		fmt_header "$(get_msg label_lyrics_providers)"

		for i in "${!options[@]}"; do
			local provider="${options[$i]}"
			local desc="${descriptions[$i]}"
			local marker="[ ]"
			if [[ " ${CURRENT_LYRIC_PROVIDERS[@]} " =~ " $provider " ]]; then
				marker="[x]"
			fi
			fmt_option "$((i + 1))" "$marker $desc"
		done

		newline
		fmt_option "0" "$(get_msg menu_return)"
		newline
		fmt_prompt "$(get_msg choose_option) (0-${#options[@]}): "
		read -r choice

		# Se pressionar Enter sem digitar nada, mantém a configuração atual
		if [[ -z "$choice" ]]; then
			newline
			fmt_info "$(get_msg config_kept_suffix)"
			newline
			fmt_prompt "$(get_msg press_enter_continue)"
			read -r
			return 0
		fi

		case $choice in
		0)
			return 0
			;;
		1 | 2 | 3)
			local index=$((choice - 1))
			local provider="${options[$index]}"
			if [[ " ${CURRENT_LYRIC_PROVIDERS[@]} " =~ " $provider " ]]; then
				# Remover o provider
				CURRENT_LYRIC_PROVIDERS=(${CURRENT_LYRIC_PROVIDERS[@]//$provider/})
				# Remove empty elements
				for i in "${!CURRENT_LYRIC_PROVIDERS[@]}"; do
					if [ -z "${CURRENT_LYRIC_PROVIDERS[i]}" ]; then
						unset 'CURRENT_LYRIC_PROVIDERS[i]'
					fi
				done
			else
				# Adicionar o provider
				CURRENT_LYRIC_PROVIDERS+=("$provider")
			fi
			save_spotdl_config
			;;
		*)
			newline
			fmt_error "$(get_msg invalid_option)"
			sleep 1.5
			;;
		esac
	done
}
