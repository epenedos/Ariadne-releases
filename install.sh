#!/bin/sh
# Install (or update) Ariadne on this Mac.
#
#   curl -fsSL https://raw.githubusercontent.com/epenedos/Ariadne-releases/main/install.sh | sh
#
# Downloads the latest release, installs it into /Applications (override with
# ARIADNE_INSTALL_DIR), and clears quarantine so Gatekeeper doesn't flag the
# ad-hoc-signed bundle as damaged. The app keeps itself up to date afterwards.
set -eu

REPO="epenedos/Ariadne-releases"
DEST="${ARIADNE_INSTALL_DIR:-/Applications}"
APP_NAME="Ariadne.app"

fail() { echo "✗ $1" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "Ariadne is a macOS app"
[ "$(uname -m)" = "arm64" ] || fail "Ariadne needs Apple Silicon (this Mac is $(uname -m))"
MACOS_MAJOR=$(sw_vers -productVersion | cut -d. -f1)
[ "$MACOS_MAJOR" -ge 14 ] || fail "Ariadne needs macOS 14 or newer (this Mac runs $(sw_vers -productVersion))"
[ -d "$DEST" ] || fail "$DEST doesn't exist"
[ -w "$DEST" ] || fail "$DEST isn't writable — try: ARIADNE_INSTALL_DIR=\$HOME/Applications sh install.sh"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading the latest Ariadne…"
curl -fsSL -o "$TMP/Ariadne.zip" \
  "https://github.com/$REPO/releases/latest/download/Ariadne.zip" \
  || fail "download failed — is https://github.com/$REPO reachable?"

/usr/bin/ditto -xk "$TMP/Ariadne.zip" "$TMP/unpacked" || fail "the archive didn't unpack"
[ -d "$TMP/unpacked/$APP_NAME" ] || fail "the archive didn't contain $APP_NAME"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
  "$TMP/unpacked/$APP_NAME/Contents/Info.plist" 2>/dev/null) || fail "the bundle looks corrupt"

if pgrep -xq Ariadne; then
  echo "⚠ Ariadne is running — the new version takes over on its next launch."
fi

if [ -d "$DEST/$APP_NAME" ]; then
  OLD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
    "$DEST/$APP_NAME/Contents/Info.plist" 2>/dev/null || echo "?")
  echo "Replacing Ariadne $OLD in $DEST…"
  rm -rf "$DEST/$APP_NAME"
fi

/usr/bin/ditto "$TMP/unpacked/$APP_NAME" "$DEST/$APP_NAME"
/usr/bin/xattr -dr com.apple.quarantine "$DEST/$APP_NAME" 2>/dev/null || true

echo "✓ Ariadne $VERSION installed at $DEST/$APP_NAME"
echo "  It checks for updates on launch and daily, and installs them silently."
