#!/bin/bash
# main.sh - Script principal do SpotDL Helper com modo debug

# ==================================================
# CONFIGURAÇÕES DE DEBUG
# ==================================================
DEBUG=false
for arg in "$@"; do
	case "$arg" in
	--debug | --verbose) DEBUG=true ;;
	esac
done

# ==================================================
# FUNÇÕES DE CORES
# ==================================================
init_colors() {
	if command -v tput >/dev/null 2>&1; then
		RED=$(tput setaf 1)
		GREEN=$(tput setaf 2)
		YELLOW=$(tput setaf 3)
		BLUE=$(tput setaf 4)
		MAGENTA=$(tput setaf 5)
		CYAN=$(tput setaf 6)
		WHITE=$(tput setaf 7)
		RESET=$(tput sgr0)
	else
		RED='\033[0;31m'
		GREEN='\033[0;32m'
		YELLOW='\033[1;33m'
		BLUE='\033[0;34m'
		MAGENTA='\033[0;35m'
		CYAN='\033[0;36m'
		WHITE='\033[1;37m'
		RESET='\033[0m'
	fi
}
init_colors

# ==================================================
# FUNÇÕES DE LOGGING
# ==================================================
debug_log() {
	[ "$DEBUG" = true ] || return
	local ts
	ts=$(date +"%T.%3N")
	printf "${YELLOW}[DEBUG][$ts]${RESET} %s\n" "$*" >&2
}
log_step() {
	[ "$DEBUG" = true ] || return
	printf "\n${CYAN}==================================================${RESET}\n"
	printf "${CYAN}==> $*${RESET}\n"
	printf "${CYAN}==================================================${RESET}\n\n"
}
log_module_status() {
	local status="$1" path="$2" name
	name=$(basename "$path")
	if [ "$status" = "OK" ]; then
		debug_log "${GREEN}✔ Módulo carregado${RESET} → ${MAGENTA}${name}${RESET} ($(dirname "$path"))"
	else
		printf "${RED}✖ Módulo não encontrado → ${name} ($(dirname "$path"))${RESET}\n" >&2
	fi
}

# ==================================================
# FUNÇÃO PARA CARREGAR MÓDULOS
# ==================================================
load_module() {
	local path="$1"
	if [[ -f "$path" ]]; then
		source "$path"
		log_module_status "OK" "$path"
	else
		log_module_status "FAIL" "$path"
		exit 1
	fi
}

# ==================================================
# VARIÁVEIS E DIRETÓRIOS ESSENCIAIS
# ==================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$BASE_DIR/modules"
LANG_DIR="$BASE_DIR/lang"
XDG_DOWNLOADS_DIR="$(xdg-user-dir DOWNLOAD 2>/dev/null || echo "$HOME/Downloads")"

SPOTDL_CONFIG_DIR="$HOME/.spotdl"
HELPER_CONFIG_DIR="$HOME/.spotdl-helper"
SPOTDL_CONFIG_PATH="$SPOTDL_CONFIG_DIR/config.json"
HELPER_CONFIG_PATH="$HELPER_CONFIG_DIR/helper-config.json"

FINAL_DIR="$XDG_DOWNLOADS_DIR/SpotDL"

# ==================================================
# CARREGAMENTO DE MÓDULOS CORE
# ==================================================
load_module "$MODULES_DIR/formatting/_load.sh"
load_module "$MODULES_DIR/ui/_load.sh"
load_module "$MODULES_DIR/utils/_load.sh"
load_module "$MODULES_DIR/config/_load.sh"

# ==================================================
# INICIALIZAÇÃO DE CONFIGURAÇÕES
# ==================================================
init_config_system() {
	log_step "INICIALIZANDO SISTEMA DE CONFIGURAÇÃO"
	mkdir -p "$SPOTDL_CONFIG_DIR" "$HELPER_CONFIG_DIR"

	[[ -f "$SPOTDL_CONFIG_PATH" ]] || save_spotdl_config
	[[ -f "$HELPER_CONFIG_PATH" ]] || save_helper_config

	debug_log "${CYAN}Diretórios e configs criados/verificados${RESET}"
}

