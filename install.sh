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
echo "2) Visual Studio Code"
echo "3) WhatsApp Desktop"
echo "0) Keluar"
echo ""
read -p "Masukkan nomor pilihan: " OPTION

# ---------- ROOT CHECK ----------
if [[ $EUID -ne 0 ]]; then
  echo ""
  echo "❌ Jalankan script ini dengan sudo"
  exit 1
fi

# ---------- GOOGLE CHROME ----------
install_chrome() {
  echo "🔄 Update repository..."
  apt update -y

  echo "📦 Install dependency..."
  apt install -y wget gdebi-core

  echo "⬇️ Download Google Chrome..."
  wget -q -O /tmp/google-chrome.deb \
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

  echo "🚀 Install Google Chrome..."
  gdebi -n /tmp/google-chrome.deb

  DESKTOP_FILE="/usr/share/applications/google-chrome.desktop"
  add_to_desktop "$DESKTOP_FILE"

  echo "🎉 Google Chrome berhasil diinstall!"
}

# ---------- VISUAL STUDIO CODE ----------
install_vscode() {
  echo "🔄 Update repository..."
  apt update -y

  echo "📦 Install dependency..."
  apt install -y wget gpg

  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg

  echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" \
  > /etc/apt/sources.list.d/vscode.list

  apt update -y
  apt install -y code

  DESKTOP_FILE="/usr/share/applications/code.desktop"
  add_to_desktop "$DESKTOP_FILE"

  echo "🎉 Visual Studio Code berhasil diinstall!"
}

# ---------- WHATSAPP DESKTOP ----------
install_whatsapp() {
  echo "🔄 Update repository..."
  apt update -y

  echo "📦 Install Flatpak..."
  apt install -y flatpak

  echo "➕ Menambahkan Flathub repo..."
  flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

  echo "⬇️ Install WhatsApp Desktop..."
  flatpak install -y flathub com.github.eneshecan.WhatsAppForLinux

  DESKTOP_FILE="/var/lib/flatpak/exports/share/applications/com.github.eneshecan.WhatsAppForLinux.desktop"

  if [[ -f "$DESKTOP_FILE" ]]; then
    add_to_desktop "$DESKTOP_FILE"
  fi

  echo "🎉 WhatsApp Desktop berhasil diinstall!"
}

# ---------- ADD ICON TO DESKTOP (COMMON FUNCTION) ----------
add_to_desktop() {
  local DESKTOP_FILE="$1"

  echo "🖥️ Menambahkan icon ke Desktop..."
  for USER_HOME in /home/*; do
    DESKTOP_DIR="$USER_HOME/Desktop"
    if [[ -d "$DESKTOP_DIR" ]]; then
      cp "$DESKTOP_FILE" "$DESKTOP_DIR/"
      chown $(basename "$USER_HOME"):$(basename "$USER_HOME") \
        "$DESKTOP_DIR/$(basename "$DESKTOP_FILE")"
      chmod +x "$DESKTOP_DIR/$(basename "$DESKTOP_FILE")"
    fi
  done
}

# ---------- MENU ----------
case $OPTION in
  1)
    install_chrome
    ;;
  2)
    install_vscode
    ;;
  3)
    install_whatsapp
    ;;
  0)
    echo "👋 Keluar..."
    exit 0
    ;;
  *)
    echo "❌ Pilihan tidak valid"
    ;;
esac
