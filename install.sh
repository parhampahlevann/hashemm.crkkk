#!/usr/bin/env bash

set -e

URL="https://github.com/parhampahlevann/hashemm.crkkk/releases/download/v3.0.0/Hashem-v3.0.0-Pro-Local-amd64.zip"
ZIP_FILE="Hashem-v3.0.0-Pro-Local-amd64.zip"
EXTRACT_DIR="Hashem-v3.0.0-Pro-Local-amd64"
# استفاده از مسیر داخل /root برای جلوگیری از خطای noexec در پارتیشن /tmp برخی سرورها
WORK_DIR="/root/.hashem_installer_$$"

# ۱. بررسی دسترسی روت
if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run this script as root or with sudo."
    exit 1
fi

# ۲. بررسی و نصب پیش‌نیازها
echo "[*] Checking dependencies..."
for pkg in curl unzip; do
    if ! command -v "$pkg" &> /dev/null; then
        echo "[*] Installing $pkg..."
        apt-get update -qq && apt-get install -y -qq "$pkg"
    fi
done

# ۳. ساخت پوشه کاری
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# ۴. دانلود فایل فشرده
echo "[*] Downloading $ZIP_FILE..."
curl -L --fail --progress-bar -o "$ZIP_FILE" "$URL"

# ۵. استخراج فایل
echo "[*] Extracting archive..."
unzip -q -o "$ZIP_FILE"

# ۶. ورود به پوشه استخراج شده
if [ -d "$EXTRACT_DIR" ]; then
    cd "$EXTRACT_DIR"
elif [ -f "install.sh" ]; then
    echo "[*] Found files in current directory..."
else
    echo "[-] Error: install.sh not found after extraction."
    rm -rf "$WORK_DIR"
    exit 1
fi

# ۷. اعطای دسترسی اجرایی به تمام باینری‌ها و اسکریپت‌ها (رفع خطای Permission denied)
echo "[*] Fixing permissions for binaries and scripts..."
chmod -R +x .

# ۸. اجرای نصب‌کننده اصلی
echo "[*] Running installer..."
bash install.sh

# ۹. پاکسازی فایل‌های موقت
echo "[*] Cleaning up temporary files..."
rm -rf "$WORK_DIR"

echo "[+] Installation completed successfully!"
