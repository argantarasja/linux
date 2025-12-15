#!/bin/bash

# Menjalankan script dengan opsi berhenti saat error
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
echo "0) Keluar"
echo ""
read -p "Masukkan nomor pilihan: " OPTION

# Cek apakah script dijalankan sebagai root (menggunakan sudo)
if [[ $EUID -ne 0 ]]; then
  echo ""
  echo "❌ Jalankan script ini dengan sudo"
  exit 1
fi

# Fungsi untuk install Google Chrome
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

# Fungsi untuk install Visual Studio Code (VS Code)
install_vscode() {
  echo ""
  echo "🔄 Update repository..."
  apt update -y

  echo "📦 Install dependency..."
  apt install -y wget gpg

  echo "⬇️  Download dan install Microsoft GPG key..."
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft-archive-keyring.gpg

  echo "⬇️  Menambahkan repository VS Code..."
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list

  echo "🔄 Update repository untuk VS Code..."
  apt update -y

  echo "📦 Install Visual Studio Code..."
  apt install -y code

  DESKTOP_FILE="/usr/share/applications/code.desktop"

  if [[ -f "$DESKTOP_FILE" ]]; then
    echo "🖥️  Menambahkan icon VS Code ke Desktop..."
    for USER_HOME in /home/*; do
      DESKTOP_DIR="$USER_HOME/Desktop"
      if [[ -d "$DESKTOP_DIR" ]]; then
        cp "$DESKTOP_FILE" "$DESKTOP_DIR/"
        chown $(basename "$USER_HOME"):$(basename "$USER_HOME") \
          "$DESKTOP_DIR/code.desktop"
        chmod +x "$DESKTOP_DIR/code.desktop"
      fi
    done
  fi

  echo ""
  echo "🎉 Visual Studio Code berhasil diinstall!"
}

# Menu pemilihan dan eksekusi berdasarkan pilihan
case $OPTION in
  1)
    install_chrome
    ;;
  2)
    install_vscode
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