init_config_system

# ==================================================
# CARREGAMENTO DE MÓDULOS ESPECÍFICOS
# ==================================================
load_module "$MODULES_DIR/download/_load.sh"
load_module "$MODULES_DIR/manage_spotdl/_load.sh"
load_module "$MODULES_DIR/enviroment/_load.sh"
load_module "$MODULES_DIR/menu/_load.sh"

# ==================================================
# CARREGAMENTO DE CONFIGURAÇÕES E IDIOMA
# ==================================================
log_step "CARREGAMENTO DE CONFIGURAÇÕES E IDIOMA"
CURRENT_LANG="${CURRENT_LANG:-pt_BR}"
load_ui_strings "$CURRENT_LANG"
load_config
debug_log "${CYAN}Configurações carregadas${RESET}"

# ==================================================
# VERIFICAÇÃO DE DEPENDÊNCIAS
# ==================================================
log_step "VERIFICANDO DEPENDÊNCIAS"
check_dependencies || {
	printf "${RED}Dependências faltando. Abortando.${RESET}\n"
	exit 1
}
debug_log "${CYAN}Dependências verificadas${RESET}"

# ==================================================
# VERIFICAÇÃO DO SPOTDL
# ==================================================
log_step "VERIFICANDO SPOTDL"
if check_spotdl; then
	debug_log "${CYAN}SpotDL verificado:${GREEN} $SPOTDL_CMD${RESET}"
	spotdl_version=$("$SPOTDL_CMD" --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "N/A")
	debug_log "${CYAN}Versão SpotDL:${GREEN} $spotdl_version${RESET}"
else
	printf "${RED}Falha ao verificar SpotDL. Abortando.${RESET}\n"
	exit 1
fi

# ==================================================
# FUNÇÃO DE PAUSA DEBUG
# ==================================================
debug_pause() {
	[ "$DEBUG" = true ] || return
	printf "\n${CYAN}==================================================${RESET}\n"
	printf "${CYAN}==>${RESET}${GREEN} PRESSIONE ENTER PARA CONTINUAR...${RESET}\n"
	printf "${CYAN}==================================================${RESET}\n"
	read -r -n 1 _ </dev/tty
}

# ==================================================
# EXIBIÇÃO DE CONFIGURAÇÕES ATUAIS (DEBUG)
# ==================================================
log_step "CONFIGURAÇÕES ATUAIS"
debug_log "Idioma: ${GREEN}$CURRENT_LANG${RESET}"
debug_log "Diretório downloads: ${GREEN}$FINAL_DIR${RESET}"
debug_log "Template: ${GREEN}$OUTPUT_STRUCTURE${RESET}"
debug_log "Formato: ${GREEN}${EDITABLE_CONFIG[format]}${RESET}"
debug_log "Bitrate: ${GREEN}${EDITABLE_CONFIG[bitrate]}${RESET}"
debug_log "Threads: ${GREEN}${EDITABLE_CONFIG[threads]}${RESET}"
debug_log "Gerar letras: ${GREEN}${EDITABLE_CONFIG[generate_lrc]}${RESET}"
debug_log "Pular capa: ${GREEN}${EDITABLE_CONFIG[skip_album_art]}${RESET}"
debug_log "Sincronizar sem deletar: ${GREEN}${EDITABLE_CONFIG[sync_without_deleting]}${RESET}"
debug_log "Remover LRC na sincronização: ${GREEN}${EDITABLE_CONFIG[sync_remove_lrc]}${RESET}"
debug_log "Sobrescrita: ${GREEN}${EDITABLE_CONFIG[overwrite]}${RESET}"
debug_log "Sem cache: ${GREEN}${EDITABLE_CONFIG[no_cache]}${RESET}"
debug_log "Máximo de backups: ${GREEN}$MAX_BACKUPS${RESET}"
debug_log "Provedores de letras: ${GREEN}$(format_lyrics_providers_display)${RESET}"

[ "$DEBUG" = true ] && debug_pause

# ==================================================
# INÍCIO DO MENU PRINCIPAL
# ==================================================
menu_main
