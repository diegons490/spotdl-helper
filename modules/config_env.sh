#!/bin/bash
# modules/config_env.sh
# Define variáveis globais e carrega módulos de configuração.

# ==================================================
# CARREGAR MÓDULOS AUXILIARES DE CONFIGURAÇÃO
# ==================================================
CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/config"

source "$CONFIG_DIR/config_edit_options.sh"
source "$CONFIG_DIR/config_helper.sh"
source "$CONFIG_DIR/config_spotdl.sh"
source "$CONFIG_DIR/config_utils.sh"

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

declare -ga CURRENT_LYRIC_PROVIDERS=()

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

# ==================================================
# NOTA
# ==================================================
# $SPOTDL_CONFIG_DIR, $HELPER_CONFIG_DIR e $DOWNLOADS_DIR
# DEVEM ser definidos no script principal antes de carregar este módulo.
