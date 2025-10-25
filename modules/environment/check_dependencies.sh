#!/bin/bash
# modules/check_dependencies.sh
# Verificação de dependências

# Função principal para verificar dependências
check_dependencies() {
	local dependencies=("ffmpeg" "jq")
	local missing=()

	# Verificar cada dependência
	for dep in "${dependencies[@]}"; do
		if ! command -v "$dep" &>/dev/null; then
			missing+=("$dep")
		fi
	done

	# Se houver dependências faltantes
	if ((${#missing[@]} > 0)); then
		fmt_error "$(get_msg missing_dependencies_header)"
		fmt_warning "$(get_msg missing_dependencies)"

		# Mensagem específica para cada dependência faltante
		for dep in "${missing[@]}"; do
			case "$dep" in
			ffmpeg)
				fmt_error "  ➔ ffmpeg: $(get_msg error_ffmpeg_not_found)"
				;;
			jq)
				fmt_error "  ➔ jq: $(get_msg error_jq_not_found)"
				;;
			esac
		done

		fmt_warning "$(get_msg attempt_detect_pkg_manager)"
		suggest_installation "${missing[@]}"
		return 1
	fi

	return 0
}
