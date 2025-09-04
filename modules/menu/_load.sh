#!/bin/bash
# modules/menu/_load.sh
# Carregador dos módulos de menu

MENU_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE MENU"

# Lista de módulos em ordem de carregamento
MENU_MODULES=(
	"config_main"
	"config_manual"
	"config_wizard"
	"spotdl_menu"
	"menu_main"
)

# Carregamento dos módulos
for module in "${MENU_MODULES[@]}"; do
	module_path="$MENU_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
