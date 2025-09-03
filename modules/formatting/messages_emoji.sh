#!/bin/bash
# modules/formatting/messages_emoji.sh
# Fortação de textos informativos com emoji

# ==========================================
# Exemplos de uso:
# fmt_success_emoji "Download concluído!"
# fmt_warning_emoji "Arquivo já existe!"
# fmt_error_emoji "Falha ao conectar ao servidor!"
# fmt_info_emoji "Processando arquivos..."
# fmt_debug_emoji "Valor da variável X = 42"
# fmt_question_emoji "Deseja continuar?"
# fmt_config_emoji "Bitrate configurado para 320kbps"
# ==========================================

# ✅ Mensagem de sucesso com emoji
# Uso: fmt_success_emoji "Mensagem"
fmt_success_emoji() {
	local msg
	msg="$(format_text "$1" bright_green)"
	printf "✅ %b\n" "$msg"
}

# ⚠️ Mensagem de aviso com emoji
# Uso: fmt_warning_emoji "Mensagem"
fmt_warning_emoji() {
	local msg
	msg="$(format_text "$1" bright_yellow)"
	printf "⚠️ %b\n" "$msg"
}

# ❌ Mensagem de erro com emoji
# Uso: fmt_error_emoji "Mensagem"
fmt_error_emoji() {
	local msg
	msg="$(format_text "$1" bright_red)"
	printf "❌ %b\n" "$msg"
}

# ℹ️ Mensagem informativa com emoji
# Uso: fmt_info_emoji "Mensagem"
fmt_info_emoji() {
	local msg
	msg="$(format_text "$1" bright_blue)"
	printf "ℹ️ %b\n" "$msg"
}

# 🐞 Mensagem de debug com emoji
# Uso: fmt_debug_emoji "Mensagem"
fmt_debug_emoji() {
	local msg
	msg="$(format_text "$1" magenta)"
	printf "🐞 %b\n" "$msg"
}

# ❓ Mensagem de pergunta com emoji
# Uso: fmt_question_emoji "Mensagem"
fmt_question_emoji() {
	local msg
	msg="$(format_text "$1" bright_cyan)"
	printf "❓ %b\n" "$msg"
}

# ⚙️ Mensagem de detalhe de configuração
# Uso: fmt_config_emoji "Mensagem"
fmt_config_emoji() {
	local msg
	msg="$(format_text "$1" bright_white)"
	printf "⚙️ %b\n" "$msg"
}

# ℹ️ Mensagem de detalhe com emoji e cores
# Uso: fmt_config_detail_emoji "Label" "Valor"
fmt_config_detail_emoji() {
	local icon="ℹ️"
	local label
	label="$(format_text "$1:" bright_yellow)"
	local value
	value="$(format_text " $2" bright_green)"
	printf "%b %b%b\n" "$icon" "$label" "$value"
}
