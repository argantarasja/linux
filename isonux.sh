#!/bin/bash
set -e

clear
echo "========================================"
echo "        Linux Software Auto Installer   "
echo "========================================"
echo ""
echo "Pilih software yang ingin diinstall:"
echo ""
echo "1) Google Chrome"
echo "2) Instagram"
echo "3) Telegram Desktop"
echo "4) TikTok"
echo "5) Visual Studio Code"
echo "6) WhatsApp Desktop"
echo "7) YouTube"
echo "0) Keluar"
echo ""
read -p "Masukkan nomor pilihan: " OPTION

# ---------- ROOT CHECK ----------
if [[ $EUID -ne 0 ]]; then
  echo "❌ Jalankan script ini dengan sudo"
  exit 1
fi

# ---------- COMMON FUNCTION ----------
add_to_desktop() {
  local FILE="$1"
  for USER_HOME in /home/*; do
    DESKTOP="$USER_HOME/Desktop"
    if [[ -d "$DESKTOP" ]]; then
      cp "$FILE" "$DESKTOP/"
      chown $(basename "$USER_HOME"):$(basename "$USER_HOME") "$DESKTOP/$(basename "$FILE")"
      chmod +x "$DESKTOP/$(basename "$FILE")"
    fi
  done
}

# ---------- GOOGLE CHROME ----------
install_chrome() {
  apt update -y
  apt install -y wget gdebi-core
  wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  gdebi -n /tmp/chrome.deb
  add_to_desktop /usr/share/applications/google-chrome.desktop
  echo "🎉 Google Chrome berhasil diinstall!"
}

# ---------- WEB APP FUNCTION ----------
install_webapp() {
  NAME="$1"
  URL="$2"
  ICON_PATH="$3"

  DESKTOP_FILE="/usr/share/applications/$NAME.desktop"

  cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$NAME
Exec=google-chrome --app=$URL
Icon=$ICON_PATH
Type=Application
Categories=Network;
EOF

  add_to_desktop "$DESKTOP_FILE"
  echo "🎉 $NAME berhasil ditambahkan ke Desktop dengan icon custom"
}

# ---------- INSTAGRAM ----------
install_instagram() {
  wget -qO /usr/share/icons/instagram.png https://upload.wikimedia.org/wikipedia/commons/e/e7/Instagram_logo_2016.svg
  install_webapp "Instagram" "https://www.instagram.com" "/usr/share/icons/instagram.png"
}

# ---------- YOUTUBE ----------
install_youtube() {
  wget -qO /usr/share/icons/youtube.png https://upload.wikimedia.org/wikipedia/commons/b/b8/YouTube_Logo_2017.svg
  install_webapp "YouTube" "https://www.youtube.com" "/usr/share/icons/youtube.png"
}

# ---------- TIKTOK ----------
install_tiktok() {
  wget -qO /usr/share/icons/tiktok.png https://upload.wikimedia.org/wikipedia/en/a/a9/TikTok_logo.svg
  install_webapp "TikTok" "https://www.tiktok.com" "/usr/share/icons/tiktok.png"
}

# ---------- TELEGRAM ----------
install_telegram() {
  apt update -y
  apt install -y flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub org.telegram.desktop

  DESKTOP_FILE="/var/lib/flatpak/exports/share/applications/org.telegram.desktop"
  [[ -f "$DESKTOP_FILE" ]] && add_to_desktop "$DESKTOP_FILE"
  echo "🎉 Telegram Desktop berhasil diinstall!"
}

# ---------- VSCODE ----------
install_vscode() {
  apt update -y
  apt install -y wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
  apt update -y
  apt install -y code
  add_to_desktop /usr/share/applications/code.desktop
  echo "🎉 Visual Studio Code berhasil diinstall!"
}

# ---------- WHATSAPP ----------
install_whatsapp() {
  apt update -y
  apt install -y flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.github.eneshecan.WhatsAppForLinux

  DESKTOP_FILE="/var/lib/flatpak/exports/share/applications/com.github.eneshecan.WhatsAppForLinux.desktop"
  [[ -f "$DESKTOP_FILE" ]] && add_to_desktop "$DESKTOP_FILE"
  echo "🎉 WhatsApp Desktop berhasil diinstall!"
}

# ---------- MENU ----------
case $OPTION in
  1) install_chrome ;;
  2) install_instagram ;;
  3) install_telegram ;;
  4) install_tiktok ;;
  5) install_vscode ;;
  6) install_whatsapp ;;
  7) install_youtube ;;
  0) echo "👋 Keluar..." ;;
  *) echo "❌ Pilihan tidak valid" ;;
esac
