#!/bin/bash
# modules/formatting.sh - Utilitário de formatação de texto no terminal
# Refeito para usar `tput` em vez de códigos ANSI fixos

# -------------------------------
# Cores foreground (texto)
# -------------------------------
get_fg_color() {
	case "$1" in
	black) tput setaf 0 ;;
	red) tput setaf 1 ;;
	green) tput setaf 2 ;;
	yellow) tput setaf 3 ;;
	blue) tput setaf 4 ;;
	magenta) tput setaf 5 ;;
	cyan) tput setaf 6 ;;
	white) tput setaf 7 ;;
	bright_black) tput setaf 8 ;;
	bright_red) tput setaf 9 ;;
	bright_green) tput setaf 10 ;;
	bright_yellow) tput setaf 11 ;;
	bright_blue) tput setaf 12 ;;
	bright_magenta) tput setaf 13 ;;
	bright_cyan) tput setaf 14 ;;
	bright_white) tput setaf 15 ;;
	esac
}

# -------------------------------
# Cores background
# -------------------------------
get_bg_color() {
	case "$1" in
	black) tput setab 0 ;;
	red) tput setab 1 ;;
	green) tput setab 2 ;;
	yellow) tput setab 3 ;;
	blue) tput setab 4 ;;
	magenta) tput setab 5 ;;
	cyan) tput setab 6 ;;
	white) tput setab 7 ;;
	bright_black) tput setab 8 ;;
	bright_red) tput setab 9 ;;
	bright_green) tput setab 10 ;;
	bright_yellow) tput setab 11 ;;
	bright_blue) tput setab 12 ;;
	bright_magenta) tput setab 13 ;;
	bright_cyan) tput setab 14 ;;
	bright_white) tput setab 15 ;;
	esac
}

# -------------------------------
# Estilos de texto
# -------------------------------
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

