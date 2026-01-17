#!/usr/bin/env bash

set -ouex pipefail

# Remove the kernel files installed by BlueBuild
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
    rpm --erase --nodeps $pkg
done

# We have to temporarily disable these otherwise build fails
cd /usr/lib/kernel/install.d \
    && mv 05-rpmostree.install 05-rpmostree.install.bak \
    && mv 50-dracut.install 50-dracut.install.bak \
    && printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install \
    && printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install \
    && chmod +x  05-rpmostree.install 50-dracut.install

# Install CachyOS kernel packages
sudo sed -i '/^\[fedora\]/a exclude=akmods' /etc/yum.repos.d/fedora.repo
sudo sed -i '/^\[updates\]/a exclude=akmods' /etc/yum.repos.d/fedora-updates.repo
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf install -y --setopt=install_weak_deps=False \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-devel-matched \
    kernel-cachyos-lto-modules
dnf -y copr remove bieszczaders/kernel-cachyos-lto

# Restore kernel install files
mv -f 05-rpmostree.install.bak 05-rpmostree.install \
    && mv -f 50-dracut.install.bak 50-dracut.install \
    && cd -