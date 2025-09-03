#!/bin/bash
# fmt_test.sh - Teste unificado para módulos de formatação

# Carregar módulos de formatação
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for module in core colors styles config messages messages_emoji visuals commands; do
	source "${DIR}/${module}.sh" 2>/dev/null || {
		echo "ERRO: Falha ao carregar ${module}.sh"
		exit 1
	}
done

# Função para demo
fmt_demo() {
	clear
	fmt_header "DEMONSTRAÇÃO DE FORMATAÇÕES"

	# 1. Cores de Texto
	fmt_section "1. Cores de Texto"
	for color in black red green yellow blue magenta cyan white \
		bright_black bright_red bright_green bright_yellow \
		bright_blue bright_magenta bright_cyan bright_white; do
		format_text " $color " "$color"
		printf " "
	done
	newline 2

	# 2. Cores de Fundo
	fmt_section "2. Cores de Fundo"
	for color in black red green yellow blue magenta cyan white \
		bright_black bright_red bright_green bright_yellow \
		bright_blue bright_magenta bright_cyan bright_white; do
		format_text " $color " "white" "bg_$color"
		printf " "
	done
	newline 2

	# 3. Estilos de Texto
	fmt_section "3. Estilos de Texto"
	for style in bold dim underline reverse blink; do
		format_text " $style " "$style"
		printf " "
	done
	newline 2

	# 4. Funções de Mensagem
	fmt_section "4. Funções de Mensagem"
	fmt_success "Esta é uma mensagem de sucesso"
	fmt_warning "Esta é uma mensagem de aviso"
	fmt_error "Esta é uma mensagem de erro"
	fmt_info "Esta é uma mensagem informativa"
	fmt_debug "Esta é uma mensagem de debug"
	fmt_question "Esta é uma mensagem de pergunta"
	newline

	# 5. Funções de Formatação
	fmt_section "5. Funções de Formatação"
	fmt_config_detail "Configuração" "Valor"
	fmt_config_item "1" "Opção" "Habilitado"
	fmt_option "A" "Opção com letra"
	fmt_prompt "Digite algo: "
	printf "(aguardando input)\n"
	newline

	# 6. Separadores
	fmt_section "6. Separadores"
	fmt_separator
	fmt_separator "=" 30
	fmt_separator_color "*" 25 bright_yellow
	fmt_separator_centered "TÍTULO" "-" 30
	fmt_double_separator
	newline

	# 7. Elementos Visuais
	fmt_section "7. Elementos Visuais"
	fmt_boxed "TEXTO EM DESTAQUE" bright_white blue bold
	fmt_quote "Esta é uma citação importante que deve ser destacada no texto" bright_cyan
	newline

	# 8. Barra de Progresso
	fmt_section "8. Barra de Progresso"
	for i in {0..100..10}; do
		fmt_progress_bar "$i"
		sleep 0.1
	done
	printf "\n"
	newline

	# 9. Destaque de Texto
	fmt_section "9. Destaque de Texto"
	fmt_highlight "Este texto contém palavras importantes para destacar" "importantes" black yellow
	newline

	# 10. Logs com Timestamp
	fmt_section "10. Logs com Timestamp"
	fmt_log "INFO" "Sistema inicializado com sucesso"
	fmt_log "WARN" "Recurso utilizando 80% da capacidade"
	fmt_log "ERROR" "Falha na conexão com o servidor"
	newline

	# 11. Menu de Exemplo
	fmt_section "11. Menu de Exemplo"
	fmt_menu "Iniciar processo" "Ver configurações" "Sair"
	newline

	# 12. Lista de Configurações
	fmt_section "12. Lista de Configurações"
	fmt_config_list "Usuário" "admin" "Servidor" "192.168.1.1" "Status" "Ativo"
	newline

	# 13. Comandos Formatados
	fmt_section "13. Comandos Formatados"
	fmt_cmd "spotdl download 'https://open.spotify.com/track/...' --format mp3 --bitrate 320k"
	newline

	# 14. Exemplos de Ícones Personalizados
	fmt_section "14. Exemplos de Ícones Personalizados"
	printf "  %b %b %b %b\n" \
		"$(format_text "🚀" bright_cyan)" \
		"$(format_text "💾" bright_blue)" \
		"$(format_text "📂" bright_yellow)" \
		"$(format_text "🔍" bright_magenta)"
	printf "  %b %b %b %b\n" \
		"$(format_text "🎵" bright_green)" \
		"$(format_text "🐧" bright_white)" \
		"$(format_text "⚡" bright_yellow)" \
		"$(format_text "💡" bright_cyan)"

	newline 2
	fmt_success "Demonstração concluída!"
}