# =========================
# Função Principal de Formatação
# =========================
# Aplica formatação usando `tput` (terminfo) para cores e estilos,
# com suporte opcional a ícones (símbolos ou emoji).
#
# Parâmetros:
#   $1   - Texto a ser exibido
#   $2.. - Opções adicionais (em qualquer ordem):
#          - Cores de texto: black, red, green, yellow, blue, magenta, cyan, white, bright_*
#          - Cores de fundo: bg_black, bg_red, bg_green, bg_yellow, bg_blue, bg_magenta, bg_cyan, bg_white
#          - Estilos: reset, bold, dim, underline, reverse, blink
#          - Ícone/emoji: qualquer string (exibido antes do texto)
#
# Observações:
#   - Apenas um ícone é suportado (se múltiplos forem passados, o último é usado).
#   - Ao final do texto, `tput sgr0` é aplicado para resetar formatação.
#
# Saída:
#   Imprime o texto formatado (sem quebra de linha).
#
# Exemplos de uso:
#   format_text "Processando" yellow bold
#   # Saída: Texto amarelo em negrito
#
#   format_text "Sucesso" green "✔" bold
#   # Saída: ✔ Sucesso (verde em negrito)
#
#   format_text "Erro crítico" red "✖" bold underline
#   # Saída: ✖ Erro crítico (vermelho, negrito e sublinhado)
#
#   format_text "Aviso" yellow "⚠" bold blink
#   # Saída: ⚠ Aviso (amarelo piscando e em negrito)
#
#   format_text "Executando" cyan "🚀" bold
#   # Saída: 🚀 Executando (ciano, negrito)
#
#   format_text "Novo arquivo" blue "📂" underline
#   # Saída: 📂 Novo arquivo (azul e sublinhado)
#
#   format_text "Configuração salva" magenta "💾" bold
#   # Saída: 💾 Configuração salva (magenta, negrito)
#
#   format_text "Linux detectado" green "🐧"
#   # Saída: 🐧 Linux detectado (verde simples)
#
# Exemplos de ícones/emoji prontos para copiar:
#
#   ✅ Confirmação / Sucesso:
#   ✔ ✓ ✅ ☑ ★ ✦ ✧
#
#   ❌ Erros / Falhas:
#   ✖ ✘ ❌ ✕ ✗ ⨯ ⛔ 🛑 ☠
#
#   ⚠ Avisos / Alarmes:
#   ⚠ ⚡ ℹ ⏰ 🔔 ❗ ❕ ‼
#
#   ❓ Perguntas / Dúvidas:
#   ? ❓ ❔ ⁉ ⍰
#
#   ℹ Informações:
#   ℹ ⓘ 🛈 🗒 📢
#
#   🔍 Debug / Log:
#   🔍 🐞 🐛 🔎 📝 🐧
#
#   🚀 Progresso / Ação:
#   → ← ↑ ↓ ↔ ↕ ↩ ↪ ⤴ ⤵
#   ➔ ➜ ➞ ➝ ➟ ➠ ➡ ⮕ ⭢ ⬅ ⬆ ⬇ ⇧ ⇩ ⇨ ⇦
#   🚀 ⏳ 🔄 … ⋮ ⋯ ⋰ ⋱ • ○ ◉ ◎ ◆ ◇
#   ◌ ◍ ● ◐ ◑ ◒ ◓ ◔ ◕ ★ ☆ ✦ ✧ ✪ ✫ ✬ ✭ ✮ ✯
#   ⌛ ⏳
#
#   🎵 Música / Mídia:
#   🎶 🎼 🎵 ▶ ⏸ ⏹
#
#   📂 Arquivos / Organização:
#   📂 📁 📄 📜 📑 🗂 🗃 🗄
#   📝 📒 📕 📗 📘 📙 📚 🖹 🖺
#
#   🛠 Tecnologia / Terminal:
#   🖥 💻 ⌨ 🖱 🖲 🖨 ⚙ 🛠 🔧 🔨 ⚒ 🐧 🐍 🐋 📦
#
#   🔔 Alertas e notificações:
#   🔔 🔕 🔊 🔉 🔈 🚨 🚩 🛑 ⛔ ❗ ❕ ‼ ⁉
#
#   🚀 Ação / Destaque:
#   🔥 🚀 💡 ⭐ 🌟 ✨ 🎯 🎵 🎶 🎼
#   📌 📍 🎲 🧩 🏆 🎖 🏅
#
#   🧱 ANSI blocos e símbolos de destaque:
#   █ ▓ ▒ ░ ▞ ▚ ▙ ▛ ▜ ▟
#   ■ □ ▢ ▣ ▤ ▥ ▦ ▧ ▨ ▩ ◆ ◇ ◈ ◉ ◎ ◍
#
format_text() {
	local text="$1"
	shift
	local pre="" post="$(tput sgr0)"
	local icon=""

	while [[ $# -gt 0 ]]; do
		case "$1" in
		# foreground
		black | red | green | yellow | blue | magenta | cyan | white | bright_*)
			pre+=$(get_fg_color "$1")
			;;
		# background (usa prefixo bg_)
		bg_*)
			pre+=$(get_bg_color "${1#bg_}")
			;;
		# estilos
		bold | dim | underline | reverse | blink | reset)
			pre+=$(get_style "$1")
			;;
		# se não for cor/estilo, é ícone
		*)
			icon="$1"
			;;
		esac
		shift
	done

	if [[ -n "$icon" ]]; then
		printf "%b%s %s%b" "$pre" "$icon" "$text" "$post"
	else
		printf "%b%s%b" "$pre" "$text" "$post"
	fi
}

