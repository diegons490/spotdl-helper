#!/bin/bash
# modules/formatting/visuals.sh
# Funções de Separadores, linhas e etc

# Cabeçalho centralizado entre linhas decorativas
# Parâmetros:
#   $1 - Texto do título
# Exemplo:
#   fmt_header "INSTALAÇÃO"
#   # Saída:
#   # ===========================================
#   #               INSTALAÇÃO
#   # ===========================================
fmt_header() {
	local title="$1"
	local line="==========================================="
	printf "\n%b\n%b\n%b\n\n" \
		"$(format_text "$line" bright_cyan bold)" \
		"$(format_text "   $title   " bright_cyan bold)" \
		"$(format_text "$line" bright_cyan bold)"
}

# Cabeçalho de seção simples
# Parâmetros:
#   $1 - Texto da seção
# Exemplo:
#   fmt_section "Configuração de Rede"
#   # Saída: [Configuração de Rede em ciano negrito]
fmt_section() {
	printf "%b\n" "$(format_text "$1" bright_cyan bold)"
}

# Linha separadora simples
# Parâmetros:
#   $1 - Caractere (padrão: '-')
#   $2 - Comprimento (padrão: 40)
# Exemplo:
#   fmt_separator "=" 20
#   # Saída: ====================
fmt_separator() {
	local char="${1:--}"
	local length="${2:-40}"
	# Usar printf para criar a linha com o caractere repetido
	local line
	line=$(printf "%-${length}s" "")
	line="${line// /$char}"
	printf "%s\n" "$line"
}

# Texto centralizado com separadores
# Parâmetros:
#   $1 - Texto
#   $2 - Caractere (padrão: '=')
#   $3 - Comprimento (padrão: 40)
# Exemplo:
#   fmt_separator_centered "MENU" "=" 40
#   # Saída: =============== MENU ================
fmt_separator_centered() {
	local text="$1"
	local char="${2:-=}"
	local length="${3:-40}"
	local text_len=${#text}

	# Garante que o comprimento seja pelo menos o tamanho do texto + 2
	if ((length < text_len + 2)); then
		length=$((text_len + 2))
	fi

	local pad=$(((length - text_len - 2) / 2))
	local extra=$(((length - text_len - 2) % 2))

	local left=$(printf "%*s" "$pad" "")
	local right=$(printf "%*s" $((pad + extra)) "")

	printf "%s%s %s%s\n" "${left// /$char}" "$text" "${right// /$char}"
}

# Separador colorido
# Parâmetros:
#   $1 - Caractere (padrão: '-')
#   $2 - Comprimento (padrão: 40)
#   $3 - Cor (padrão: bright_cyan)
# Exemplo:
#   fmt_separator_color "-" 30 bright_yellow
#   # Saída: [------------------------------ em amarelo]
fmt_separator_color() {
	local char="${1:--}"
	local length="${2:-40}"
	local color="${3:-bright_cyan}"
	local line
	printf -v line "%*s" "$length" ""
	printf "%s\n" "$(format_text "${line// /$char}" "$color")"
}

# Separador duplo para ênfase
# Parâmetros:
#   $1 - Caractere (padrão: '=')
#   $2 - Comprimento (padrão: 40)
# Exemplo:
#   fmt_double_separator "=" 20
#   # Saída:
#   # ====================
#   # ====================
fmt_double_separator() {
	local char="${1:-=}"
	local length="${2:-40}"
	# Criar linha com o caractere repetido usando substituição
	local line
	line=$(printf "%-${length}s" "")
	line="${line// /$char}"
	# Imprimir duas linhas idênticas
	printf "%s\n%s\n" "$line" "$line"
}

# Barra de progresso simples
# Parâmetros:
#   $1 - Porcentagem (0-100)
# Exemplo:
#   fmt_progress_bar 72
#   # Saída: [████████████████████████████████████████████████] 72% (com cores)
fmt_progress_bar() {
	local percent="$1"
	local filled=$((percent / 2))
	local empty=$((50 - filled))
	printf "%b" "$(format_text "[" bright_white)"
	printf "%b" "$(format_text "$(printf '%0.s█' $(seq 1 $filled))" bright_green)"
	printf "%b" "$(format_text "$(printf '%0.s ' $(seq 1 $empty))" bright_black)"
	printf "%b" "$(format_text "]" bright_white)"
	printf " %b\r" "$(format_text "$percent%" bright_yellow)"
}

# Destacar palavras no texto
# Parâmetros:
#   $1 - Texto completo
#   $2 - Palavra a destacar
#   $3 - Cor do texto (padrão: black)
#   $4 - Cor do fundo (padrão: yellow)
# Exemplo:
#   fmt_highlight "Este é um texto de exemplo" "exemplo" black yellow
#   # Saída: [Este é um texto de] [exemplo em preto com fundo amarelo]
fmt_highlight() {
	local text="$1"
	local word="$2"
	local text_color="${3:-black}"
	local bg_color="${4:-yellow}"

	# Usa substituição de string para adicionar formatação
	local highlighted="${text//$word/$(format_text "$word" "$text_color" "$bg_color" bold)}"
	printf "%b\n" "$highlighted"
}

# Texto com marcação de citação
# Parâmetros:
#   $1 - Texto
#   $2 - Cor da borda (padrão: bright_yellow)
# Exemplo:
#   fmt_quote "Texto de exemplo" bright_yellow
#   # Saída: [▐ Texto de exemplo] (com borda amarela)
fmt_quote() {
	local text="$1"
	local color="${2:-bright_yellow}"
	printf "%b\n" "$(format_text "▐ $text" "$color" "" bold)"
}

# Caixa de texto destacada
# Parâmetros:
#   $1 - Texto
#   $2 - Cor do texto (padrão: white)
#   $3 - Cor do fundo (padrão: blue)
#   $4 - Estilo (padrão: bold)
# Exemplo:
#   fmt_boxed "AVISO" bright_yellow blue bold
#   # Saída:
#   # ┌──────┐
#   # │ AVISO │
#   # └──────┘
#   # (com cores e estilos especificados)
fmt_boxed() {
	local text="$1"
	local text_color="${2:-white}"
	local bg_color="${3:-blue}"
	local style="${4:-bold}"
	local length=$((${#text} + 4))

	local top_line="┌$(printf '%0.s─' $(seq 1 $length))┐"
	local middle_line="│  $text  │"
	local bottom_line="└$(printf '%0.s─' $(seq 1 $length))┘"

	printf "%b\n" "$(format_text "$top_line" "$text_color" "$bg_color" "$style")"
	printf "%b\n" "$(format_text "$middle_line" "$text_color" "$bg_color" "$style")"
	printf "%b\n" "$(format_text "$bottom_line" "$text_color" "$bg_color" "$style")"
}

# =========================
# fmt_blink_warning
# =========================
# Imprime uma mensagem de alerta piscando em amarelo com ícone ⚠
# Parâmetro:
#   $1 - texto da mensagem
fmt_blink_warning() {
	local icon
	icon="$(format_text " ⚠ " bright_white bg_bright_yellow bold)"
	local msg
	msg="$(format_text " $1" bright_yellow blink bold)"
	printf "%b%b\n" "$icon" "$msg"
}
