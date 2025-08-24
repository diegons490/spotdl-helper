#!/bin/bash
# modules/ui_prompts.sh - Sistema de idiomas modularizado

declare -gA PROMPT_MSGS=()
LANG_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lang"

# Carregar módulo de formatação
source "$(dirname "${BASH_SOURCE[0]}")/formatting.sh"

# Função para carregar idioma
load_ui_strings() {
    local lang="${1:-pt_BR}"
    local lang_file="${LANG_DIR}/${lang}.lang"
    
    # Limpa o array existente
    PROMPT_MSGS=()
    
    if [[ -f "$lang_file" ]]; then
        # Carrega o arquivo de idioma
        source "$lang_file"
        
        # Copia as mensagens para o array global
        for key in "${!LANG_MSGS[@]}"; do
            PROMPT_MSGS["$key"]="${LANG_MSGS[$key]}"
        done
    else
        fmt_error "Arquivo de idioma não encontrado: $lang_file" >&2
        # Tenta carregar o idioma padrão como fallback
        if [[ "$lang" != "pt_BR" ]]; then
            load_ui_strings "pt_BR"
        fi
    fi
}

get_msg() {
    local key="$1"

    # Verificar se as mensagens foram carregadas
    if [[ ${#PROMPT_MSGS[@]} -eq 0 ]]; then
        load_ui_strings "${CURRENT_LANG:-pt_BR}"
    fi
    
    if [[ -v PROMPT_MSGS[$key] ]]; then
        # Interpreta sequências de escape como \n para quebra de linha
        printf "%b" "${PROMPT_MSGS[$key]}"
    else
        # Fallback para chaves essenciais
        case "$key" in
            invalid_option) echo "Opção inválida" ;;
            or_char) echo "ou" ;;
            yes_char) echo "s" ;;
            no_char) echo "n" ;;
            *)
                fmt_error "ERROR: Chave de mensagem não encontrada: '$key'" >&2
                echo "$key" 
                ;;
        esac
    fi
}
