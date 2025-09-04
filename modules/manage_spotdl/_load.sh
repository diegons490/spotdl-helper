#!/bin/bash
# modules/manage_spotdl/_load.sh
# Carregador de módulos de gerenciamento do SpotDL com logs aprimorados

MANAGE_SPOTDL_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE GERENCIAMENTO DO SPOTDL"

# Carregar arquivo de variáveis primeiro
VARS_PATH="$MANAGE_SPOTDL_DIR/manage_spotdl_vars.sh"
if [[ -f "$VARS_PATH" ]]; then
	source "$VARS_PATH"
	log_module_status "OK" "$VARS_PATH"
else
	log_module_status "FAIL" "$VARS_PATH"
	exit 1
fi

# Lista de módulos a carregar
MANAGE_SPOTDL_MODULES=(
	"backup_manage"
	"backup_restore"
	"check_spotdl"
	"get_backup_limit"
	"spotdl_update"
)

# Carregamento dos módulos
for module in "${MANAGE_SPOTDL_MODULES[@]}"; do
	module_path="$MANAGE_SPOTDL_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
