#!/bin/bash
# modules/download/_load.sh
# Carregador de módulos de download com logs aprimorados

DOWNLOAD_MODULES_DIR="$(dirname "${BASH_SOURCE[0]}")"

log_step "CARREGANDO MÓDULOS DE DOWNLOAD"

# Lista de módulos a carregar (sem .sh)
DOWNLOAD_MODULES=(
	"config_vars"
	"download_artist_albums"
	"download_music"
	"download_playlists"
	"reload_config"
	"run_spotdl"
	"sync_files"
	"validate_links"
)

# Carregamento dos módulos
for module in "${DOWNLOAD_MODULES[@]}"; do
	module_path="$DOWNLOAD_MODULES_DIR/${module}.sh"
	if [[ -f "$module_path" ]]; then
		source "$module_path"
		log_module_status "OK" "$module_path"
	else
		log_module_status "FAIL" "$module_path"
		exit 1
	fi
done
