#!/bin/bash
# modules/utils.sh
# Funções gerais e reutilizáveis não interativas

# Desativa 'set -e' temporariamente para executar comandos sem encerrar o script em erro
disable_set_e() {
	set +e
	"$@"
	local status=$?
	set -e
	return $status
}

# Função auxiliar para mostrar cabeçalhos de seção
print_section_header() {
	fmt_section "$1"
}

# Função para perguntas sim/não
prompt_yes_no() {
	local prompt_msg="$1"
	local choice
	local yes_opts no_opts

	yes_opts="$(get_msg yes_options)"
	no_opts="$(get_msg no_options)"

	while true; do
		fmt_prompt "$prompt_msg [$(get_msg yes_char)/$(get_msg no_char)]"
		read -r choice
		choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

		# Se a resposta estiver em alguma das listas configuradas
		for opt in $yes_opts; do
			[[ "$choice" == "$opt" ]] && return 0
		done
		for opt in $no_opts; do
			[[ "$choice" == "$opt" ]] && return 1
		done

		fmt_error "$(get_msg invalid_option)"
	done
}

# ================================
# prompt_yes_no_colored
# ================================
# Exibe uma pergunta com ícone "?" (branco/ciano), mensagem (ciano) e opções [s/n] (amarelo).
# Lê a resposta do usuário e retorna:
#   0 → opção "sim"
#   1 → opção "não"
# Se inválida, exibe erro e repete a pergunta.
# Uso:
#   if prompt_yes_no_colored "Deseja adicionar outro link?"; then
#       echo "Sim"
#   else
#       echo "Não"
#   fi
prompt_yes_no_ansi() {
	local prompt_msg="$1"
	local choice
	local yes_opts no_opts

	yes_opts="$(get_msg yes_options)"
	no_opts="$(get_msg no_options)"

	while true; do
		# Formatação separada para o texto da pergunta e opções [s/n]
		printf "%b %b " \
			"$(format_text " ? " bright_white bg_cyan bold)" \
			"$(format_text "$prompt_msg" bright_cyan bold)"

		# Destaca apenas o [s/n] em amarelo
		printf "%b" "$(format_text "[$(get_msg yes_char)/$(get_msg no_char)]" bright_yellow)"
		printf ": "

		read -r choice
		choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

		# Valida resposta
		for opt in $yes_opts; do
			[[ "$choice" == "$opt" ]] && return 0
		done
		for opt in $no_opts; do
			[[ "$choice" == "$opt" ]] && return 1
		done

		newline
		fmt_error "$(get_msg invalid_option)\n"
	done
}

# Prompt de pergunta sim/não com cores e emoji
# Uso: prompt_yes_no_colored "Mensagem da pergunta"
prompt_yes_no_emoji() {
	local prompt_msg="$1"
	local choice
	local yes_opts no_opts

	yes_opts="$(get_msg yes_options)" # ex: s S y Y
	no_opts="$(get_msg no_options)"   # ex: n N

	local icon="❓" # emoji de pergunta sem bold

	while true; do
		# Pergunta formatada com ícone
		printf "%b %b [%s/%s]: " \
			"$icon" \
			"$(format_text "$prompt_msg" bright_cyan bold)" \
			"$(get_msg yes_char)" \
			"$(get_msg no_char)"

		read -r choice
		choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

		# Valida resposta
		for opt in $yes_opts; do
			[[ "$choice" == "$opt" ]] && return 0
		done
		for opt in $no_opts; do
			[[ "$choice" == "$opt" ]] && return 1
		done

		# Imprime erro e repete pergunta
		fmt_error "$(get_msg invalid_option)"
	done
}

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
