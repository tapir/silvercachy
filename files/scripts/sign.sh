#!/usr/bin/env bash

set -ouex pipefail

# Configuration
KEY="/tmp/certs/MOK.priv"

# 1. Dynamically find the kernel version from the installed RPM
KVER="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-cachyos-lto)"

if [ -z "$KVER" ]; then
    echo "Error: kernel-cachyos-lto not found in the RPM database."
    exit 1
fi

echo "Detected Kernel Version: $KVER"

# 2. Path to the Kernel Image in an OSTree build
# In OSTree systems, the kernel image is moved to the module directory
VMLINUZ="/usr/lib/modules/$KVER/vmlinuz"

if [ -f "$VMLINUZ" ]; then
    echo "Signing kernel image at: $VMLINUZ"
    sbsign --key "$KEY" --cert "$CERT" --output "$VMLINUZ" "$VMLINUZ"
else
    echo "Could not find vmlinuz in /usr/lib/modules"
    exit 1
fi

# 3. Find the signing utility
# Fedora/OSTree usually puts this in the kernel-devel or kernel-modules-internal package
SIGN_FILE=$(find /usr/src -name sign-file | head -n 1)
[ -z "$SIGN_FILE" ] && SIGN_FILE="/usr/lib/modules/$KVER/build/scripts/sign-file"

# 4. Sign all modules (including extras)
MODULE_ROOT="/usr/lib/modules/$KVER"

echo "Recursively signing modules in $MOD_DIR..."
find "$MODULE_ROOT" -name "*.ko.xz" -type f | while read -r mod; do
    # Decompress
    xz -d "$mod"
    RAW_MOD="${mod%.xz}"
    
    # Sign
    "$SIGN_FILE" sha256 "$KEY" "$CERT" "$RAW_MOD"
    
    # Recompress
    xz "$RAW_MOD"
done

echo "Successfully signed kernel and modules for $KVER"