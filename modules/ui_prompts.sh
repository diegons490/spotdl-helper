#!/bin/bash
# modules/ui_prompts.sh - Sistema de idiomas modularizado

declare -gA PROMPT_MSGS=()
LANG_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lang"

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
        printf "\n${RED}Arquivo de idioma não encontrado: %s${RESET}\n" "$lang_file" >&2
        # Tenta carregar o idioma padrão como fallback
        if [[ "$lang" != "pt_BR" ]]; then
            load_ui_strings "pt_BR"
        fi
    fi
}

# Função para acessar mensagens com fallback seguro
get_msg() {
    local key="$1"

    # Verificar se as mensagens foram carregadas
    if [[ ${#PROMPT_MSGS[@]} -eq 0 ]]; then
        load_ui_strings "${CURRENT_LANG:-pt_BR}"
    fi
    
    if [[ -v PROMPT_MSGS[$key] ]]; then
        printf "%s" "${PROMPT_MSGS[$key]}"
    else
        # Fallback para chaves essenciais
        case "$key" in
            invalid_option) echo "Opção inválida" ;;
            or_char) echo "ou" ;;
            yes_char) echo "s" ;;
            no_char) echo "n" ;;
            *)
                printf "\n${RED}ERROR: Chave de mensagem não encontrada: '%s'${RESET}\n" "$key" >&2
                echo "$key" 
                ;;
        esac
    fi
}