#!/usr/bin/env bash
# NeuralNote installer.
#
#   curl -fsSL https://raw.githubusercontent.com/aniiirudhh/neuralnote-releases/main/install.sh | bash
#
# What it does, and nothing else:
#   1. Checks you are on an Apple Silicon Mac running macOS 13.5+.
#   2. Downloads NeuralNote.zip and NeuralNote.zip.sha256 from the public
#      GitHub Releases of aniiirudhh/neuralnote-releases.
#   3. Verifies the SHA-256 checksum, and that the app is signed by
#      NeuralNote's own certificate (not just "validly signed").
#   4. Copies NeuralNote.app into /Applications (or ~/Applications if
#      /Applications is not writable), replacing any previous version.
#
# NeuralNote is not notarized yet. Files fetched with curl are not
# quarantined, so Gatekeeper does not block the app. The checksum protects
# against a corrupted or truncated download; it comes from the same release,
# so it is not a substitute for notarization.
#
# Environment overrides:
#   NEURALNOTE_VERSION        install a specific version, e.g. 1.0.1 (default: latest)
#   NEURALNOTE_INSTALL_DIR    target directory (default: /Applications)
#   NEURALNOTE_DOWNLOAD_BASE  alternate release URL base (used by tests)
#   NEURALNOTE_SKIP_LAUNCH=1  do not open the app after installing
#   NEURALNOTE_SIGNER_SHA1    expected signing-certificate SHA-1 (used by tests)

set -euo pipefail

REPO="aniiirudhh/neuralnote-releases"
APP_NAME="NeuralNote.app"
ASSET="NeuralNote.zip"
BUNDLE_ID="ai.neuralnote.app"
# SHA-1 of the "NeuralNote Self-Signed" certificate every release is signed
# with. Checking only that a signature is valid would accept an app signed by
# anyone; pinning the certificate means a swapped download is refused even if
# its checksum file was swapped too.
SIGNER_SHA1_DEFAULT="cee499ac369c8c48d3a494bc67771703339612b4"

say() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

check_platform() {
    [ "$(uname -s)" = "Darwin" ] || die "NeuralNote runs on macOS only."
    [ "$(uname -m)" = "arm64" ] || die "NeuralNote needs an Apple Silicon Mac (M1 or later)."
    local ver major minor
    ver="$(sw_vers -productVersion)"
    major="${ver%%.*}"
    minor="$(printf '%s' "$ver" | cut -d. -f2)"
    minor="${minor:-0}"
    if [ "$major" -lt 13 ] || { [ "$major" -eq 13 ] && [ "$minor" -lt 5 ]; }; then
        die "macOS 13.5 or newer is required (found $ver)."
    fi
}

download_base() {
    if [ -n "${NEURALNOTE_DOWNLOAD_BASE:-}" ]; then
        printf '%s' "$NEURALNOTE_DOWNLOAD_BASE"
    elif [ -n "${NEURALNOTE_VERSION:-}" ]; then
        printf 'https://github.com/%s/releases/download/v%s' "$REPO" "$NEURALNOTE_VERSION"
    else
        printf 'https://github.com/%s/releases/latest/download' "$REPO"
    fi
}

install_dir() {
    if [ -n "${NEURALNOTE_INSTALL_DIR:-}" ]; then
        printf '%s' "$NEURALNOTE_INSTALL_DIR"
    elif [ -w /Applications ]; then
        printf '/Applications'
    else
        mkdir -p "$HOME/Applications"
        printf '%s' "$HOME/Applications"
    fi
}

main() {
    check_platform

    local base dest expected actual
    base="$(download_base)"
    dest="$(install_dir)"
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    local tmp="$TMP_DIR"

    # Refuse plain http and redirects to it for real downloads.
    local curl_opts=(-fsSL)
    case "$base" in https://*) curl_opts+=(--proto '=https' --tlsv1.2) ;; esac

    say "Downloading NeuralNote from $base"
    curl "${curl_opts[@]}" -o "$tmp/$ASSET" "$base/$ASSET"
    curl "${curl_opts[@]}" -o "$tmp/$ASSET.sha256" "$base/$ASSET.sha256"

    say "Verifying checksum"
    expected="$(awk '{print $1}' "$tmp/$ASSET.sha256")"
    actual="$(shasum -a 256 "$tmp/$ASSET" | awk '{print $1}')"
    [ -n "$expected" ] && [ "$expected" = "$actual" ] \
        || die "checksum mismatch (expected $expected, got $actual). Nothing was installed."

    ditto -x -k "$tmp/$ASSET" "$tmp/unpacked"
    [ -d "$tmp/unpacked/$APP_NAME" ] || die "$APP_NAME not found in download."

    say "Verifying code signature"
    local signer="${NEURALNOTE_SIGNER_SHA1:-$SIGNER_SHA1_DEFAULT}"
    codesign --verify --deep "$tmp/unpacked/$APP_NAME" 2>/dev/null \
        || die "code signature check failed. Nothing was installed."
    codesign --verify -R="identifier \"$BUNDLE_ID\" and certificate leaf = H\"$signer\"" \
        "$tmp/unpacked/$APP_NAME" 2>/dev/null \
        || die "this download is not signed by NeuralNote's certificate. Nothing was installed."

    if pgrep -x NeuralNote >/dev/null 2>&1; then
        say "Quitting running NeuralNote"
        osascript -e 'quit app "NeuralNote"' >/dev/null 2>&1 || pkill -x NeuralNote || true
        sleep 1
    fi

    say "Installing to $dest/$APP_NAME"
    mkdir -p "$dest"
    # Copy next to the target first, then swap, so a failed copy never leaves
    # the user without an app.
    local staged="$dest/.$APP_NAME.new"
    rm -rf "${staged:?}"
    ditto "$tmp/unpacked/$APP_NAME" "$staged"
    if [ -e "$dest/$APP_NAME" ]; then
        rm -rf "${dest:?}/$APP_NAME"
    fi
    mv "$staged" "$dest/$APP_NAME"
    xattr -dr com.apple.quarantine "$dest/$APP_NAME" 2>/dev/null || true

    say "Installed. Signed by: $(codesign -dvv "$dest/$APP_NAME" 2>&1 | awk -F= '/^Authority=/{print $2; exit}' || true)"
    if [ "${NEURALNOTE_SKIP_LAUNCH:-0}" != "1" ]; then
        open "$dest/$APP_NAME"
        say "NeuralNote is starting. Grant Microphone, Accessibility and Input Monitoring when asked."
    fi
}

main "$@"
