#!/bin/bash
# modules/formatting/styles.sh
# Estilos de texto

# Função para estilos de texto
get_style() {
	case "$1" in
	reset) tput sgr0 ;;
	bold) tput bold ;;
	dim) tput dim ;;
	underline) tput smul ;;
	reverse) tput rev ;;
	blink) tput blink ;;
	esac
}

# Texto em negrito (sem quebra de linha)
# Parâmetros:
#   $1 - Texto
# Exemplo:
#   fmt_bold "Importante:"
#   # Saída: [Importante: em negrito]
fmt_bold() {
	printf "%b" "$(format_text "$1" "" bold)"
}

# Texto colorido simples
# Parâmetros:
#   $1 - Texto
#   $2 - Cor do texto
color_only() { format_text "$1" "$2"; }

# Texto em negrito
# Parâmetros:
#   $1 - Texto
#   $2 - Cor do texto (opcional)
bold_text() { format_text "$1" "$2" bold; }

# Texto sublinhado
# Parâmetros:
#   $1 - Texto
#   $2 - Cor do texto (opcional)
underline_text() { format_text "$1" "$2" underline; }

# Texto em itálico
# Parâmetros:
#   $1 - Texto
#   $2 - Cor do texto (opcional)
italic_text() { format_text "$1" "$2" italic; }
