#!/bin/bash
# modules/environment/_load.sh
# Carregador dos módulos de ambiente / dependências

ENV_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE AMBIENTE"

# Lista de módulos em ordem de carregamento
ENV_MODULES=(
	"check_dependencies"
	"suggest_installation"
)

# Carregamento dos módulos
for module in "${ENV_MODULES[@]}"; do
	module_path="$ENV_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
