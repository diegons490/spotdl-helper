#!/bin/bash
# modules/config_env.sh
# Define variáveis globais e carrega módulos de configuração.

# ==================================================
# CONFIGURAÇÕES EDITÁVEIS DO SPOTDL
# ==================================================
declare -gA EDITABLE_CONFIG=(
	[format]="mp3"
	[bitrate]="128k"
	[generate_lrc]="true"
	[skip_album_art]="false"
	[threads]="3"
	[sync_without_deleting]="false"
	[sync_remove_lrc]="false"
	[overwrite]="skip"
	[no_cache]="false"
)

# ==================================================
# DEFINIR PROVEDORES PADRÃO
# ==================================================
declare -ga CURRENT_LYRIC_PROVIDERS=("genius" "musixmatch")

# ==================================================
# CONFIGURAÇÕES DO HELPER
# ==================================================
declare -g CURRENT_LANG="en_US"
declare -g MAX_BACKUPS=5
declare -g FINAL_DIR=""
declare -g OUTPUT_STRUCTURE=""

# ==================================================
# CAMINHOS FIXOS DE CONFIGURAÇÃO
# (dependem de variáveis definidas no main.sh)
# ==================================================
declare -g SPOTDL_CONFIG_PATH="${SPOTDL_CONFIG_DIR}/config.json"
declare -g HELPER_CONFIG_PATH="${HELPER_CONFIG_DIR}/helper-config.json"

# ==================================================
# VARIÁVEIS POPULADAS EM TEMPO DE EXECUÇÃO
# ==================================================
declare -g OVERWRITE_MODE=""
declare -g THREADS=""
declare -g GENERATE_LRC=""
declare -g SYNC_WITHOUT_DELETING=""
declare -g NO_CACHE=""
