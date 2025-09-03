#!/bin/bash
# modules/manage_spotdl/_load.sh
# Carregador de submódulos de gerenciamento do SpotDL com logs aprimorados

# Carregar arquivo de variáveis primeiro
VARS_PATH="$(dirname "${BASH_SOURCE[0]}")/manage_spotdl_vars.sh"
if [[ -f "$VARS_PATH" ]]; then
	source "$VARS_PATH"
	log_module_status "OK" "$VARS_PATH"
else
	log_module_status "FAIL" "$VARS_PATH"
	exit 1
fi

# Lista de submódulos a carregar
MANAGE_SPOTDL_MODULES=(
	"check_spotdl"
	"get_backup_limit"
	"manage_backups"
	"restore_backup"
	"update_spotdl"
)

# Carregamento dos submódulos
for submodule in "${MANAGE_SPOTDL_MODULES[@]}"; do
	submodule_path="$(dirname "${BASH_SOURCE[0]}")/${submodule}.sh"
	if [[ -f "$submodule_path" ]]; then
		source "$submodule_path"
		log_module_status "OK" "$submodule_path"
	else
		log_module_status "FAIL" "$submodule_path"
		exit 1
	fi
done
