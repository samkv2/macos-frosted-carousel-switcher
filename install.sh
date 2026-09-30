#!/usr/bin/env bash
# ==============================================================================
# macOS Frosted Carousel Switcher - Universal Installer
# Compatible with: KDE Plasma 6 & Plasma 5 on any Linux distribution
# (Arch, Fedora, Ubuntu, Kubuntu, Debian, openSUSE, Manjaro, KDE Neon, etc.)
# ==============================================================================

set -e

PLUGIN_ID="macos_carousel_switcher"
PLUGIN_NAME="macOS Frosted Carousel Switcher"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Styling
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}"
echo "========================================================"
echo "    ${PLUGIN_NAME} - Installer"
echo "========================================================"
echo -e "${RESET}"

# 1. Detect Desktop Environment
if [ "$XDG_CURRENT_DESKTOP" != "KDE" ] && [ "$DESKTOP_SESSION" != "plasma" ] && [ -z "$KDE_FULL_SESSION" ]; then
    echo -e "${YELLOW}[!] Warning:${RESET} Current desktop session does not appear to be KDE Plasma."
    echo -e "    This switcher is designed specifically for KDE Plasma (KWin)."
    read -p "    Continue installation anyway? (y/N): " -r choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
fi

# 2. Detect Plasma Version & Tools
KWRITE_BIN=""
QDBUS_BIN=""
KPACKAGE_BIN=""

if command -v kwriteconfig6 >/dev/null 2>&1; then
    PLASMA_VER=6
    KWRITE_BIN="kwriteconfig6"
    QDBUS_BIN="$(command -v qdbus6 2>/dev/null || command -v qdbus 2>/dev/null || true)"
    KPACKAGE_BIN="$(command -v kpackagetool6 2>/dev/null || true)"
elif command -v kwriteconfig5 >/dev/null 2>&1; then
    PLASMA_VER=5
    KWRITE_BIN="kwriteconfig5"
    QDBUS_BIN="$(command -v qdbus 2>/dev/null || command -v qdbus-qt5 2>/dev/null || true)"
    KPACKAGE_BIN="$(command -v kpackagetool5 2>/dev/null || true)"
else
    echo -e "${RED}[ERROR] Neither kwriteconfig6 nor kwriteconfig5 was found.${RESET}"
    echo "Please ensure KDE Plasma base utilities are installed."
    exit 1
fi

echo -e "${GREEN}[✓] Detected KDE Plasma ${PLASMA_VER} environment.${RESET}"

# 3. Determine Installation Target Path
if [ "$1" == "--system" ] || [ "$(id -u)" -eq 0 ]; then
    # System-wide install
    TARGET_DIR="/usr/share/kwin/tabbox/${PLUGIN_ID}"
    echo -e "${BLUE}[*] Performing system-wide installation to:${RESET} ${TARGET_DIR}"
    mkdir -p "${TARGET_DIR}/contents/ui"
    cp -r "${SCRIPT_DIR}/metadata.json" "${TARGET_DIR}/"
    cp -r "${SCRIPT_DIR}/contents/ui/"* "${TARGET_DIR}/contents/ui/"
else
    # User-local install (Standard & Recommended)
    TARGET_DIR="${HOME}/.local/share/kwin/tabbox/${PLUGIN_ID}"
    echo -e "${BLUE}[*] Installing to user directory:${RESET} ${TARGET_DIR}"
    mkdir -p "${TARGET_DIR}/contents/ui"
    cp -r "${SCRIPT_DIR}/metadata.json" "${TARGET_DIR}/"
    cp -r "${SCRIPT_DIR}/contents/ui/"* "${TARGET_DIR}/contents/ui/"
fi

echo -e "${GREEN}[✓] Files successfully copied.${RESET}"

# 4. Register with KPackage (if available)
if [ -n "$KPACKAGE_BIN" ]; then
    echo -e "${BLUE}[*] Registering package with KPackage manager...${RESET}"
    "$KPACKAGE_BIN" --type KWin/WindowSwitcher --install "${TARGET_DIR}" >/dev/null 2>&1 || \
    "$KPACKAGE_BIN" --type KWin/WindowSwitcher --upgrade "${TARGET_DIR}" >/dev/null 2>&1 || true
    echo -e "${GREEN}[✓] Package registered.${RESET}"
fi

# 5. Activate in KWin Configuration
echo -e "${BLUE}[*] Activating switcher in ~/.config/kwinrc...${RESET}"
"$KWRITE_BIN" --file kwinrc --group TabBox --key LayoutName "${PLUGIN_ID}"
echo -e "${GREEN}[✓] KWin configuration updated.${RESET}"

# 6. Reconfigure Running KWin Session
if [ -n "$QDBUS_BIN" ]; then
    echo -e "${BLUE}[*] Reloading active KWin compositor...${RESET}"
    "$QDBUS_BIN" org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
    echo -e "${GREEN}[✓] KWin reconfigured successfully!${RESET}"
fi

echo ""
echo -e "${BOLD}${GREEN}========================================================"
echo "    Installation Complete!"
echo "========================================================${RESET}"
echo ""
echo -e "You can now press ${BOLD}Alt + Tab${RESET} to enjoy your new switcher!"
echo ""
echo -e "Tip: You can also customize or preview it anytime via:"
echo -e "     ${CYAN}System Settings -> Window Management -> Task Switcher${RESET}"
echo ""
