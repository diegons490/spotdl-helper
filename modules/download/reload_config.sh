#!/bin/bash
# modules/download/reload_config.sh
# Função para recarregar configurações

reload_download_config() {
	# Recarregar configurações do spotDL
	if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
		# Atualizar variáveis do spotDL
		OUTPUT_TEMPLATE=$(jq -r '.output' "$SPOTDL_CONFIG_PATH")
		OVERWRITE_MODE=$(jq -r '.overwrite // "skip"' "$SPOTDL_CONFIG_PATH")
		THREADS=$(jq -r '.threads // 3' "$SPOTDL_CONFIG_PATH")
		GENERATE_LRC=$(jq -r '.generate_lrc // "true"' "$SPOTDL_CONFIG_PATH")
		SYNC_WITHOUT_DELETING=$(jq -r '.sync_without_deleting // "true"' "$SPOTDL_CONFIG_PATH")

		# Atualizar configurações editáveis
		for key in "${!EDITABLE_CONFIG[@]}"; do
			local value
			value=$(jq -r --arg k "$key" '.[$k] // empty' "$SPOTDL_CONFIG_PATH" 2>/dev/null)
			if [[ -n "$value" && "$value" != "null" ]]; then
				EDITABLE_CONFIG["$key"]="$value"
			fi
		done

		# Recarregar estrutura de diretórios
		local full_template
		full_template=$(jq -r '.output // empty' "$SPOTDL_CONFIG_PATH")
		if [[ -n "$full_template" && "$full_template" != "null" ]]; then
			FINAL_DIR="${full_template%%\{*}"
			FINAL_DIR="${FINAL_DIR%/}"
			OUTPUT_STRUCTURE="${full_template#${FINAL_DIR}/}"
		fi
	fi

	# Recarregar configurações do helper
	if [[ -f "$HELPER_CONFIG_PATH" ]]; then
		MAX_BACKUPS=$(jq -r '.max_backups // 5' "$HELPER_CONFIG_PATH")
	fi

	# Recarregar provedores de letras
	CURRENT_LYRIC_PROVIDERS=()
	if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
		while IFS= read -r provider; do
			[[ -n "$provider" && "$provider" != "null" ]] && CURRENT_LYRIC_PROVIDERS+=("$provider")
		done < <(jq -r '.lyrics_providers[]?' "$SPOTDL_CONFIG_PATH" 2>/dev/null)
	fi
}
