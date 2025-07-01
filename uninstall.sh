#!/bin/bash
set -euo pipefail

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"
BOLD="\033[1m"

printf "${BOLD}${CYAN}Starting SpotDL Helper uninstallation...${RESET}\n"

# Main directories
INSTALL_DIR="$HOME/.local/share/spotdl-helper"
BIN_LINK="$HOME/.local/bin/spotdl-helper"
DESKTOP_FILE="$HOME/.local/share/applications/spotdl-helper.desktop"
CONFIG_DIR="$HOME/.config/spotdl-helper"
SPOTDL_DIR="$HOME/.spotdl"
SPOTDL_HELPER_DIR="$HOME/.spotdl-helper"
LOG_DIR="$HOME/.local/share/spotdl-helper/logs"

# Accept -y for auto-confirmation
AUTO_YES=false
if [[ "${1:-}" == "-y" ]]; then
    AUTO_YES=true
fi

# Uninstallation confirmation
if ! $AUTO_YES; then
    read -rp "Are you sure you want to completely remove SpotDL Helper? (y/N): " answer
    answer=${answer,,}
    if [[ "$answer" != "s" && "$answer" != "y" ]]; then
        printf "${YELLOW}Operation canceled.${RESET}\n"
        exit 0
    fi
fi

# Function to log removal with details
log_removal() {
    local path="$1"
    local type="$2"

    if [[ -e "$path" ]]; then
        if [[ -f "$path" ]]; then
            printf "${GREEN}Removed file:${RESET} %s (Size: %s, Type: %s)\n" \
                   "$path" "$(du -h "$path" | cut -f1)" "$type"
        elif [[ -d "$path" ]]; then
            printf "${GREEN}Removed directory:${RESET} %s (Contents: %d items, Type: %s)\n" \
                   "$path" "$(find "$path" | wc -l)" "$type"
        fi
        return 0
    else
        printf "${YELLOW}Not found:${RESET} %s (Type: %s)\n" "$path" "$type"
        return 1
    fi
}

# Component removal
removed=0

# 1. Remove desktop shortcut
if [[ -f "$DESKTOP_FILE" ]] || [[ -L "$DESKTOP_FILE" ]]; then
    rm -f "$DESKTOP_FILE" && log_removal "$DESKTOP_FILE" "Desktop shortcut" && ((removed++))
    # Update desktop database immediately
    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$HOME/.local/share/applications" &>/dev/null
        printf "${CYAN}Desktop database updated.${RESET}\n"
    fi
fi

# 2. Remove symbolic link
if [[ -L "$BIN_LINK" ]] || [[ -f "$BIN_LINK" ]]; then
    rm -f "$BIN_LINK" && log_removal "$BIN_LINK" "Binary link" && ((removed++))
fi

# 3. Remove main installation directory (with detailed logging)
if [[ -d "$INSTALL_DIR" ]]; then
    printf "\n${CYAN}Removing installation directory:${RESET}\n"
    # Log contents before removal
    find "$INSTALL_DIR" -type f -exec echo "  Found file: {}" \;
    find "$INSTALL_DIR" -type d -exec echo "  Found dir: {}" \;

    rm -rf "$INSTALL_DIR" && log_removal "$INSTALL_DIR" "Main installation" && ((removed++))
fi

# 4. Remove configuration files (with detailed logging)
if [[ -d "$CONFIG_DIR" ]]; then
    if $AUTO_YES; then
        printf "\n${CYAN}Removing configuration directory:${RESET}\n"
        find "$CONFIG_DIR" -type f -exec echo "  Config file: {}" \;
        rm -rf "$CONFIG_DIR" && log_removal "$CONFIG_DIR" "Configuration" && ((removed++))
    else
        read -rp "Do you want to remove ALL configuration files? (y/N): " cfg_answer
        cfg_answer=${cfg_answer,,}
        if [[ "$cfg_answer" == "s" || "$cfg_answer" == "y" ]]; then
            printf "\n${CYAN}Removing configuration directory:${RESET}\n"
            find "$CONFIG_DIR" -type f -exec echo "  Config file: {}" \;
            rm -rf "$CONFIG_DIR" && log_removal "$CONFIG_DIR" "Configuration" && ((removed++))
        else
            printf "${YELLOW}Configuration kept at:${RESET} %s\n" "$CONFIG_DIR"
            printf "Contents:\n"
            find "$CONFIG_DIR" -type f -exec echo "  {}" \;
        fi
    fi
fi

# 5. Remove additional SpotDL directories (with detailed logging)
if [[ -d "$SPOTDL_DIR" ]]; then
    printf "\n${CYAN}Removing SpotDL directory:${RESET}\n"
    find "$SPOTDL_DIR" -maxdepth 1 -type f -exec echo "  Found: {}" \;
    rm -rf "$SPOTDL_DIR" && log_removal "$SPOTDL_DIR" "SpotDL config" && ((removed++))
fi

if [[ -d "$SPOTDL_HELPER_DIR" ]]; then
    printf "\n${CYAN}Removing SpotDL Helper directory:${RESET}\n"
    find "$SPOTDL_HELPER_DIR" -maxdepth 1 -type f -exec echo "  Found: {}" \;
    rm -rf "$SPOTDL_HELPER_DIR" && log_removal "$SPOTDL_HELPER_DIR" "SpotDL Helper config" && ((removed++))
fi

# 6. Remove logs (with detailed logging)
if [[ -d "$LOG_DIR" ]]; then
    printf "\n${CYAN}Removing log directory:${RESET}\n"
    find "$LOG_DIR" -type f -name "*.log" -exec echo "  Log file: {}" \;
    rm -rf "$LOG_DIR" && log_removal "$LOG_DIR" "Logs" && ((removed++))
fi

# Final update of menu cache
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$HOME/.local/share/applications/" &>/dev/null
    printf "${CYAN}Final menu cache update completed.${RESET}\n"
fi

# Summary
if [[ $removed -gt 0 ]]; then
    printf "\n${BOLD}${GREEN}Uninstallation completed successfully!${RESET}\n"
    printf "${CYAN}Total components removed:${RESET} %d\n" $removed
else
    printf "\n${YELLOW}No SpotDL Helper components were found.${RESET}\n"
fi

printf "\n${CYAN}Thank you for using SpotDL Helper!${RESET}\n"
exit 0
