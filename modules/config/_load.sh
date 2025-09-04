#!/bin/bash
# modules/config/_load.sh
# Loader dos módulos de configuração com suporte a debug

CONFIG_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE CONFIGURAÇÃO"

# Lista de módulos em ordem de carregamento
CONFIG_MODULES_ORDER=(
	"config_env"
	"config_edit_options"
	"config_helper"
	"config_spotdl"
	"config_utils"
)

# Carregamento dos módulos
for module in "${CONFIG_MODULES_ORDER[@]}"; do
	module_path="$CONFIG_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
