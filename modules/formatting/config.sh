#!/bin/bash
# modules/formatting/config.sh
# Exibição de configuração e menus

# Item de configuração detalhado
# Parâmetros:
#   $1 - Label
#   $2 - Valor
# Exemplo:
#   fmt_config_detail "Usuário" "admin"
#   # Saída: [i em azul] [Usuário: em amarelo negrito] [admin em verde negrito]
fmt_config_detail() {
	local icon
	icon="$(format_text " i " bright_white bg_blue bold)"
	local label
	label="$(format_text "$1:" bright_yellow)"
	local value
	value="$(format_text " $2" bright_green)"
	printf "%b %b%b\n" "$icon" "$label" "$value"
}

# Item de configuração formatado
# Parâmetros:
#   $1 - Número
#   $2 - Label
#   $3 - Valor
# Exemplo:
#   fmt_config_item "1" "Tema" "Escuro"
#   # Saída: [1 em amarelo negrito]) [Tema:] [Escuro em verde negrito]
fmt_config_item() {
	printf " %b) %s: %b\n" \
		"$(format_text "$1" bright_yellow bold)" \
		"$(format_text "$2" bright_white)" \
		"$(format_text "$3" bright_green bold)"
}

# Opção numerada para menus
# Parâmetros:
#   $1 - Número
#   $2 - Descrição
# Exemplo:
#   fmt_option "1" "Instalar pacote"
#   # Saída: [1 em amarelo]) [Instalar pacote]
fmt_option() {
	printf "%b) %b\n" \
		"$(format_text "$1" bright_yellow bold)" \
		"$(format_text "$2" bright_white)"
}

# Prompt para input
# Parâmetros:
#   $1 - Texto do prompt
# Exemplo:
#   fmt_prompt "Digite sua escolha: "
#   # Saída: [Digite sua escolha: em verde negrito] (sem quebra de linha)
fmt_prompt() {
	printf "%b" "$(format_text "$1" bright_green bold)"
}

# Menu enumerado simples
# Parâmetros:
#   $@ - Itens do menu
# Exemplo:
#   fmt_menu "Iniciar" "Configurar" "Sair"
#   # Saída:
#   # [[1] em ciano] [Iniciar em branco]
#   # [[2] em ciano] [Configurar em branco]
#   # [[3] em ciano] [Sair em branco]
fmt_menu() {
	local i=1
	for item in "$@"; do
		printf "%b %b\n" \
			"$(format_text "[$i]" bright_cyan)" \
			"$(format_text "$item" bright_white)"
		((i++))
	done
}

# Lista de pares chave-valor
# Parâmetros:
#   Pares de argumentos: ch1 valor1 ch2 valor2...
# Exemplo:
#   fmt_config_list "Usuário" "admin" "Tema" "escuro"
#   # Saída:
#   # [Usuário: em amarelo] [admin em branco]
#   # [Tema: em amarelo] [escuro em branco]
fmt_config_list() {
	while [[ $# -gt 0 ]]; do
		local key="$1" value="$2"
		printf "%b: %b\n" \
			"$(format_text "$key" bright_yellow)" \
			"$(format_text "$value" bright_white)"
		shift 2 || break
	done
}

# Linha de configuração com label destacado
# Parâmetros:
#   $1 - Label
#   $2 - Valor
# Exemplo:
#   fmt_config_path "Arquivo de config:" "/etc/app.conf"
#   # Saída: [Arquivo de config: em amarelo negrito] [/etc/app.conf]
fmt_config_path() {
	printf "\n%s %s" "$(format_text "$1" bright_yellow bold)" "$2"
}
