#!/usr/bin/env bash

set -ouex pipefail

# Get kernel version
KERNEL_VERSION="$(rpm -q "kernel-cachyos-lto" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

# Necessary packages to compile kmod
dnf install -y --setopt=install_weak_deps=False akmods

# Add Negativo17 repo
curl -fLsS --retry 5 -o /etc/yum.repos.d/fedora-nvidia.repo https://negativo17.org/repos/fedora-nvidia.repo
sed -i '/^enabled=1/a\priority=90' /etc/yum.repos.d/fedora-nvidia.repo

# Kmod compile
cp /usr/sbin/akmodsbuild /usr/sbin/akmodsbuild.backup
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild
dnf install -y --setopt=install_weak_deps=False --setopt=tsflags=noscripts akmod-nvidia nvidia-kmod-common nvidia-modprobe
akmods --force --verbose --kernels "${KERNEL_VERSION}" --kmod "nvidia"
mv /usr/sbin/akmodsbuild.backup /usr/sbin/akmodsbuild

# Check if everything went ok
modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz >/dev/null || {
    echo "NVIDIA modules missing for kernel ${KERNEL_VERSION}"
    find /var/cache/akmods/nvidia -name '*.log' -exec cat {} + 2>/dev/null || true
    exit 1
}

# Install userspace with multilibs
dnf install -y --setopt=install_weak_deps=False \
    'libva-nvidia-driver' \
    'nvidia-driver' \
    'nvidia-persistenced' \
    'nvidia-settings' \
    'nvidia-driver-cuda' \
    'libnvidia-cfg' \
    'libnvidia-fbc' \
    'libnvidia-ml' \
    'libnvidia-gpucomp' \
    'nvidia-driver-libs.i686' \
    'nvidia-driver-cuda-libs.i686' \
    'libnvidia-fbc.i686' \
    'libnvidia-ml.i686' \
    'libnvidia-gpucomp.i686'

# Add Nvidia container support
curl -fLsS --retry 5 -o /etc/yum.repos.d/nvidia-container-toolkit.repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
sed -i 's/^gpgcheck=0/gpgcheck=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's/^enabled=0.*/enabled=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install Nvidia container support
dnf install -y --setopt=install_weak_deps=False nvidia-container-toolkit

# SELinux policy
curl -fLsS --retry 5 -o nvidia-container.pp https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp
semodule -i nvidia-container.pp

# Remove added repos and files
rm -f nvidia-container.pp
rm -f /etc/yum.repos.d/nvidia-container-toolkit.repo
rm -f /etc/yum.repos.d/fedora-nvidia.repo

# Cleanup
dnf remove -y akmod-nvidia akmods