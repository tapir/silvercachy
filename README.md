# SilverCachy &nbsp; [![bluebuild build badge](https://github.com/tapir/silvercachy/actions/workflows/build.yml/badge.svg)](https://github.com/tapir/silvercachy/actions/workflows/build.yml)

A `BlueBuild` image based on their `fedora-silverblue` image. It mainly adds the `CachyOS ThinLTO` kernel and builds `Nvidia` for it.
Kernel and the modules are signed with my MOK key which will be automatically enrolled after the first boot. Use password `scachy` when asked.

## Changes

- Remove packages:
  - `firefox`
  - `firefox-langpacks`
  - `htop`
  - `nvtop`
  - `gnome-software`
  - `gnome-tour`
  - `ptyxis`
  - `gnome-system-monitor`
  - `malcontent-control`
  - `gnome-disk-utility`
  - `gnome-color-manager`
  - `yelp`
- Replace `tuned` with `powerpower-profiles-daemon`
- Install `Bazaar` (App Store) and `Ptyxis` (Terminal) at firstboot to have a minimal set of applications where you can install other applications
- Install `CachyOS-LTO` kernel
- Install latest `Nvidia` drivers from Negativo17
- Install `CachyOS Addons`
- Enroll `silvercachy` MOK
- Sign kernel and modules
- **TODO:** Make use of more `BlueBuild` modules like `akmods` instead of custom scripts

## Installation

- Disable `secureboot` from BIOS
- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/tapir/silvercachy:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Accept MOK key enrollment with password `scachy`
- Then rebase to the signed image:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/tapir/silvercachy:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```
- Enable `secureboot` back

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/tapir/silvercachy
```
