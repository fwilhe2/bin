#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 owner/repo"
    exit 1
fi

REPO="$1"
BINARY_NAME="${REPO##*/}"

# Detect OS and ARCH in GoReleaser format
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="x86_64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac

# Get latest release tag from GitHub
TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

TARBALL="${BINARY_NAME}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/$REPO/releases/download/$TAG/$TARBALL"

# Download and extract
curl -L "$URL" -o "$TARBALL"
tar -xzf "$TARBALL" "$BINARY_NAME"

# Move to /usr/local/bin (needs sudo)
chmod +x "$BINARY_NAME"
sudo mv "$BINARY_NAME" /usr/local/bin/

# Clean up
rm "$TARBALL"

echo "$BINARY_NAME installed to /usr/local/bin/"