# Função para testes interativos
fmt_interactive() {
	while true; do
		clear
		fmt_header "MODO INTERATIVO DE TESTE"

		fmt_menu "1. Testar cores de texto" \
			"2. Testar cores de fundo" \
			"3. Testar estilos" \
			"4. Testar funções de mensagem" \
			"5. Testar elementos visuais" \
			"6. Testar comandos formatados" \
			"7. Testar ícones personalizados" \
			"0. Voltar"

		fmt_prompt "Selecione uma opção: "
		read -r choice

		case $choice in
		1)
			clear
			fmt_section "CORES DE TEXTO"
			for color in black red green yellow blue magenta cyan white \
				bright_black bright_red bright_green bright_yellow \
				bright_blue bright_magenta bright_cyan bright_white; do
				printf "%-15s: " "$color"
				format_text " Texto de exemplo " "$color"
				printf "\n"
			done
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		2)
			clear
			fmt_section "CORES DE FUNDO"
			for color in black red green yellow blue magenta cyan white \
				bright_black bright_red bright_green bright_yellow \
				bright_blue bright_magenta bright_cyan bright_white; do
				printf "%-15s: " "$color"
				format_text "                     " "white" "bg_$color"
				printf "\n"
			done
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		3)
			clear
			fmt_section "ESTILOS DE TEXTO"
			for style in bold dim underline reverse blink; do
				printf "%-15s: " "$style"
				format_text " Texto de exemplo " "$style"
				printf "\n"
			done
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		4)
			clear
			fmt_section "FUNÇÕES DE MENSAGEM"
			fmt_success "Mensagem de sucesso"
			fmt_warning "Mensagem de aviso"
			fmt_error "Mensagem de erro"
			fmt_info "Mensagem informativa"
			fmt_debug "Mensagem de debug"
			fmt_question "Mensagem de pergunta"
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		5)
			clear
			fmt_section "ELEMENTOS VISUAIS"
			fmt_separator
			fmt_separator_color "*" 25 bright_magenta
			fmt_separator_centered "EXEMPLO" "=" 30
			fmt_boxed "TEXTO EM DESTAQUE" bright_white green bold
			fmt_quote "Esta é uma citação de exemplo" bright_cyan
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		6)
			clear
			fmt_section "COMANDOS FORMATADOS"
			fmt_cmd "ls -la"
			fmt_cmd "curl -X GET https://api.example.com/v1/users"
			fmt_cmd "docker run -it --rm ubuntu:20.04 bash -c 'printf Hello World'"
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		7)
			clear
			fmt_section "ÍCONES PERSONALIZADOS"
			format_text " Tecnologia" bright_blue "💻"
			printf "\n"
			format_text " Música" bright_green "🎵"
			printf "\n"
			format_text " Arquivos" bright_yellow "📂"
			printf "\n"
			format_text " Pesquisa" bright_magenta "🔍"
			printf "\n"
			format_text " Energia" bright_yellow "⚡"
			printf "\n"
			format_text " Ideia" bright_cyan "💡"
			printf "\n"
			format_text " Linux" bright_white "🐧"
			printf "\n"
			format_text " Foguete" bright_cyan "🚀"
			printf "\n"
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		0)
			break
			;;
		*)
			fmt_error "Opção inválida"
			sleep 1
			;;
		esac
	done
}

# Função para testes rápidos
fmt_quicktest() {
	for func in "$@"; do
		if declare -f "$func" >/dev/null; then
			fmt_section "Testando: $func"
			case "$func" in
			fmt_success | fmt_warning | fmt_error | fmt_info | fmt_debug | fmt_question)
				"$func" "Mensagem de teste"
				;;
			fmt_separator)
				"$func"
				;;
			fmt_separator_color)
				"$func" "-" 20 bright_green
				;;
			fmt_progress_bar)
				for i in {0..100..20}; do
					"$func" "$i"
					sleep 0.1
				done
				printf "\n"
				;;
			fmt_cmd)
				"$func" "printf 'test command'"
				;;
			*)
				"$func" "Teste" "Valor"
				;;
			esac
		else
			fmt_error "Função não encontrada: $func"
		fi
	done
}

# Função principal de teste
run_tests() {
	while true; do
		clear
		fmt_header "TESTES DE FORMATAÇÃO"
		fmt_menu "1. Demo Completa" \
			"2. Teste Interativo" \
			"3. Testes Rápidos" \
			"0. Sair"

		fmt_prompt "Selecione uma opção: "
		read -r choice

		case $choice in
		1) fmt_demo ;;
		2) fmt_interactive ;;
		3)
			clear
			fmt_header "TESTES RÁPIDOS"
			fmt_prompt "Digite as funções a testar (separadas por espaço): "
			read -r functions
			fmt_quicktest $functions
			;;
		0) exit 0 ;;
		*)
			fmt_error "Opção inválida"
			sleep 1
			;;
		esac

		if [ "$choice" -ne "0" ]; then
			fmt_prompt "\nPressione Enter para continuar..."
			read -r
		fi
	done
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	run_tests
fi
