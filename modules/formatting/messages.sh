#!/bin/bash
# modules/formatting/messages.sh
# Fortação de textos informativos

# Mensagem de sucesso com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_success "Operação concluída"
#   # Saída: [✔ em fundo verde] [Operação concluída em verde]
fmt_success() {
	local icon
	icon="$(format_text " ✔ " bright_white bg_green bold)"
	local msg
	msg="$(format_text " $1" bright_green)"
	printf "%b%b\n" "$icon" "$msg"
}

# Mensagem de pergunta com ícone
# Parâmetros:
#   $1 - Mensagem/pergunta
# Exemplo:
#   fmt_question "Deseja continuar?"
#   # Saída: [? em fundo azul] [Deseja continuar? em azul]
fmt_question() {
	local icon
	icon="$(format_text " ? " bright_white bg_cyan bold)"
	local msg
	msg="$(format_text " $1" bright_cyan)"
	printf "%b%b\n" "$icon" "$msg"
}

# Mensagem de aviso com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_warning "Permissões insuficientes"
#   # Saída: [⚠ em fundo amarelo] [Permissões insuficientes em amarelo]
fmt_warning() {
	local icon
	icon="$(format_text " ! " bright_white bg_yellow bold)"
	local msg
	msg="$(format_text " $1" yellow)"
	printf "%b%b\n" "$icon" "$msg"
}

# Mensagem de erro com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_error "Falha na instalação"
#   # Saída: [✖ em fundo vermelho] [Falha na instalação em vermelho]
fmt_error() {
	local icon
	icon="$(format_text " ✖ " bright_white bg_red bold)"
	local msg
	msg="$(format_text " $1" bright_red)"
	printf "%b%b\n" "$icon" "$msg"
}

# Mensagem informativa com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_info "Use --help para ajuda"
#   # Saída: [i em fundo azul] [Use --help para ajuda em azul]
fmt_info() {
	local icon
	icon="$(format_text " i " bright_white bg_blue bold)"
	local msg
	msg="$(format_text " $1" bright_blue)"
	printf "%b%b\n" "$icon" "$msg"
}

# Mensagem de debug com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_debug "Variável X=42"
#   # Saída: [d em fundo magenta] [Variável X=42 em magenta]
fmt_debug() {
	local icon
	icon="$(format_text " d " bright_white bg_magenta bold)"
	local msg
	msg="$(format_text " $1" bright_magenta)"
	printf "%b%b\n" "$icon" "$msg"
}

# Mensagem de log com timestamp
# Parâmetros:
#   $1 - Nível (INFO, WARN, ERROR, etc.)
#   $2 - Mensagem
# Exemplo:
#   fmt_log "INFO" "Script iniciado"
#   # Saída: [2023-09-15 10:00:00] [INFO] Script iniciado
fmt_log() {
	local level="$1"
	local message="$2"
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	case "${level^^}" in
	"INFO") local color="bright_blue" ;;
	"WARN") local color="bright_yellow" ;;
	"ERROR") local color="bright_red" ;;
	*) local color="white" ;;
	esac

	printf "%b [%b] %b\n" \
		"$(format_text "$timestamp" bright_black)" \
		"$(format_text "$level" "$color" "" bold)" \
		"$message"
}
