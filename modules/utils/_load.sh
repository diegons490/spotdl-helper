#!/bin/bash
# modules/utils/_load.sh
# Carregador dos módulos utilitários gerais

UTILS_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS UTILITÁRIOS"

# Lista de módulos em ordem de carregamento
UTILS_MODULES=(
	"prompts"
	"utils"
)

# Carregamento dos módulos
for module in "${UTILS_MODULES[@]}"; do
	module_path="$UTILS_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
