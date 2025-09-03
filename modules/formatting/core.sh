#!/bin/bash
# modules/formatting/core.sh
# Função Principal de Formatação

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

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

# Variante do format_text sem reset no final
format_text_norestore() {
	local text="$1"
	shift
	local pre="" post=""
	local icon=""

	while [[ $# -gt 0 ]]; do
		case "$1" in
		black | red | green | yellow | blue | magenta | cyan | white | bright_*)
			pre+=$(get_fg_color "$1")
			;;
		bg_*) pre+=$(get_bg_color "${1#bg_}") ;;
		bold | dim | underline | reverse | blink | reset) pre+=$(get_style "$1") ;;
		*) icon="$1" ;;
		esac
		shift
	done

	if [[ -n "$icon" ]]; then
		printf "%b%s %s" "$pre" "$icon" "$text"
	else
		printf "%b%s" "$pre" "$text"
	fi
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
# Linha Multi-Formatada
# =========================
# Combina múltiplos segmentos de texto, cada um com sua própria formatação.
# Parâmetros:
#   Devem ser passados em grupos de 4:
#       1º: texto
#       2º: cor do texto (foreground) ou "" para omitir
#       3º: cor de fundo (background) ou "" para omitir
#       4º: estilo ou "" para omitir
#   É possível omitir cores ou estilos usando strings vazias ou passando apenas o texto.
# Saída:
#   Imprime no terminal a linha completa, aplicando cada formatação individualmente.
# Exemplos:
#   multi_format_line \
#       "Error: " red "" bold \
#       "File not found" yellow "" ""
#   multi_format_line \
#       "Success: " bright_green "" bold \
#       "Operation completed" white "" underline

multi_format_line() {
	local output=""

	while [[ $# -gt 0 ]]; do
		local txt="$1"
		local fg="${2:-}"
		local bg="${3:-}"
		local st="${4:-}"

		# Aplica formatação usando format_text
		output+=$(format_text "$txt" "$fg" "bg_$bg" "$st")

		# Avança para o próximo grupo
		shift 4 || break
	done

	printf "%b\n" "$output"
}
