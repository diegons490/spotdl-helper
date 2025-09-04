# modules/ui/load_ui_strings.sh
# Sistema de idiomas modularizado

declare -gA PROMPT_MSGS=()

# Caminho absoluto baseado no main.sh ou diretório base do projeto
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LANG_DIR="$BASE_DIR/lang"

load_ui_strings() {
	local lang="${1:-pt_BR}"
	local lang_file="${LANG_DIR}/${lang}.lang"

	# Limpa o array existente
	PROMPT_MSGS=()

	if [[ -f "$lang_file" ]]; then
		source "$lang_file"
		for key in "${!LANG_MSGS[@]}"; do
			PROMPT_MSGS["$key"]="${LANG_MSGS[$key]}"
		done
	else
		printf "✖ Arquivo de idioma não encontrado: %s\n" "$lang_file" >&2
		[[ "$lang" != "pt_BR" ]] && load_ui_strings "pt_BR"
	fi
}
