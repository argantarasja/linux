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
echo "2) Software Lain (Coming Soon)"
echo "0) Keluar"
echo ""
read -p "Masukkan nomor pilihan: " OPTION

# Cek root
if [[ $EUID -ne 0 ]]; then
  echo ""
  echo "❌ Jalankan script ini dengan sudo"
  exit 1
fi

install_chrome() {
  echo ""
  echo "🔄 Update repository..."
  apt update -y

  echo "📦 Install dependency..."
  apt install -y wget gdebi-core

  echo "⬇️  Download Google Chrome..."
  wget -q -O /tmp/google-chrome.deb \
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

  echo "🚀 Install Google Chrome..."
  gdebi -n /tmp/google-chrome.deb

  DESKTOP_FILE="/usr/share/applications/google-chrome.desktop"

  if [[ -f "$DESKTOP_FILE" ]]; then
    echo "🖥️  Menambahkan icon ke Desktop..."
    for USER_HOME in /home/*; do
      DESKTOP_DIR="$USER_HOME/Desktop"
      if [[ -d "$DESKTOP_DIR" ]]; then
        cp "$DESKTOP_FILE" "$DESKTOP_DIR/"
        chown $(basename "$USER_HOME"):$(basename "$USER_HOME") \
          "$DESKTOP_DIR/google-chrome.desktop"
        chmod +x "$DESKTOP_DIR/google-chrome.desktop"
      fi
    done
  fi

  echo ""
  echo "🎉 Google Chrome berhasil diinstall!"
}

case $OPTION in
  1)
    install_chrome
    ;;
  2)
    echo ""
    echo "⚠️  Software ini masih Coming Soon"
    ;;
  0)
    echo ""
    echo "👋 Keluar..."
    exit 0
    ;;
  *)
    echo ""
    echo "❌ Pilihan tidak valid"
    ;;
esac