# =========================
# Função para Exibir Comandos
# =========================
# Exibe comandos em uma caixa estilizada que lembra um terminal
#
# Parâmetros:
#   $1 - Comando a ser exibido
#
# Exemplo:
#   fmt_cmd "spotdl download 'url' --format mp3"
#   # Saída:
#   # ╭─────────────────────────────────────────────────────╮
#   # │ $ spotdl download 'url' --format mp3                │
#   # ╰─────────────────────────────────────────────────────╯
#
fmt_cmd() {
	local cmd="$1"
	local max_length=$(($(tput cols) - 8)) # Usa largura do terminal menos margem
	local display_cmd="\$ $cmd"

	# Função auxiliar para criar linha horizontal
	_create_horizontal_line() {
		local length="$1"
		local line
		line=$(printf "%-${length}s" "")
		echo "${line// /─}"
	}

	# Função para calcular comprimento visual considerando caracteres multibyte
	_visual_length() {
		local string="$1"
		# Remove códigos ANSI primeiro (se houver)
		local clean_string
		clean_string=$(echo "$string" | sed 's/\x1b\[[0-9;]*m//g')
		# Calcula comprimento visual usando awk
		echo "$clean_string" | awk '{
            gsub(/[^\x00-\x7F]/, "x")  # Substitui caracteres não-ASCII por "x"
            print length()
        }'
	}

	# Se o comando for muito longo, quebra em múltiplas linhas
	if [[ ${#display_cmd} -gt $max_length ]]; then
		local lines=()
		local current_line=""

		# Divide o comando em palavras para quebra inteligente
		IFS=' ' read -ra words <<<"$display_cmd"

		for word in "${words[@]}"; do
			# Calcula comprimento visual atual
			local current_visual_length=0
			if [[ -n "$current_line" ]]; then
				current_visual_length=$(_visual_length "$current_line")
			fi

			# Calcula comprimento visual da nova palavra
			local word_visual_length=$(_visual_length "$word")

			# Se adicionar esta palavra exceder o limite, inicia nova linha
			if [[ $current_visual_length -eq 0 ]]; then
				current_line="$word"
			elif [[ $((current_visual_length + word_visual_length + 1)) -le $max_length ]]; then
				current_line="$current_line $word"
			else
				lines+=("$current_line")
				current_line="$word"
			fi
		done

		# Adiciona a última linha
		if [[ -n "$current_line" ]]; then
			lines+=("$current_line")
		fi

		# Encontra a linha mais longa (em comprimento visual)
		local longest_line=0
		for line in "${lines[@]}"; do
			local line_length=$(_visual_length "$line")
			if [[ $line_length -gt $longest_line ]]; then
				longest_line=$line_length
			fi
		done

		local total_length=$((longest_line + 2)) # +2 para margem interna

		# Cria as linhas superior e inferior
		local line_content
		line_content=$(_create_horizontal_line "$total_length")
		local top_line="╭${line_content}╮"
		local bottom_line="╰${line_content}╯"

		# Formata e exibe
		printf "%b\n" "$(format_text "$top_line" bright_black)"

		# Imprime cada linha do comando
		for line in "${lines[@]}"; do
			# Preenche a linha com espaços para ter o mesmo comprimento visual
			local visual_len=$(_visual_length "$line")
			local padding=$((longest_line - visual_len))
			printf -v padded_line "%s%*s" "$line" "$padding" ""
			printf "%b %b %b\n" \
				"$(format_text "│" bright_black)" \
				"$(format_text "$padded_line" bright_white "" bold)" \
				"$(format_text "│" bright_black)"
		done

		printf "%b\n" "$(format_text "$bottom_line" bright_black)"
	else
		# Comando curto - exibe em uma única linha
		local visual_length=$(_visual_length "$display_cmd")
		local total_length=$((visual_length + 2))
		local line_content
		line_content=$(_create_horizontal_line "$total_length")
		local top_line="╭${line_content}╮"
		local bottom_line="╰${line_content}╯"

		printf "%b\n" "$(format_text "$top_line" bright_black)"
		printf "%b %b %b\n" \
			"$(format_text "│" bright_black)" \
			"$(format_text "$display_cmd" bright_white "" bold)" \
			"$(format_text "│" bright_black)"
		printf "%b\n" "$(format_text "$bottom_line" bright_black)"
	fi
}

# =========================
# Funções Rápidas (Sem Quebra de Linha)
# =========================

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

# =========================
# Linha Multi-Formatada
# =========================
# Combina múltiplos segmentos de texto com formatações independentes
# Parâmetros:
#   Grupos de 4 parâmetros: texto, cor_texto, cor_fundo, estilo
#   (Últimos parâmetros podem be omitted)
# Saída:
#   Imprime linha com múltiplos textos formatados
# Exemplo:
#   multi_format_line "Error:" red "" bold " File not found" yellow
#   # Saída: [Error: em vermelho negrito] [File not found em amarelo]
multi_format_line() {
	local output=""
	while [[ $# -gt 0 ]]; do
		local txt="$1" fg="" bg="" st=""
		[[ -n "$2" && -n "${TEXT_COLORS[$2]}" ]] && fg="${TEXT_COLORS[$2]}"
		[[ -n "$3" && -n "${BG_COLORS[$3]}" ]] && bg="${BG_COLORS[$3]}"
		[[ -n "$4" && -n "${TEXT_STYLES[$4]}" ]] && st="${TEXT_STYLES[$4]}"
		output+="${fg}${bg}${st}${txt}${TEXT_STYLES[reset]}"
		shift 4 || break
	done
	printf "%b\n" "$output"
}

# =========================
# Funções de Mensagens Formatadas (Com Quebra de Linha)
# =========================

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

# Mensagem de sucesso com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_success "Operação concluída"
#   # Saída: [✔ em fundo verde] [Operação concluída em verde]
fmt_success() {
	local icon
	icon="$(format_text " ✔ " bright_white bg_bright_green bold)"
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
	icon="$(format_text " ? " bright_white bg_bright_cyan bold)"
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
	icon="$(format_text " ⚠ " bright_white bg_bright_yellow bold)"
	local msg
	msg="$(format_text " $1" bright_yellow)"
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
	icon="$(format_text " ✖ " bright_white bg_bright_red bold)"
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
	icon="$(format_text " i " bright_white bg_bright_blue bold)"
	local msg
	msg="$(format_text " $1" bright_blue)"
	printf "%b%b\n" "$icon" "$msg"
}

# Item de configuração detalhado
# Parâmetros:
#   $1 - Label
#   $2 - Valor
# Exemplo:
#   fmt_config_detail "Usuário" "admin"
#   # Saída: [i em azul] [Usuário: em amarelo negrito] [admin em verde negrito]
fmt_config_detail() {
	local icon
	icon="$(format_text " i " bright_white bg_bright_blue bold)"
	local label
	label="$(format_text "$1:" bright_yellow bold)"
	local value
	value="$(format_text " $2" bright_green bold)"
	printf "%b %b%b\n" "$icon" "$label" "$value"
}

# Mensagem de debug com ícone
# Parâmetros:
#   $1 - Mensagem
# Exemplo:
#   fmt_debug "Variável X=42"
#   # Saída: [d em fundo magenta] [Variável X=42 em magenta]
fmt_debug() {
	local icon
	icon="$(format_text " d " bright_white bg_bright_magenta bold)"
	local msg
	msg="$(format_text " $1" bright_magenta)"
	printf "%b%b\n" "$icon" "$msg"
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

# Opção numerada para menus
# Parâmetros:
#   $1 - Número
#   $2 - Descrição
# Exemplo:
#   fmt_option "1" "Instalar pacote"
#   # Saída: [1 em amarelo]) [Instalar pacote]
fmt_option() {
	printf "%b) %b\n" \
		"$(format_text "$1" bright_yellow)" \
		"$2"
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
		"$2" \
		"$(format_text "$3" bright_green bold)"
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

# Prompt para input
# Parâmetros:
#   $1 - Texto do prompt
# Exemplo:
#   fmt_prompt "Digite sua escolha: "
#   # Saída: [Digite sua escolha: em verde negrito] (sem quebra de linha)
fmt_prompt() {
	printf "%b" "$(format_text "$1" bright_green bold)"
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

# =========================
# Funções de Separadores e Linhas
# =========================

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
	printf -v line "%*s" "$length" ""
	printf "%s\n" "${line// /$char}"
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

# Quebras de linha
# Parâmetros:
#   $1 - Número de linhas (padrão: 1)
# Exemplo:
#   newline 2
#   # Saída: duas quebras de linha
newline() {
	local count="${1:-1}"
	for ((i = 0; i < count; i++)); do
		printf "\n"
	done
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

# =========================
# Demonstração de Formatações (--demo)
# =========================
# Exibe exemplos de todas as funções de formatação disponíveis
#
# Parâmetros:
#   Nenhum
#
# Saída:
#   Demonstração organizada de cores, estilos, ícones e funções de mensagens
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

	# 5. Funções de Formatação
	fmt_section "5. Funções de Formatação"
	fmt_config_detail "Configuração" "Valor"
	fmt_config_item "1" "Opção" "Habilitado"
	fmt_option "A" "Opção com letra"
	fmt_prompt "Digite algo: "
	printf "(aguardando input)\n"

	# 6. Separadores
	fmt_section "6. Separadores"
	fmt_separator
	fmt_separator "=" 30
	fmt_separator_color "*" 25 bright_yellow
	fmt_separator_centered "TÍTULO" "-" 30
	fmt_double_separator

	# 7. Elementos Visuais
	fmt_section "7. Elementos Visuais"
	fmt_boxed "TEXTO EM DESTAQUE" bright_white blue bold
	fmt_quote "Esta é uma citação importante que deve ser destacada no texto" bright_cyan

	# 8. Barra de Progresso
	fmt_section "8. Barra de Progresso"
	for i in {0..100..10}; do
		fmt_progress_bar "$i"
		sleep 0.1
	done
	printf "\n"

	# 9. Destaque de Texto
	fmt_section "9. Destaque de Texto"
	fmt_highlight "Este texto contém palavras importantes para destacar" "importantes" black yellow

	# 10. Logs com Timestamp
	fmt_section "10. Logs com Timestamp"
	fmt_log "INFO" "Sistema inicializado com sucesso"
	fmt_log "WARN" "Recurso utilizando 80% da capacidade"
	fmt_log "ERROR" "Falha na conexão com o servidor"

	# 11. Menu de Exemplo
	fmt_section "11. Menu de Exemplo"
	fmt_menu "Iniciar processo" "Ver configurações" "Sair"

	# 12. Lista de Configurações
	fmt_section "12. Lista de Configurações"
	fmt_config_list "Usuário" "admin" "Servidor" "192.168.1.1" "Status" "Ativo"

	# 13. Comandos Formatados
	fmt_section "13. Comandos Formatados"
	fmt_cmd "spotdl download 'https://open.spotify.com/track/...' --format mp3 --bitrate 320k"

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
	fmt_info "Use as funções individuais para testar formatações específicas"
}

# =========================
# Teste Rápido de Formatação (--quicktest)
# =========================
# Executa testes rápidos das funções de formatação especificadas
#
# Parâmetros:
#   $@ - Nomes das funções a serem testadas (separadas por espaço)
#
# Saída:
#   Exibe na tela os efeitos de cores, estilos e formatações
fmt_quicktest() {
	for func in "$@"; do
		# Verifica se a função existe
		if declare -f "$func" >/dev/null; then
			fmt_section "Testando: $func"

			case "$func" in
			# Funções de mensagens com cores específicas
			fmt_success | fmt_warning | fmt_error | fmt_info | fmt_debug | fmt_question)
				"$func" "Mensagem de teste"
				;;
			# Separadores e elementos visuais
			fmt_separator)
				"$func"
				;;
			fmt_separator_color)
				"$func" "-" 20 bright_green
				;;
			# Barra de progresso de exemplo
			fmt_progress_bar)
				for i in {0..100..20}; do
					"$func" "$i"
					sleep 0.1
				done
				printf "\n"
				;;
			# Comandos formatados
			fmt_cmd)
				"$func" "echo 'test command'"
				;;
			# Funções genéricas de teste
			*)
				"$func" "Teste" "Valor"
				;;
			esac
		else
			fmt_error "Função não encontrada: $func"
		fi
	done
}

# =========================
# Modo Interativo de Teste (--interactive)
# =========================
# Permite testar todas as funções de formatação (cores, fundo, estilos, etc.)
# sem depender de variáveis globais, apenas usando `tput`.
#
# Saída:
#   Interface interativa para testar diferentes formatações
fmt_interactive() {
	while true; do
		tput clear
		fmt_header "MODO INTERATIVO DE TESTE"

		fmt_menu "1. Testar cores de texto" \
			"2. Testar cores de fundo" \
			"3. Testar estilos" \
			"4. Testar funções de mensagem" \
			"5. Testar elementos visuais" \
			"6. Testar comandos formatados" \
			"7. Testar ícones personalizados" \
			"0. Sair"

		fmt_prompt "Selecione uma opção: "
		read -r choice

		case $choice in
		1)
			tput clear
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
			tput clear
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
			tput clear
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
			tput clear
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
			tput clear
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
			tput clear
			fmt_section "COMANDOS FORMATADOS"
			fmt_cmd "ls -la"
			fmt_cmd "curl -X GET https://api.example.com/v1/users"
			fmt_cmd "docker run -it --rm ubuntu:20.04 bash -c 'echo Hello World'"
			fmt_prompt "Pressione Enter para continuar..."
			read -r
			;;
		7)
			tput clear
			fmt_section "ÍCONES PERSONALIZADOS"
			format_text " Tecnologia" bright_blue "💻"
			echo
			format_text " Música" bright_green "🎵"
			echo
			format_text " Arquivos" bright_yellow "📂"
			echo
			format_text " Pesquisa" bright_magenta "🔍"
			echo
			format_text " Energia" bright_yellow "⚡"
			echo
			format_text " Ideia" bright_cyan "💡"
			echo
			format_text " Linux" bright_white "🐧"
			echo
			format_text " Foguete" bright_cyan "🚀"
			echo
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

