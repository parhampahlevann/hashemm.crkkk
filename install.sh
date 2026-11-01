#!/usr/bin/env bash

# توقف اسکریپت در صورت بروز هرگونه خطا
set -e

URL="https://github.com/parhampahlevann/hashemm.crkkk/releases/download/v3.0.0/Hashem-v3.0.0-Pro-Local-amd64.zip"
ZIP_FILE="Hashem-v3.0.0-Pro-Local-amd64.zip"
EXTRACT_DIR="Hashem-v3.0.0-Pro-Local-amd64"
WORK_DIR="/tmp/hashem_installer_$$"

# ۱. بررسی دسترسی روت
if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run this script as root or with sudo."
    exit 1
fi

# ۲. بررسی و نصب پیش‌نیازها (unzip و curl)
echo "[*] Checking dependencies..."
for pkg in curl unzip; do
    if ! command -v "$pkg" &> /dev/null; then
        echo "[*] Installing $pkg..."
        apt-get update -qq && apt-get install -y -qq "$pkg"
    fi
done

# ۳. ساخت پوشه موقت برای دانلود و استخراج تمیز
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# ۴. دانلود فایل فشرده
echo "[*] Downloading $ZIP_FILE..."
curl -L --fail --progress-bar -o "$ZIP_FILE" "$URL"

# ۵. استخراج فایل
echo "[*] Extracting archive..."
unzip -q -o "$ZIP_FILE"

# ۶. ورود به پوشه و اجرای نصب‌کننده اصلی
if [ -d "$EXTRACT_DIR" ]; then
    cd "$EXTRACT_DIR"
elif [ -f "install.sh" ]; then
    # در صورتی که فایل‌ها بدون پوشه والد مستقیماً استخراج شده باشند
    echo "[*] Found install.sh in current directory..."
else
    echo "[-] Error: Directory $EXTRACT_DIR or install.sh not found after extraction."
    rm -rf "$WORK_DIR"
    exit 1
fi

echo "[*] Running installer..."
chmod +x install.sh
bash install.sh

# ۷. پاکسازی فایل‌های موقت دانلود شده
echo "[*] Cleaning up temporary files..."
rm -rf "$WORK_DIR"

echo "[+] Installation completed successfully!"
