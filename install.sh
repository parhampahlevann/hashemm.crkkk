#!/usr/bin/env bash
#
# Hashem v3.0.0 Pro Local - Automatic Installer
# Download + Extract + Install + Run in one step
#

set -euo pipefail

# ---------- Settings ----------
VERSION="v3.0.0"
ARCHIVE="Hashem-${VERSION}-Pro-Local-amd64"
DOWNLOAD_URL="https://github.com/parhampahlevann/hashemm.crkkk/releases/download/${VERSION}/${ARCHIVE}.zip"

# Temporary directory (cleaned up automatically)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "=========================================="
echo "  Installing $ARCHIVE"
echo "=========================================="

# ---------- 1) Download ----------
echo "[1/4] Downloading $ARCHIVE.zip ..."
if command -v curl &>/dev/null; then
    curl -fL --retry 3 --progress-bar \
         -o "$TMP_DIR/$ARCHIVE.zip" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
    wget -O "$TMP_DIR/$ARCHIVE.zip" "$DOWNLOAD_URL"
else
    echo "ERROR: neither curl nor wget is installed." >&2
    echo "Install one first: sudo apt install curl" >&2
    exit 1
fi
echo "OK Download complete."

# ---------- 2) Extract ----------
echo "[2/4] Extracting archive ..."
command -v unzip &>/dev/null || { echo "ERROR: unzip is not installed: sudo apt install unzip" >&2; exit 1; }
unzip -q "$TMP_DIR/$ARCHIVE.zip" -d "$TMP_DIR"
echo "OK Extraction complete."

# ---------- 3) Install ----------
cd "$TMP_DIR/$ARCHIVE"
echo "[3/4] Running installer (root required) ..."
if [[ $EUID -eq 0 ]]; then
    bash install.sh
else
    sudo bash install.sh
fi
echo "OK Installation complete."

# ---------- 4) Run ----------
echo "[4/4] Launching Hashem ..."
# Adjust the binary name below if install.sh installs it under a different name
if command -v hashem &>/dev/null; then
    exec hashem
elif [[ -x /usr/local/bin/hashem ]]; then
    exec /usr/local/bin/hashem
elif [[ -x ./hashem ]]; then
    exec ./hashem
else
    echo "WARNING: Installed, but the binary name could not be detected."
    echo "Listing extracted files - update the exec lines above accordingly:"
    ls -la
fi
