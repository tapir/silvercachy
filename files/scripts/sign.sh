#!/usr/bin/env bash

set -oue pipefail

# Dynamically find the kernel version from the installed RPM
KVER="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-cachyos-lto)"

if [ -z "$KVER" ]; then
    echo "Error: kernel-cachyos-lto not found in the RPM database."
    exit 1
fi

echo "Detected Kernel Version: $KVER"

# Path to the Kernel Image in an OSTree build
VMLINUZ="/usr/lib/modules/$KVER/vmlinuz"

if [ -f "$VMLINUZ" ]; then
    echo "Signing kernel image at: $VMLINUZ"
    sbsign --key "$KEY" --cert "$CERT" --output "$VMLINUZ" "$VMLINUZ"
else
    echo "Could not find vmlinuz in /usr/lib/modules"
    exit 1
fi

# Find the signing utility
SIGN_FILE=$(find /usr/src -name sign-file | head -n 1)
[ -z "$SIGN_FILE" ] && SIGN_FILE="/usr/lib/modules/$KVER/build/scripts/sign-file"

# Sign all modules (including extras)
MODULE_ROOT="/usr/lib/modules/$KVER"

echo "Recursively signing modules in $MODULE_ROOT..."

find "$MODULE_ROOT" -type f \( \
    -name "*.ko" \
    -o -name "*.ko.xz" \
    -o -name "*.ko.zst" \
    -o -name "*.ko.gz" \
\) -print0 | while IFS= read -r -d '' mod; do
    echo "Signing $mod"

    case "$mod" in
        *.ko)
            "$SIGN_FILE" sha256 /tmp/certs/MOK.priv /usr/share/silvercachy/MOK.pem "$mod"
            ;;
        *.ko.xz)
            xz -d "$mod"
            raw="${mod%.xz}"
            "$SIGN_FILE" sha256 /tmp/certs/MOK.priv /usr/share/silvercachy/MOK.pem "$raw"
            xz -z "$raw"
            ;;
        *.ko.zst)
            zstd -d --rm "$mod"
            raw="${mod%.zst}"
            "$SIGN_FILE" sha256 /tmp/certs/MOK.priv /usr/share/silvercachy/MOK.pem "$raw"
            zstd -q "$raw"
            ;;
        *.ko.gz)
            gunzip "$mod"
            raw="${mod%.gz}"
            "$SIGN_FILE" sha256 /tmp/certs/MOK.priv /usr/share/silvercachy/MOK.pem "$raw"
            gzip "$raw"
            ;;
    esac
done

echo "Successfully signed kernel and modules for $KVER"