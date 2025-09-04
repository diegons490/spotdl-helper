#!/bin/bash
# modules//utils/utils.sh
# Funções gerais e reutilizáveis não interativas

# Função auxiliar para perguntas sim/não
ask_to_edit() {
	local key="$1"
	local prompt_msg="$2"
	local current_value="${editable_config[$key]}"
	local current_char

	# Converter true/false para s/n
	[[ "$current_value" == "true" ]] && current_char="s" || current_char="n"

	while true; do
		fmt_prompt "$prompt_msg [$current_char]"
		read -n 1 -r input

		# Se pressionar Enter, mantém o valor atual
		if [[ -z "$input" ]]; then
			break
		fi

		input=$(echo "$input" | tr '[:upper:]' '[:lower:]')

		case "$input" in
		"s")
			editable_config[$key]="true"
			break
			;;
		"n")
			editable_config[$key]="false"
			break
			;;
		*)
			fmt_error "$(get_msg invalid_option)"
			;;
		esac
	done
}

# Função para pressionar Enter
prompt_enter_continue() {
	fmt_prompt "$(get_msg press_enter_continue)"
	read -n 1 -r -s
	printf "\n"
}

# Desativa 'set -e' temporariamente para executar comandos sem encerrar o script em erro
disable_set_e() {
	set +e
	"$@"
	local status=$?
	set -e
	return $status
}
