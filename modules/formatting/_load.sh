#!/bin/bash
# modules/formatting/_load.sh
# Carregador dos módulos de formatação com suporte a debug

FORMATTING_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE FORMATAÇÃO"

# Lista de módulos em ordem de carregamento
FORMATTING_MODULES=(
	"core"
	"colors"
	"styles"
	"config"
	"messages"
	"messages_emoji"
	"visuals"
	"commands"
)

# Carregamento dos módulos
for module in "${FORMATTING_MODULES[@]}"; do
	module_path="$FORMATTING_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
