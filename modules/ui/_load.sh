#!/bin/bash
# modules/ui/_load.sh
# Carregador dos módulos de interface / i18n / prompts

UI_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE INTERFACE (UI / I18N / PROMPTS)"

# Lista de módulos em ordem de carregamento (sem .sh)
UI_MODULES=(
	"get_msg"
	"load_ui_strings"
)

# Carregamento dos módulos
for module in "${UI_MODULES[@]}"; do
	module_path="$UI_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
