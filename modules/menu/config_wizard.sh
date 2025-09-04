#!/bin/bash
# modules/menu/edit_config_interactively.sh
# Menu de configurações interativas

config_wizard() {
	# Declarar array associativo para configurações editáveis (global)
	declare -gA EDITABLE_CONFIG

	local config_file="$SPOTDL_CONFIG_PATH"

	# Função para carregar valor específico do JSON de config
	load_config_value() {
		local key=$1
		jq -r --arg key "$key" '.[$key] // empty' "$config_file"
	}

	# Lista das chaves que serão exibidas e editadas
	local keys=(format bitrate overwrite threads generate_lrc skip_album_art sync_without_deleting sync_remove_lrc no_cache)

	# Popular o array EDITABLE_CONFIG com valores do arquivo JSON
	for key in "${keys[@]}"; do
		local val
		val=$(load_config_value "$key")
		if [[ -z "$val" ]]; then
			case "$key" in
			generate_lrc | skip_album_art | sync_without_deleting | sync_remove_lrc | no_cache)
				val="false"
				;; # padrão booleano
			*)
				val="(não definido)"
				;;
			esac
		fi
		EDITABLE_CONFIG[$key]="$val"
	done

	# Função para converter booleanos para texto traduzido Sim/Não
	format_boolean_display() {
		local val="$1"
		if [[ "$val" == "true" ]]; then
			echo "$(get_msg boolean_yes_display)"
		elif [[ "$val" == "false" ]]; then
			echo "$(get_msg boolean_no_display)"
		else
			echo "$val"
		fi
	}

	# Função para converter valor de overwrite para texto traduzido
	format_overwrite_display() {
		local val="$1"
		case "$val" in
		skip) echo "$(get_msg overwrite_skip)" ;;
		force) echo "$(get_msg overwrite_force)" ;;
		metadata) echo "$(get_msg overwrite_metadata)" ;;
		*) echo "$val" ;;
		esac
	}

	while true; do
		clear
		fmt_header "$(get_msg config_menu_title)"
		fmt_info "$(get_msg config_current_settings)"

		fmt_config_item "1" "$(get_msg label_language)" "$CURRENT_LANG"
		fmt_config_item "2" "$(get_msg label_download_path)" "$FINAL_DIR"
		fmt_config_item "3" "$(get_msg config_output_template)" "$(get_template_display_name)"
		fmt_config_item "4" "$(get_msg format)" "${EDITABLE_CONFIG[format]}"
		fmt_config_item "5" "$(get_msg bitrate)" "${EDITABLE_CONFIG[bitrate]}"
		fmt_config_item "6" "$(get_msg overwrite)" "$(format_overwrite_display "${EDITABLE_CONFIG[overwrite]}")"
		fmt_config_item "7" "$(get_msg threads)" "${EDITABLE_CONFIG[threads]}"
		fmt_config_item "8" "$(get_msg generate_lrc)" "$(format_boolean_display "${EDITABLE_CONFIG[generate_lrc]}")"
		fmt_config_item "9" "$(get_msg skip_album_art)" "$(format_boolean_display "${EDITABLE_CONFIG[skip_album_art]}")"
		fmt_config_item "10" "$(get_msg sync_without_deleting)" "$(format_boolean_display "${EDITABLE_CONFIG[sync_without_deleting]}")"
		fmt_config_item "11" "$(get_msg sync_remove_lrc)" "$(format_boolean_display "${EDITABLE_CONFIG[sync_remove_lrc]}")"
		fmt_config_item "12" "$(get_msg no_cache)" "$(format_boolean_display "${EDITABLE_CONFIG[no_cache]}")"
		fmt_config_item "13" "$(get_msg label_max_backups)" "$MAX_BACKUPS"
		fmt_config_item "14" "$(get_msg label_lyrics_providers)" "$(format_lyrics_providers_display)"
		printf "\n"
		fmt_option "0" "$(get_msg menu_return)"

		fmt_prompt "\n$(get_msg choose_option_menu)"
		read -r choice

		case $choice in
		1) edit_language ;;
		2) edit_download_path ;;
		3) edit_output_template ;;
		4) edit_audio_format ;;
		5) edit_bitrate ;;
		6) edit_overwrite ;;
		7) edit_threads ;;
		8) edit_generate_lrc ;;
		9) edit_skip_album_art ;;
		10) edit_sync_without_deleting ;;
		11) edit_sync_remove_lrc ;;
		12) edit_no_cache ;;
		13) edit_max_backups ;;
		14) edit_lyrics_providers ;;
		0) return ;;
		*)
			newline
			fmt_error "$(get_msg invalid_option)"
			sleep 1.5
			;;
		esac
	done
}
