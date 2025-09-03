# 🎵 SpotDL Helper

An interactive Bash interface to simplify the use of [spotDL](https://github.com/spotDL/spotify-downloader), a powerful tool to download Spotify songs, albums, and playlists (using external sources like YouTube).

> ⚠️ SpotDL Helper **does not download directly from Spotify**. It uses Spotify metadata (track name, artist, album, cover art, etc.) and downloads the audio from platforms like YouTube.

---

## 📌 What is SpotDL Helper?

SpotDL Helper is a **command-line (CLI) frontend** that makes using spotDL easier through menus, shortcuts, and configurable options. It’s ideal for users who prefer convenience and don’t want to memorize long commands.

---

## 🎬 Preview

![screenshot](/preview.png?raw=true)

---

## 🚀 Features

- 🔹 **Download songs, albums, and playlists** by simply pasting a Spotify link.
- 🔹 **Manage multiple links** in one session.
- 🔹 **Set a default download directory**.
- 🔹 **Automatically detect and install spotDL** if needed.
- 🔹 **Update spotDL** with automatic backup of the previous binary.
- 🔹 **Restore previous spotDL versions** from backup.
- 🔹 **Limit the number of stored backups**.
- 🔹 **Compatible with multiple terminals** (Konsole, GNOME Terminal, Xfce Terminal, etc.).
- 🔹 **Multilingual support**: Portuguese (pt_BR), English (en_US), Spanish (es_ES).

---

## 📁 Project Structure

```
. 📂 spotdl-helper
├── 📄 README.md
└── 📂 bin/
│  ├── 📄 spotdl-4.4.2-linux
└── 📂 bkp_spotdl/
│  ├── 📄 spotdl-4.4.1-linux
└── 📂 icons/
│  ├── 📄 spotdl-helper.icon
├── 📄 install.sh
└── 📂 lang/
│  ├── 📄 en_US.lang
│  ├── 📄 es_ES.lang
│  ├── 📄 pt_BR.lang
├── 📄 launcher.sh
├── 📄 main.sh
└── 📂 modules/
│  └── 📂 config/
│    ├── 📄 _load.sh
│    ├── 📄 config_edit_options.sh
│    ├── 📄 config_env.sh
│    ├── 📄 config_helper.sh
│    ├── 📄 config_spotdl.sh
│    ├── 📄 config_utils.sh
│  ├── 📄 dependencies.sh
│  └── 📂 download/
│    ├── 📄 _load.sh
│    ├── 📄 config_vars.sh
│    ├── 📄 download_artist_albums.sh
│    ├── 📄 download_music.sh
│    ├── 📄 download_playlists.sh
│    ├── 📄 reload_config.sh
│    ├── 📄 run_spotdl.sh
│    ├── 📄 sync_files.sh
│    ├── 📄 validate_links.sh
│  └── 📂 formatting/
│    ├── 📄 _load.sh
│    ├── 📄 colors.sh
│    ├── 📄 commands.sh
│    ├── 📄 config.sh
│    ├── 📄 core.sh
│    ├── 📄 demo.sh
│    ├── 📄 interactive.sh
│    ├── 📄 messages.sh
│    ├── 📄 messages_emoji.sh
│    ├── 📄 quicktest.sh
│    ├── 📄 styles.sh
│    ├── 📄 test.sh
│    ├── 📄 visuals.sh
│  └── 📂 manage_spotdl/
│    ├── 📄 _load.sh
│    ├── 📄 check_spotdl.sh
│    ├── 📄 get_backup_limit.sh
│    ├── 📄 manage_backups.sh
│    ├── 📄 manage_spotdl_vars.sh
│    ├── 📄 restore_backup.sh
│    ├── 📄 update_spotdl.sh
│  ├── 📄 menu.sh
│  ├── 📄 ui_prompts.sh
│  ├── 📄 utils.sh
├── 📄 preview.png
└── 📄 uninstall.sh
```

---
## 🛠️ How to Install

### Recommended: Install via terminal (one-liner)

You can install SpotDL Helper directly from the terminal using the official installation script hosted on GitHub:

### With curl:
```bash
curl -fsSL https://raw.githubusercontent.com/diegons490/spotdl-helper/main/install.sh | bash
```
### Or with wget:
```
wget -qO- https://raw.githubusercontent.com/diegons490/spotdl-helper/main/install.sh | bash
```
### Alternative: Manual installation from GitHub repository:
##### If you prefer, you can clone the repository and run the installer script manually:
```
git clone https://github.com/diegons490/spotdl-helper
cd spotdl-helper
chmod +x install.sh
./install.sh
```
---

## 📦 Requirements

- `bash`
- `ffmpeg`
- `jq`
- `wget` or `curl`
- A supported terminal (`konsole`, `gnome-terminal`, `xfce4-terminal`, etc.)

> All requirements are checked automatically, and spotDL will be downloaded if not found.

---

> ⚠️ **Important Notice:**  
> This version uses the **local version** of the application, so it is **not compatible** with versions installed in other ways (e.g., system-wide installs via pip, package managers, Snap, etc.).

---

## 🧩 Credits

This project is just a helper interface for the excellent:

### ➤ [spotDL – spotify-downloader](https://github.com/spotDL/spotify-downloader)

> spotDL is maintained by [@spotDL](https://github.com/spotDL) and its community.  
>  
> Licensed under the MIT License.

---

## 🛠️ License

This project is licensed under the [MIT License](LICENSE).

---

## 📣 Contributions

Contributions are welcome! Feel free to open issues, submit pull requests, or suggest improvements.

---

*Crafted with care by [Diego N.S.](https://github.com/diegons490) — a helper for those who just want to enjoy their music effortlessly.*
