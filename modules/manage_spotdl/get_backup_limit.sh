#!/bin/bash
# modules/manage_spotdl/get_backup_limit.sh
# Obtém o limite máximo de backups do arquivo de configuração

get_backup_limit() {
	# Usa variável global definida no main.sh, ou fallback
	local config_file="${HELPER_CONFIG_PATH:-$HOME/.spotdl-helper/helper-config.json}"
	local default_limit=5

	if [[ ! -f "$config_file" ]]; then
		fmt_error "$(printf "$(get_msg config_file_not_found)" "$config_file")\n"
		echo "$default_limit"
		return
	fi

	local config_value
	config_value=$(jq -r '.max_backups' "$config_file" 2>/dev/null)

	if [[ "$config_value" =~ ^[1-9][0-9]*$ ]]; then
		echo "$config_value"
	else
		fmt_error "$(printf "$(get_msg invalid_max_backups)" "$config_value")\n"
		echo "$default_limit"
	fi
}
