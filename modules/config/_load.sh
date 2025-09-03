#!/bin/bash
# modules/config/_load.sh
# Loader dos módulos de configuração com suporte a debug

CONFIG_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE CONFIGURAÇÃO"

# Lista de módulos em ordem de carregamento
CONFIG_MODULES_ORDER=(
	"config_env.sh"
	"config_edit_options.sh"
	"config_helper.sh"
	"config_spotdl.sh"
	"config_utils.sh"
)

for module in "${CONFIG_MODULES_ORDER[@]}"; do
	module_path="$CONFIG_MODULES_DIR/$module"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
