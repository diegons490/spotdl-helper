#!/bin/bash
# modules/download/validate_links.sh
# Validações de links

is_valid_track_link() {
	[[ "$1" =~ open.spotify.com/track/ ]]
}

is_valid_album_link() {
	[[ "$1" =~ open.spotify.com/album/ ]]
}

is_valid_playlist_link() {
	[[ "$1" =~ open.spotify.com/playlist/ ]]
}

is_valid_artist_link() {
	[[ "$1" =~ open.spotify.com/artist/ ]]
}
