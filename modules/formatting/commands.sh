#!/bin/bash
# modules/formatting/commands.sh
# Função para destacar comandos

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
		printf "${line// /─}"
	}

	# Função para calcular comprimento visual considerando caracteres multibyte
	_visual_length() {
		local string="$1"
		# Remove códigos ANSI primeiro (se houver)
		local clean_string
		clean_string=$(printf "$string" | sed 's/\x1b\[[0-9;]*m//g')
		# Calcula comprimento visual usando awk
		printf "$clean_string" | awk '{
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
