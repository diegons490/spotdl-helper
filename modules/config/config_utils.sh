#!/bin/bash
# modules/config_utils.sh
# Funções utilitárias e de suporte para o gerenciamento de configurações.

# Função principal para carregar configurações
load_config() {
    load_helper_config
    if [[ ! -f "$SPOTDL_CONFIG_PATH" ]]; then
        save_spotdl_config
    fi
    load_spotdl_config
    load_ui_strings "$CURRENT_LANG"
}

# Funções de suporte para templates de saída
get_current_template() {
    if [[ -f "$SPOTDL_CONFIG_PATH" ]]; then
        jq -r '.output' "$SPOTDL_CONFIG_PATH" 2>/dev/null
    else
        echo "${FINAL_DIR}/${OUTPUT_STRUCTURE}"
    fi
}

get_template_display_name() {
    case "$OUTPUT_STRUCTURE" in
        "{artist}/{album}/{title}.{output-ext}")
            echo "$(get_msg config_output_template_1)"
            ;;
        "{artist}/{title}.{output-ext}")
            echo "$(get_msg config_output_template_2)"
            ;;
        "{title}.{output-ext}")
            echo "$(get_msg config_output_template_3)"
            ;;
        *)
            echo "$OUTPUT_STRUCTURE"
            ;;
    esac
}

# Salva todas as configurações
save_all_config() {
    save_helper_config
    fmt_success "$(get_msg config_all_saved)"
    sleep 1
}

# Recarrega e exibe todas as configurações da aplicação
reload_application_config() {
    load_helper_config
    load_spotdl_config
    load_ui_strings "$CURRENT_LANG"

    OVERWRITE_MODE="${EDITABLE_CONFIG[overwrite]}"
    THREADS="${EDITABLE_CONFIG[threads]}"
    GENERATE_LRC="${EDITABLE_CONFIG[generate_lrc]}"
    SYNC_WITHOUT_DELETING="${EDITABLE_CONFIG[sync_without_deleting]}"
    NO_CACHE="${EDITABLE_CONFIG[no_cache]}"

    fmt_section "$(get_msg loaded_config)\n"

    local config_items=(
        "label_language|$CURRENT_LANG"
        "label_download_path|$FINAL_DIR"
        "config_output_template|$OUTPUT_STRUCTURE"
        "format|${EDITABLE_CONFIG[format]}"
        "bitrate|${EDITABLE_CONFIG[bitrate]}"
        "overwrite|${EDITABLE_CONFIG[overwrite]}"
        "threads|${EDITABLE_CONFIG[threads]}"
        "generate_lrc|${EDITABLE_CONFIG[generate_lrc]}"
        "skip_album_art|${EDITABLE_CONFIG[skip_album_art]}"
        "sync_without_deleting|${EDITABLE_CONFIG[sync_without_deleting]}"
        "sync_remove_lrc|${EDITABLE_CONFIG[sync_remove_lrc]}"
        "no_cache|${EDITABLE_CONFIG[no_cache]}"
        "label_max_backups|$MAX_BACKUPS"
        "label_lyrics_providers|$(format_lyrics_providers_display)"
    )
    

    for item in "${config_items[@]}"; do
        IFS='|' read -r key value <<< "$item"
        fmt_config_detail "$(get_msg "$key")" "$value"
    done

    fmt_prompt "\n$(get_msg press_enter_continue)"
    read -r
}

