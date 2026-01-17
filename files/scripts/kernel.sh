#!/usr/bin/env bash

set -ouex pipefail

# Remove the kernel files installed by BlueBuild
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
    rpm --erase --nodeps $pkg
done

# Install CachyOS kernel packages
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf install -y --setopt=install_weak_deps=False \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-devel-matched \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-nvidia-open 
dnf -y copr remove bieszczaders/kernel-cachyos-lto