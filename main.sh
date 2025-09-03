#!/bin/bash
# main.sh - Script principal com modo debug

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
# FUNÇÕES DE CORES (usando tput com fallback)
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
# FUNÇÕES DE LOGGING CENTRALIZADAS
# ==================================================
debug_log() {
	[ "$DEBUG" = true ] || return
	local timestamp
	timestamp=$(date +"%T.%3N")
	printf "${YELLOW}[DEBUG][$timestamp]${RESET} %s\n" "$*" >&2
}

log_step() {
	[ "$DEBUG" = true ] || return
	printf "\n${CYAN}==================================================${RESET}\n" >&2
	printf "${CYAN}==> $*${RESET}\n" >&2
	printf "${CYAN}==================================================${RESET}\n\n" >&2
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
# DIRETÓRIOS E VARIÁVEIS ESSENCIAIS
# ==================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$BASE_DIR/modules"
LANG_DIR="$BASE_DIR/lang"
XDG_DOWNLOADS_DIR="$(xdg-user-dir DOWNLOAD 2>/dev/null || echo "$HOME/Downloads")"

SPOTDL_CONFIG_DIR="$HOME/.spotdl"
HELPER_CONFIG_DIR="$HOME/.spotdl-helper"
SPOTDL_CONFIG_PATH="$SPOTDL_CONFIG_DIR/config.json"
HELPER_CONFIG_PATH="$HELPER_CONFIG_DIR/helper-config.json"

# ==================================================
# CARREGAR MÓDULOS DE FORMATAÇÃO (agora com cores hardcoded)
# ==================================================
log_step "CARREGANDO MÓDULOS DE FORMATAÇÃO"
load_module "$MODULES_DIR/formatting/_load.sh"

# ==================================================
# CARREGAR MÓDULOS BASE
# ==================================================
log_step "CARREGANDO MÓDULOS BASE"
for base in utils ui_prompts; do
	load_module "$MODULES_DIR/${base}.sh"
done

# ==================================================
# CARREGAR MÓDULOS DE CONFIGURAÇÃO
# ==================================================
load_module "$MODULES_DIR/config/_load.sh"

# ==================================================
# FUNÇÕES AUXILIARES
# ==================================================
init_config_system() {
	log_step "INICIALIZANDO SISTEMA DE CONFIGURAÇÃO"
	mkdir -p "$SPOTDL_CONFIG_DIR" "$HELPER_CONFIG_DIR"
	debug_log "${CYAN}Diretórios de configuração:${GREEN} criados/verificados${RESET}"

	[[ -f "$SPOTDL_CONFIG_PATH" ]] || {
		debug_log "${CYAN}Criando config:${GREEN} spotDL${RESET}"
		save_spotdl_config
	}
	[[ -f "$HELPER_CONFIG_PATH" ]] || {
		debug_log "${CYAN}Criando config:${GREEN} helper${RESET}"
		save_helper_config
	}
}

# ==================================================
# INICIALIZAÇÃO
# ==================================================
log_step "INICIANDO SISTEMA"
debug_log "${CYAN}Diretório base:${GREEN} $BASE_DIR${RESET}"
debug_log "${CYAN}Diretório de módulos:${GREEN} $MODULES_DIR${RESET}"
debug_log "${CYAN}Config spotDL:${GREEN} $SPOTDL_CONFIG_PATH${RESET}"
debug_log "${CYAN}Config helper:${GREEN} $HELPER_CONFIG_PATH${RESET}"
debug_log "${CYAN}Downloads padrão:${GREEN} $XDG_DOWNLOADS_DIR${RESET}"

init_config_system

# ==================================================
# CARREGAR MÓDULOS FUNCIONAIS
# ==================================================
log_step "CARREGANDO MÓDULOS DE DOWNLOADS"
load_module "$MODULES_DIR/download/_load.sh"

log_step "CARREGANDO MÓDULOS DO MANAGER SPOTDL"
load_module "$MODULES_DIR/manage_spotdl/_load.sh"

# Dependências
load_module "$MODULES_DIR/dependencies.sh"

# Menu
load_module "$MODULES_DIR/menu.sh"

# ==================================================
# CARREGAR CONFIGURAÇÕES E IDIOMA
# ==================================================
log_step "CARREGANDO CONFIGURAÇÕES"
load_ui_strings "${CURRENT_LANG:-pt_BR}"
load_config
debug_log "${CYAN}Configurações:${GREEN} carregadas${RESET}"

# ==================================================
# VERIFICAÇÕES INICIAIS
# ==================================================
log_step "VERIFICANDO DEPENDÊNCIAS"
check_dependencies || {
	printf "${RED}Dependências faltando. Abortando.${RESET}\n"
	exit 1
}
debug_log "${CYAN}Dependências:${GREEN} verificadas com sucesso${RESET}"

log_step "VERIFICANDO SPOTDL"
if check_spotdl; then
	debug_log "${CYAN}SpotDL verificado:${GREEN} $SPOTDL_CMD${RESET}"
	spotdl_version=$("$SPOTDL_CMD" --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "N/A")
	debug_log "${CYAN}Versão SpotDL:${GREEN} $spotdl_version${RESET}"
else
	printf "${RED}Falha ao verificar spotDL. Abortando.${RESET}\n"
	exit 1
fi

# ==================================================
# FUNÇÃO DE PAUSA NO DEBUG
# ==================================================
debug_pause() {
	[ "$DEBUG" = true ] || return
	printf "\n${CYAN}==================================================${RESET}\n"
	printf "${CYAN}==>${RESET}${GREEN} PRESSIONE ENTER PARA CONTINUAR...${RESET}\n"
	printf "${CYAN}==================================================${RESET}\n"
	read -r -n 1 _ </dev/tty
}

# ==================================================
# EXECUÇÃO PRINCIPAL (MODO DEBUG)
# ==================================================
log_step "INICIANDO APLICAÇÃO"
debug_log "${CYAN}Configurações atuais:${RESET}"
debug_log "  ${CYAN}Idioma:${GREEN} $CURRENT_LANG${RESET}"
debug_log "  ${CYAN}Diretório downloads:${GREEN} $FINAL_DIR${RESET}"
debug_log "  ${CYAN}Template:${GREEN} $OUTPUT_STRUCTURE${RESET}"
debug_log "  ${CYAN}Formato:${GREEN} ${EDITABLE_CONFIG[format]}${RESET}"
debug_log "  ${CYAN}Bitrate:${GREEN} ${EDITABLE_CONFIG[bitrate]}${RESET}"
debug_log "  ${CYAN}Threads:${GREEN} ${EDITABLE_CONFIG[threads]}${RESET}"
debug_log "  ${CYAN}Gerar letras:${GREEN} ${EDITABLE_CONFIG[generate_lrc]}${RESET}"
debug_log "  ${CYAN}Pular capa:${GREEN} ${EDITABLE_CONFIG[skip_album_art]}${RESET}"
debug_log "  ${CYAN}Sincronizar sem deletar:${GREEN} ${EDITABLE_CONFIG[sync_without_deleting]}${RESET}"
debug_log "  ${CYAN}Remover LRC na sincronização:${GREEN} ${EDITABLE_CONFIG[sync_remove_lrc]}${RESET}"
debug_log "  ${CYAN}Sobrescrita:${GREEN} ${EDITABLE_CONFIG[overwrite]}${RESET}"
debug_log "  ${CYAN}Sem cache:${GREEN} ${EDITABLE_CONFIG[no_cache]}${RESET}"
debug_log "  ${CYAN}Máximo de backups:${GREEN} $MAX_BACKUPS${RESET}"
debug_log "  ${CYAN}Provedores de letras:${GREEN} $(format_lyrics_providers_display)${RESET}"

if [ "$DEBUG" = true ]; then
	debug_pause
fi

# ==================================================
# CHAMADA DO MENU PRINCIPAL
# ==================================================
main_menu
