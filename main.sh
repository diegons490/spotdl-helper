#!/bin/bash
# main.sh - Script principal com modo debug aprimorado e cores ajustadas

# ==================================================
# CONFIGURAÇÕES DE DEBUG
# ==================================================
DEBUG=false

# ==================================================
# PROCESSAMENTO DE ARGUMENTOS
# ==================================================
for arg in "$@"; do
    case "$arg" in
        --debug|--verbose)
            DEBUG=true
            ;;
    esac
done

# ==================================================
# DIRETÓRIOS E VARIÁVEIS ESSENCIAIS
# ==================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$BASE_DIR/modules"
LANG_DIR="$BASE_DIR/lang"
XDG_DOWNLOADS_DIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
if [[ -z "$XDG_DOWNLOADS_DIR" ]]; then
    XDG_DOWNLOADS_DIR="$HOME/Downloads"
fi

SPOTDL_CONFIG_DIR="$HOME/.spotdl"
HELPER_CONFIG_DIR="$HOME/.spotdl-helper"

SPOTDL_CONFIG_PATH="$SPOTDL_CONFIG_DIR/config.json"
HELPER_CONFIG_PATH="$HELPER_CONFIG_DIR/helper-config.json"

# ==================================================
# FUNÇÕES DE LOGGING APRIMORADAS
# ==================================================
debug_log() {
    if [ "$DEBUG" = true ]; then
        local timestamp
        timestamp=$(date +"%T.%3N")
        printf "%b\n" "$(format_text "[DEBUG][$timestamp] $*" bright_white)" >&2
    fi
}

log_step() {
    if [ "$DEBUG" = true ]; then
        printf "\n%b\n" "$(format_text "==> $*" bright_cyan bold)" >&2
    fi
}

# ==================================================
# CARREGAR MÓDULOS ESSENCIAIS
# ==================================================
log_step "CARREGANDO MÓDULOS BASE"
source "$MODULES_DIR/formatting.sh"   # cores e estilos para saída
source "$MODULES_DIR/utils.sh"        # funções utilitárias
source "$MODULES_DIR/ui_prompts.sh"   # interação e mensagens multilíngues
source "$MODULES_DIR/config_env.sh"   # variáveis globais e configs auxiliares
debug_log "Módulos base carregados"

# ==================================================
# FUNÇÕES AUXILIARES
# ==================================================
init_config_system() {
    log_step "INICIALIZANDO SISTEMA DE CONFIGURAÇÃO"
    mkdir -p "$SPOTDL_CONFIG_DIR" "$HELPER_CONFIG_DIR"
    debug_log "Diretórios de configuração criados/verificados"

    if [[ ! -f "$SPOTDL_CONFIG_PATH" ]]; then
        debug_log "Criando arquivo de configuração do spotDL..."
        save_spotdl_config
    fi

    if [[ ! -f "$HELPER_CONFIG_PATH" ]]; then
        debug_log "Criando arquivo de configuração do helper..."
        save_helper_config
    fi
}

# ==================================================
# INICIALIZAÇÃO
# ==================================================
log_step "INICIANDO SISTEMA"
debug_log "Diretório base: $BASE_DIR"
debug_log "Diretório de módulos: $MODULES_DIR"
debug_log "Config spotDL: $SPOTDL_CONFIG_PATH"
debug_log "Config helper: $HELPER_CONFIG_PATH"
debug_log "Downloads padrão: $XDG_DOWNLOADS_DIR"

init_config_system

# ==================================================
# CARREGAR MÓDULOS SECUNDÁRIOS
# ==================================================
log_step "CARREGANDO MÓDULOS FUNCIONAIS"
for module in dependencies downloads manage_spotdl menu; do
    module_path="$MODULES_DIR/${module}.sh"
    if [[ -f "$module_path" ]]; then
        source "$module_path"
        debug_log "Módulo carregado: ${module}.sh"
    else
        fmt_error "ERRO: Módulo não encontrado - ${module}.sh" >&2
        exit 1
    fi
done

# ==================================================
# CARREGAR CONFIGURAÇÕES E IDIOMA
# ==================================================
log_step "CARREGANDO CONFIGURAÇÕES"

# Primeiro carregar traduções para poder exibir mensagens
load_ui_strings "${CURRENT_LANG:-pt_BR}"

# Agora carregar configurações (sem exibição de resumo)
load_config
debug_log "Configurações carregadas"

# ==================================================
# VERIFICAÇÕES INICIAIS
# ==================================================
log_step "VERIFICANDO DEPENDÊNCIAS"
if ! check_dependencies; then
    fmt_error "Dependências essenciais faltando. Abortando." >&2
    exit 1
else
    debug_log "Dependências verificadas com sucesso"
fi

log_step "VERIFICANDO SPOTDL"
if ! check_spotdl; then
    fmt_error "Falha ao verificar spotDL. Abortando." >&2
    exit 1
else
    debug_log "SpotDL verificado: $SPOTDL_CMD"
    spotdl_version=$("$SPOTDL_CMD" --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "N/A")
    debug_log "Versão SpotDL: $spotdl_version"
fi

# ==================================================
# FUNÇÃO DE PAUSA NO DEBUG
# ==================================================
debug_pause() {
    if [ "$DEBUG" = true ]; then
        # imprime separador e mensagem direto no terminal
        printf "\n========================================\n"
        printf "\033[1;36mPressione Enter para continuar...\033[0m\n"
        printf "========================================\n"
        # lê diretamente do terminal interativo
        while true; do
            read -r -n 1 key </dev/tty
            break
        done
    fi
}



# ==================================================
# EXECUÇÃO PRINCIPAL (MODO DEBUG)
# ==================================================
log_step "INICIANDO APLICAÇÃO"
debug_log "Versão DEBUG ativa"
debug_log "Configurações atuais:"
debug_log "  Idioma: $CURRENT_LANG"
debug_log "  Diretório downloads: $FINAL_DIR"
debug_log "  Template: $OUTPUT_STRUCTURE"
debug_log "  Formato: ${EDITABLE_CONFIG[format]}"
debug_log "  Bitrate: ${EDITABLE_CONFIG[bitrate]}"
debug_log "  Threads: ${EDITABLE_CONFIG[threads]}"
debug_log "  Gerar letras: ${EDITABLE_CONFIG[generate_lrc]}"
debug_log "  Pular capa: ${EDITABLE_CONFIG[skip_album_art]}"
debug_log "  Sincronizar sem deletar: ${EDITABLE_CONFIG[sync_without_deleting]}"
debug_log "  Remover LRC na sincronização: ${EDITABLE_CONFIG[sync_remove_lrc]}"
debug_log "  Sobrescrita: ${EDITABLE_CONFIG[overwrite]}"
debug_log "  Sem cache: ${EDITABLE_CONFIG[no_cache]}"
debug_log "  Máximo de backups: $MAX_BACKUPS"

if [ "$DEBUG" = true ]; then
    newline
    fmt_separator
    fmt_info "$(format_text "MODO DEBUG ATIVADO" bright_white bold)"
    fmt_separator
    newline

    # teste isolado de pausa
    echo ">>> DEBUG: aguardando ENTER (teste isolado)"
    read -r _ < /dev/tty
    echo ">>> DEBUG: ENTER recebido, continuando..."
fi

update_spotdl
main_menu
