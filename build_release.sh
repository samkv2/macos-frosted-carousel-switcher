#!/usr/bin/env bash
# ==============================================================================
# Commercial Release Bundler for macOS Frosted Carousel Switcher
# Generates clean, ready-to-distribute .zip and .tar.gz packages
# ==============================================================================

set -e

VERSION="2.1.0"
DIST_NAME="macos-frosted-carousel-switcher-v${VERSION}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_DIR="${SCRIPT_DIR}/dist"

mkdir -p "${RELEASE_DIR}/${DIST_NAME}"

echo "Packaging release: ${DIST_NAME}..."

# Copy essential files
cp -r "${SCRIPT_DIR}/contents" "${RELEASE_DIR}/${DIST_NAME}/"
cp "${SCRIPT_DIR}/metadata.json" "${RELEASE_DIR}/${DIST_NAME}/"
cp "${SCRIPT_DIR}/install.sh" "${RELEASE_DIR}/${DIST_NAME}/"
cp "${SCRIPT_DIR}/uninstall.sh" "${RELEASE_DIR}/${DIST_NAME}/"
cp "${SCRIPT_DIR}/README.md" "${RELEASE_DIR}/${DIST_NAME}/"

# Make scripts executable
chmod +x "${RELEASE_DIR}/${DIST_NAME}/install.sh"
chmod +x "${RELEASE_DIR}/${DIST_NAME}/uninstall.sh"

cd "${RELEASE_DIR}"

# Create ZIP archive
zip -rq "${DIST_NAME}.zip" "${DIST_NAME}"
echo "[✓] Created ${RELEASE_DIR}/${DIST_NAME}.zip"

# Create TAR.GZ archive
tar -czf "${DIST_NAME}.tar.gz" "${DIST_NAME}"
echo "[✓] Created ${RELEASE_DIR}/${DIST_NAME}.tar.gz"

# Clean up temp folder
rm -rf "${DIST_NAME}"

echo "Done! Distribution packages are ready in ${RELEASE_DIR}/"
