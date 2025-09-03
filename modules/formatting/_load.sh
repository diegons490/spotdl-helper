#!/bin/bash
# modules/formatting/_load.sh
# Carregador dos módulos de formatação com suporte a debug

FORMATTING_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Lista de módulos em ordem de carregamento
FORMATTING_MODULES=(
	"core.sh"
	"colors.sh"
	"styles.sh"
	"config.sh"
	"messages.sh"
	"messages_emoji.sh"
	"visuals.sh"
	"commands.sh"
)

# Carregamento dos submódulos
for module in "${FORMATTING_MODULES[@]}"; do
	module_path="$FORMATTING_MODULES_DIR/$module"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
