#!/bin/bash
# modules/download/run_spotdl.sh
# Executa spotdl com configurações

run_spotdl() {
	# Recarregar configurações antes de executar
	reload_download_config

	local command="$1"
	local link="$2"
	shift 2
	local extra_args=("$@")

	local base_args=(
		"--format" "${EDITABLE_CONFIG[format]}"
		"--bitrate" "${EDITABLE_CONFIG[bitrate]}"
		"--output" "$OUTPUT_TEMPLATE"
		"--overwrite" "$OVERWRITE_MODE"
		"--threads" "$THREADS"
	)

	[[ "$GENERATE_LRC" == "true" ]] && base_args+=(--generate-lrc)
	[[ "${EDITABLE_CONFIG[no_cache]}" == "true" ]] && base_args+=(--no-cache)

	# Adicionar provedores de letras se configurado
	if [ ${#CURRENT_LYRIC_PROVIDERS[@]} -gt 0 ]; then
		base_args+=(--lyrics)
		for provider in "${CURRENT_LYRIC_PROVIDERS[@]}"; do
			base_args+=("$provider")
		done
	fi

	# Monta a linha de comando para exibição
	local cmd_line="spotdl $command \"$link\""
	for arg in "${base_args[@]}" "${extra_args[@]}"; do
		cmd_line+=" \"$arg\""
	done

	fmt_cmd "$cmd_line"
	newline

	# Executa o comando com a ordem correta: comando, link, argumentos
	"$SPOTDL_CMD" "$command" "$link" "${base_args[@]}" "${extra_args[@]}"
}
