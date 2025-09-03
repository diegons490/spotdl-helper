#!/bin/bash
# modules/download/config_vars.sh
# Configura, carrega variáveis e configurações essenciais

OUTPUT_TEMPLATE=$(jq -r '.output' "$SPOTDL_CONFIG_PATH")
OVERWRITE_MODE=$(jq -r '.overwrite // "skip"' "$SPOTDL_CONFIG_PATH")
THREADS=$(jq -r '.threads // 3' "$SPOTDL_CONFIG_PATH")
GENERATE_LRC=$(jq -r '.generate_lrc // "true"' "$SPOTDL_CONFIG_PATH")
SYNC_WITHOUT_DELETING=$(jq -r '.sync_without_deleting // "true"' "$SPOTDL_CONFIG_PATH")
