#!/usr/bin/env bash

set -ouex pipefail

# Add RPM Fusion non-free repos
dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install userspace with multilibs
dnf install -y --setopt=install_weak_deps=False \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-cuda-libs.i686 \
    xorg-x11-drv-nvidia-libs.i686 \
    pciutils-libs.i686
dnf remove -y akmod-nvidia

# Add Nvidia container support
curl -fLsS --retry 5 -o /etc/yum.repos.d/nvidia-container-toolkit.repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
sed -i 's/^gpgcheck=0/gpgcheck=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's/^enabled=0.*/enabled=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install Nvidia container support
dnf install -y --setopt=install_weak_deps=False nvidia-container-toolkit

# SELinux policy for containers
curl -fLsS --retry 5 -o nvidia-container.pp https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp
semodule -i nvidia-container.pp

# Remove added repos and files
rm -f nvidia-container.pp
rm -f /etc/yum.repos.d/nvidia-container-toolkit.repo
dnf remove -y rpmfusion-nonfree-release