# =========================
# Bloco de Teste (Executável Direto)
# =========================
# Permite testar rapidamente todas as funções de formatação
# se este arquivo for executado diretamente.
# Parâmetros:
#   --demo        : Executa a demonstração completa
#   --quicktest   : Executa testes rápidos de funções específicas
#   --interactive : Abre o modo interativo de teste
#   --test        : Executa um conjunto de exemplos de formatação
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	case "${1:-}" in
	--demo)
		fmt_demo
		;;
	--quicktest)
		shift
		fmt_quicktest "$@"
		;;
	--interactive)
		fmt_interactive
		;;
	--test)
		# Seção de teste rápida para validar várias funções
		fmt_section "Teste de Formatação"

		# Menu de exemplo
		fmt_menu "Opção 1" "Opção 2" "Opção 3"

		# Lista de configurações simulada
		fmt_config_list "Usuário" "admin" "Tema" "escuro" "Versão" "1.0"

		# Mensagens de alerta e status
		fmt_warning "Atenção!"
		fmt_error "Erro fatal"
		fmt_success "Operação concluída"
		fmt_info "Informação geral"
		fmt_question "Mensagem de pergunta"

		# Separador customizado
		fmt_separator "=" 40

		# Barra de progresso de exemplo
		fmt_progress_bar 72
		printf "\n"

		# Linha com múltiplas formatações
		multi_format_line "Parte1 " red "" bold \
			"Parte2 " green "" underline \
			"Fim" bright_blue

		# Caixa de destaque
		fmt_boxed "AVISO IMPORTANTE" bright_yellow red bold

		# Citação
		fmt_quote "Esta é uma citação destacada" bright_cyan

		# Texto com destaque de palavra
		fmt_highlight "Este texto contém uma palavra importante para destacar" "importante" black yellow

		# Logs simulados
		fmt_log "INFO" "Mensagem de informação"
		fmt_log "ERROR" "Erro crítico detectado"

		# Comando formatado
		fmt_cmd "echo 'Comando de exemplo'"
		;;
	*)
		# Nenhuma ação por padrão
		;;
	esac
fi
