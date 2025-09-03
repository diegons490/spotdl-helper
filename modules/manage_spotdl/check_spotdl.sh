#!/bin/bash
# modules/manage_spotdl/check_spotdl.sh
# Função para verificar o spotDL

check_spotdl() {
	# Garante que BASE_DIR esteja definido
	if [[ -z "$BASE_DIR" ]]; then
		BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
	fi

	BIN_DIR="$BASE_DIR/bin"
	BKP_DIR="$BASE_DIR/bkp_spotdl"

	# Procura o binário mais recente no diretório bin/
	LOCAL_BINARY=$(ls "$BIN_DIR"/spotdl-*-linux 2>/dev/null | sort -V | tail -n1 || true)

	if [[ -x "$LOCAL_BINARY" ]]; then
		SPOTDL_CMD="$LOCAL_BINARY"
	else
		clear
		fmt_warning "$(get_msg no_local_spotdl)\n"

		if prompt_yes_no "$(get_msg download_latest_version)"; then
			newline
			fmt_info "$(get_msg downloading_latest)"

			local response
			response=$(curl -s -w "%{http_code}" -o /dev/null https://api.github.com/repos/spotDL/spotify-downloader/releases/latest)
			local status_code=${response: -3}

			if [[ "$status_code" != "200" ]]; then
				fmt_error "$(printf "$(get_msg github_api_error)" "$status_code")"
				fmt_warning "$(get_msg try_again_later)\n"
				sleep 5
				return 1
			fi

			LATEST_URL=$(curl -s https://api.github.com/repos/spotDL/spotify-downloader/releases/latest |
				jq -r '.assets[] | select(.name | test("spotdl-.*-linux")) | .browser_download_url' | head -n1)

			if [[ -z "$LATEST_URL" ]]; then
				fmt_error "$(get_msg could_not_find_link)\n"
				return 1
			fi

			mkdir -p "$BIN_DIR"
			DOWNLOADED_FILE="$BIN_DIR/$(basename "$LATEST_URL")"

			if ! curl -L -o "$DOWNLOADED_FILE" "$LATEST_URL"; then
				fmt_error "$(get_msg download_failed)\n"
				fmt_warning "$(get_msg check_connection_or_permissions)\n"
				rm -f "$DOWNLOADED_FILE" 2>/dev/null
				return 1
			fi

			if ! chmod +x "$DOWNLOADED_FILE"; then
				fmt_error "$(get_msg permission_error)\n"
				return 1
			fi

			SPOTDL_CMD="$DOWNLOADED_FILE"

			if DOWNLOADED_VERSION=$("$SPOTDL_CMD" --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'); then
				fmt_success "$(get_msg download_completed): $DOWNLOADED_VERSION\n"
			else
				fmt_warning "$(get_msg version_check_failed)\n"
			fi

			rm -f "$CONFIG_FILE"

			fmt_prompt "$(get_msg press_enter_continue)\n"
			read -n 1 -r -s
		else
			fmt_error "$(get_msg operation_canceled)! $(get_msg no_local_version_available)\n"
			sleep 2
			exit 1
		fi
	fi
}
