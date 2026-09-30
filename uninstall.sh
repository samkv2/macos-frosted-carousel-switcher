#!/usr/bin/env bash
# ==============================================================================
# macOS Frosted Carousel Switcher - Uninstaller
# ==============================================================================

set -e

PLUGIN_ID="macos_carousel_switcher"
TARGET_DIR="${HOME}/.local/share/kwin/tabbox/${PLUGIN_ID}"

BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${BOLD}macOS Frosted Carousel Switcher - Uninstaller${RESET}"

# 1. Reset KWin configuration back to default thumbnail_grid or breeze
KWRITE_BIN="$(command -v kwriteconfig6 2>/dev/null || command -v kwriteconfig5 2>/dev/null || true)"
QDBUS_BIN="$(command -v qdbus6 2>/dev/null || command -v qdbus 2>/dev/null || true)"
KPACKAGE_BIN="$(command -v kpackagetool6 2>/dev/null || command -v kpackagetool5 2>/dev/null || true)"

if [ -n "$KWRITE_BIN" ]; then
    echo -e "${BLUE}[*] Resetting Task Switcher to default (thumbnail_grid)...${RESET}"
    "$KWRITE_BIN" --file kwinrc --group TabBox --key LayoutName "thumbnail_grid"
fi

# 2. Unregister via KPackage
if [ -n "$KPACKAGE_BIN" ]; then
    "$KPACKAGE_BIN" --type KWin/WindowSwitcher --remove "${PLUGIN_ID}" >/dev/null 2>&1 || true
fi

# 3. Remove local directory
if [ -d "${TARGET_DIR}" ]; then
    echo -e "${BLUE}[*] Removing local plugin files from:${RESET} ${TARGET_DIR}"
    rm -rf "${TARGET_DIR}"
fi

# 4. Reconfigure KWin
if [ -n "$QDBUS_BIN" ]; then
    echo -e "${BLUE}[*] Reloading KWin...${RESET}"
    "$QDBUS_BIN" org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
fi

echo -e "${GREEN}[✓] macOS Frosted Carousel Switcher uninstalled successfully.${RESET}"
