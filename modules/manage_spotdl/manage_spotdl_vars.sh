#!/bin/bash
# modules/manage_spotdl/manage_spotdl_vars.sh
# Variáveis específicas do módulo manage_spotdl

# Se BASE_DIR não veio do main.sh, calcula subindo dois níveis
if [[ -z "$BASE_DIR" ]]; then
	BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Diretórios específicos do manage_spotdl
BIN_DIR="$BASE_DIR/bin"
BACKUP_DIR="$BASE_DIR/bkp_spotdl"

# Nome e sufixo do binário
APP_NAME="spotdl"
FILE_SUFFIX="-linux"

# Exporta para que todos os scripts do manage_spotdl usem
export BIN_DIR BACKUP_DIR APP_NAME FILE_SUFFIX