# Função genérica para opções enumeradas
handle_enumerated_option() {
    local kept_message="$1"
    local current_value="$2"
    local -n valid_options_ref="$3"
    local success_message="$4"
    local prompt_msg="$5"
    local warning_msg="${6:-}"

    while true; do
        clear
        fmt_header "$(get_msg menu_option5)"

        if [[ -n "$warning_msg" ]]; then
            fmt_warning "$warning_msg"
        fi

        fmt_info "$prompt_msg"
        fmt_info "$(get_msg current_value): $current_value"

        for i in "${!valid_options_ref[@]}"; do
            local marker="[ ]"
            [[ "${valid_options_ref[$i]}" == "$current_value" ]] && marker="[x]"
            fmt_option "$((i+1))" "$marker ${valid_options_ref[$i]}"
        done

        newline
        fmt_option "0" "$(get_msg menu_return)"
        newline
        fmt_prompt "$(get_msg choose_option) (0-${#valid_options_ref[@]})"
        read -n 1 -r input
        echo

        if [[ "$input" == "0" ]]; then
            return 0
        fi

        if [[ -z "$input" ]]; then
            fmt_warning "$(printf "$kept_message" "$current_value")"
            echo "$current_value"
            return
        fi

        if [[ "$input" =~ ^[1-9]$ ]]; then
            local selected_index=$((input-1))
            if (( selected_index < ${#valid_options_ref[@]} )); then
                fmt_success "$(printf "$success_message" "${valid_options_ref[$selected_index]}")"
                echo "${valid_options_ref[$selected_index]}"
                return
            fi
        fi

        fmt_error "$(get_msg invalid_option)"
        sleep 1.5
    done
}

# Abre arquivos de configuração manualmente com editor
open_manual_config() {
    local config_type="$1"
    local config_path=""
    local config_name=""

    case "$config_type" in
        "spotdl")
            config_path="$SPOTDL_CONFIG_PATH"
            config_name="spotDL"
            ;;
        "helper")
            config_path="$HELPER_CONFIG_PATH"
            config_name="Helper"
            ;;
        *)
            fmt_error "$(get_msg "invalid_config_type")"
            return 1
            ;;
    esac

    if [[ ! -f "$config_path" ]]; then
        newline
        fmt_error "$(printf "$(get_msg "config_file_not_found")" "$config_name" "$config_path")"
        newline
        fmt_prompt "$(get_msg "press_enter_continue")"
        read -r
        return 1
    fi

    local backup_file="/tmp/backup_${config_name}_$(date +%s).json"
    cp "$config_path" "$backup_file"

    clear
    fmt_header "$(printf "$(get_msg "opening_config")" "$config_name")"
    fmt_info "$(get_msg "config_location"): $config_path"

    local editor="nano"
    local valid_editor=false
    
    while [[ "$valid_editor" == false ]]; do
        newline
        fmt_warning "$(get_msg "press_enter_nano")"
        newline
        fmt_prompt "$(get_msg "inform_editor")"
        read -r user_editor

        if [[ "$user_editor" == "0" ]]; then
            rm -f "$backup_file"
            return
        fi

        if [[ -n "$user_editor" ]]; then
            editor="$user_editor"
        fi

        if command -v "$editor" &>/dev/null; then
            valid_editor=true
        else
            clear
            fmt_header "$(printf "$(get_msg "opening_config")" "$config_name")"
            fmt_info "$(get_msg "config_location"): $config_path"
            newline
            fmt_error "$(printf "$(get_msg "editor_not_found_fmt")" "$editor")"
        fi
    done

    "$editor" "$config_path"

    clear
    fmt_header "$(printf "$(get_msg "config_after_edit")" "$config_name")"

    local diff_output
    if command -v colordiff &>/dev/null; then
        diff_output=$(colordiff -u "$backup_file" "$config_path" | grep -vE '^(---|\+\+\+|@@)')
    else
        diff_output=$(diff -u "$backup_file" "$config_path" | grep -vE '^(---|\+\+\+|@@)')
    fi

    if [[ -n "$diff_output" ]]; then
        echo -e "$(get_msg "diff_changes"):\n"
        while IFS= read -r line; do
            if [[ $line == -* ]]; then
                fmt_error "$line"
            elif [[ $line == +* ]]; then
                fmt_success "$line"
            else
                echo "$line"
            fi
        done <<< "$diff_output"
    else
        fmt_info "$(get_msg "no_changes_detected")"
    fi

    newline
    fmt_prompt "$(get_msg "press_enter_continue")"
    read -r

    rm -f "$backup_file"
    clear
    reload_application_config
}

# Adicione esta função no arquivo:

# Função para formatar a exibição dos provedores de letras
format_lyrics_providers_display() {
    if [ ${#CURRENT_LYRIC_PROVIDERS[@]} -eq 0 ]; then
        echo "$(get_msg lyrics_providers_none)"
    else
        local display_list=""
        for provider in "${CURRENT_LYRIC_PROVIDERS[@]}"; do
            case $provider in
                "genius") display_list+="$(get_msg lyrics_provider_genius), " ;;
                "azlyrics") display_list+="$(get_msg lyrics_provider_azlyrics), " ;;
                "musixmatch") display_list+="$(get_msg lyrics_provider_musixmatch), " ;;
            esac
        done
        echo "${display_list%, }"
    fi
}