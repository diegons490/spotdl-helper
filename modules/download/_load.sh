#!/bin/bash
# modules/download/_load.sh
# Carregador de submódulos de download com logs aprimorados

# Lista de submódulos a carregar
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

# Carregamento dos submódulos
for submodule in "${DOWNLOAD_MODULES[@]}"; do
	submodule_path="$(dirname "${BASH_SOURCE[0]}")/${submodule}.sh"
	if [[ -f "$submodule_path" ]]; then
		source "$submodule_path"
		log_module_status "OK" "$submodule_path"
	else
		log_module_status "FAIL" "$submodule_path"
		exit 1
	fi
done
