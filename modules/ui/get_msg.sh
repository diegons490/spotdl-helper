#!/bin/bash
# modules/ui/load_ui_strings.sh
# Função para carregamento das mensagens

get_msg() {
	local key="$1"

	# Verificar se as mensagens foram carregadas
	if [[ ${#PROMPT_MSGS[@]} -eq 0 ]]; then
		load_ui_strings "${CURRENT_LANG:-pt_BR}"
	fi

	if [[ -v PROMPT_MSGS[$key] ]]; then
		# Interpreta sequências de escape como \n para quebra de linha
		printf "%b" "${PROMPT_MSGS[$key]}"
	else
		# Fallback para chaves essenciais
		case "$key" in
		invalid_option) echo "Opção inválida" ;;
		or_char) echo "ou" ;;
		yes_char) echo "s" ;;
		no_char) echo "n" ;;
		*)
			fmt_error "ERROR: Chave de mensagem não encontrada: '$key'" >&2
			echo "$key"
			;;
		esac
	fi
}
