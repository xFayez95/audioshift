#!/bin/sh
# AudioShift one-line installer for DreamOS and supported OpenATV images.
#
# wget -O - https://xfayez95.github.io/audioshift/installer.sh | sh

PLUGIN_NAME="AudioShift"
VERSION_URL="https://xfayez95.github.io/audioshift/version.json"
WORK_DIR="/tmp/audioshift-installer"
MANIFEST_FILE="$WORK_DIR/version.json"
INFO_FILE="$WORK_DIR/package-info"

NO_RESTART=0
for arg in "$@"; do
    case "$arg" in
        --watch|--no-restart) NO_RESTART=1 ;;
    esac
done

fail() {
    echo "ERROR: $*"
    rm -rf "$WORK_DIR"
    exit 1
}

fetch() {
    url="$1"
    output="$2"
    rm -f "$output"
    if command -v wget >/dev/null 2>&1; then
        wget --no-check-certificate -q -O "$output" "$url" 2>/dev/null || true
    fi
    if [ ! -s "$output" ] && command -v curl >/dev/null 2>&1; then
        curl -kfsSL -o "$output" "$url" || true
    fi
    [ -s "$output" ]
}

restart_enigma2() {
    if [ "$NO_RESTART" = "1" ]; then
        echo "Restart Enigma2 to finish installation."
        return
    fi
    echo "Restarting Enigma2..."
    if [ "$PACKAGE_TYPE" = "ipk" ]; then
        init 4 && sleep 1 && init 3
    elif command -v systemctl >/dev/null 2>&1; then
        systemctl restart enigma2 2>/dev/null || killall -9 enigma2 2>/dev/null || true
    else
        killall -9 enigma2 2>/dev/null || true
    fi
}

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR" || fail "cannot create temporary directory"
fetch "$VERSION_URL" "$MANIFEST_FILE" || fail "could not download update metadata"

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
fi

if [ -f /var/lib/dpkg/status ] && command -v dpkg >/dev/null 2>&1; then
    PACKAGE_TYPE="deb"
    ARCH="$(dpkg --print-architecture 2>/dev/null || true)"
    [ "$ARCH" = "arm64" ] || fail "unsupported DreamOS architecture: ${ARCH:-unknown}"
    [ -n "$PYTHON_BIN" ] || fail "Python is required to read package metadata"
    PACKAGE_URL="$("$PYTHON_BIN" - "$MANIFEST_FILE" <<'PY'
import json
import sys
try:
    payload = json.load(open(sys.argv[1]))
    url = str(payload.get("download_url") or "").strip()
    if not url.startswith("https://"):
        raise ValueError("invalid package URL")
    print(url)
except Exception:
    sys.exit(1)
PY
)" || fail "DreamOS package metadata is invalid"
    PACKAGE_FILE="$WORK_DIR/audioshift-dreamos.deb"
else
    command -v opkg >/dev/null 2>&1 || fail "supported DreamOS or OpenATV image not detected"
    [ -n "$PYTHON_BIN" ] || fail "Python 3 is required to select the OpenATV package"
    MACHINE="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    case "$MACHINE" in
        aarch64|arm64) ARCH="aarch64" ;;
        cortexa15*|armv7*|armv8*|arm*) ARCH="cortexa15hf-neon-vfpv4" ;;
        *) fail "unsupported OpenATV architecture: ${MACHINE:-unknown}" ;;
    esac
    PYTHON_ABI="$("$PYTHON_BIN" -c 'import sys; print("py%d.%d" % sys.version_info[:2])' 2>/dev/null)"
    [ -n "$PYTHON_ABI" ] || fail "could not detect the Python version"
    "$PYTHON_BIN" - "$MANIFEST_FILE" "$ARCH" "$PYTHON_ABI" > "$INFO_FILE" <<'PY'
import json
import re
import sys
try:
    payload = json.load(open(sys.argv[1]))
    arch, python = sys.argv[2:4]
    item = payload.get(arch, {}).get(python)
    if not isinstance(item, dict):
        raise ValueError("no matching package")
    package_arch = str(item.get("architecture") or arch).strip()
    url = str(item.get("download_url") or item.get("url") or "").strip()
    digest = str(item.get("sha256") or "").strip().lower()
    if package_arch != arch or not url.startswith("https://"):
        raise ValueError("invalid package metadata")
    if not re.fullmatch(r"[0-9a-f]{64}", digest):
        raise ValueError("invalid package checksum")
    print(url)
    print(digest)
except Exception:
    sys.exit(1)
PY
    [ "$?" -eq 0 ] || fail "no package is published for $ARCH with $PYTHON_ABI"
    PACKAGE_URL="$(sed -n '1p' "$INFO_FILE")"
    PACKAGE_SHA256="$(sed -n '2p' "$INFO_FILE")"
    [ -n "$PACKAGE_URL" ] && [ -n "$PACKAGE_SHA256" ] || fail "OpenATV package metadata is invalid"
    PACKAGE_TYPE="ipk"
    PACKAGE_FILE="$WORK_DIR/audioshift-update.ipk"
    echo "Detected OpenATV package: $ARCH / $PYTHON_ABI"
fi

echo "Downloading ${PLUGIN_NAME}..."
fetch "$PACKAGE_URL" "$PACKAGE_FILE" || fail "package download failed"

if [ "$PACKAGE_TYPE" = "ipk" ]; then
    command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is required to verify the package"
    ACTUAL_SHA256="$(sha256sum "$PACKAGE_FILE" | awk '{print $1}')"
    [ "$ACTUAL_SHA256" = "$PACKAGE_SHA256" ] || fail "package checksum does not match"
fi

echo "Installing ${PLUGIN_NAME}..."
if [ "$PACKAGE_TYPE" = "deb" ]; then
    dpkg -i "$PACKAGE_FILE" || fail "installation failed"
else
    opkg install --force-reinstall "$PACKAGE_FILE" || fail "installation failed"
fi

rm -rf "$WORK_DIR"
restart_enigma2
