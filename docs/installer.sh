#!/bin/sh
# AudioShift one-line installer for DreamOS.
#
# wget -O - https://xfayez95.github.io/audioshift/installer.sh | sh

PLUGIN_NAME="AudioShift"
PKG_URL="https://github.com/xFayez95/audioshift/releases/latest/download/audioshift-dreamos.deb"
PKG_FILE="/tmp/audioshift-dreamos.deb"

NO_RESTART=0
for arg in "$@"; do
    case "$arg" in
        --watch|--no-restart) NO_RESTART=1 ;;
    esac
done

echo "Downloading ${PLUGIN_NAME}..."
rm -f "$PKG_FILE"
if command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate -q -O "$PKG_FILE" "$PKG_URL" 2>/dev/null || true
fi
if [ ! -s "$PKG_FILE" ] && command -v curl >/dev/null 2>&1; then
    curl -kfsSL -o "$PKG_FILE" "$PKG_URL" || true
fi
if [ ! -s "$PKG_FILE" ]; then
    echo "ERROR: download failed. Check network or install the .deb manually."
    exit 1
fi

echo "Installing ${PLUGIN_NAME}..."
if ! dpkg -i "$PKG_FILE"; then
    rm -f "$PKG_FILE"
    echo "ERROR: installation failed."
    exit 1
fi
rm -f "$PKG_FILE"

if [ "$NO_RESTART" = "1" ]; then
    echo "Restart enigma2."
    exit 0
fi

echo "Restarting enigma2..."
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart enigma2 2>/dev/null || killall -9 enigma2 2>/dev/null || true
else
    killall -9 enigma2 2>/dev/null || true
fi
