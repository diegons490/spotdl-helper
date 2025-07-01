#!/bin/bash
# modules/main.sh
# Configuração de caminhos e carregamento de módulos

# Diretórios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR"
DOWNLOADS_DIR="$(xdg-user-dir DOWNLOAD)"
FINAL_DIR="$DOWNLOADS_DIR/SpotDL"
LANG_DIR="$(dirname "$SCRIPT_DIR")/lang"
DEFAULT_LANG="en_US"
CURRENT_LANG="$DEFAULT_LANG"

export SCRIPT_DIR

# Debug inicial
echo -e "\n${CYAN}=== INICIANDO SCRIPT ===${RESET}"
echo -e "Script: ${BOLD}${YELLOW}${BASH_SOURCE[0]}${RESET}"
echo -e "Diretório base: ${BLUE}$SCRIPT_DIR${RESET}"

# Novos caminhos de configuração
SPOTDL_CONFIG_DIR="$HOME/.spotdl"
HELPER_CONFIG_DIR="$HOME/.spotdl-helper"
SPOTDL_CONFIG="$SPOTDL_CONFIG_DIR/config.json"
HELPER_CONFIG="$HELPER_CONFIG_DIR/helper-config.json"

# Criar diretórios de configuração se não existirem
echo -e "\n${GREEN}Criando diretórios de configuração:${RESET}"
echo -e " - ${SPOTDL_CONFIG_DIR}"
mkdir -p "$SPOTDL_CONFIG_DIR"
echo -e " - ${HELPER_CONFIG_DIR}"
mkdir -p "$HELPER_CONFIG_DIR"

# Carregar módulos essenciais
echo -e "\n${GREEN}Carregando módulos essenciais:${RESET}"
source "$MODULES_DIR/utils.sh" && echo -e " - utils.sh [${GREEN}OK${RESET}]"
source "$MODULES_DIR/ui_prompts.sh" && echo -e " - ui_prompts.sh [${GREEN}OK${RESET}]"

# Carregar demais módulos
echo -e "\n${GREEN}Carregando outros módulos:${RESET}"
for module in dependencies config downloads manage_spotdl menu; do
    module_path="$MODULES_DIR/${module}.sh"
    if [[ -f "$module_path" ]]; then
        source "$module_path"
        echo -e " - ${module}.sh [${GREEN}OK${RESET}]"
    else
        echo -e " - ${module}.sh [${RED}ERROR: Não encontrado${RESET}]" >&2
        exit 1
    fi
done

# Carregar configurações e idioma
echo -e "\n${GREEN}Carregando configurações:${RESET}"
load_config && echo -e " - Configurações carregadas [${GREEN}OK${RESET}]"
load_ui_strings "$CURRENT_LANG" && echo -e " - Traduções carregadas [${GREEN}OK${RESET}]"

# Verificar dependências e spotDL
echo -e "\n${GREEN}Verificando dependências:${RESET}"
check_dependencies && echo -e " - Dependências verificadas [${GREEN}OK${RESET}]"
check_spotdl && echo -e " - SpotDL verificado [${GREEN}OK${RESET}]"

# Iniciar menu principal
echo -e "\n${GREEN}Iniciando menu principal...${RESET}\n"
menu