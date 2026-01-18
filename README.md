# SilverCachy &nbsp; [![bluebuild build badge](https://github.com/tapir/silvercachy/actions/workflows/build.yml/badge.svg)](https://github.com/tapir/silvercachy/actions/workflows/build.yml)

A `BlueBuild` image based on their `fedora-silverblue` image. It mainly adds the `CachyOS ThinLTO` kernel and builds `Nvidia` for it.
Kernel and the modules are signed with my MOK key which will be automatically enrolled after the first boot. Use password `scachy` when asked.

## Changes

- Remove:
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
- Install:
  - `Bazaar` flatpak (App Store)
  - `Ptyxis` flatpak (Terminal)
  - `kernel-cachyos-lto` kernel
  - `Nvidia` drivers from Negativo17
  - `cachyos-settings`
  - `gamemode`
  - `scx-scheds`
  - `scx-tools`

`game-performance` script from `cachyos-settings` is removed due it's dependency on `power-profile-daemon`. Fedora uses `tuned` instead which looks like is the future. Also it's not easy to run `game-performance` from Steam's flatpak version. Just use `gamemoderun`. Should do the same trick.

## Installation

- Disable `secureboot` from BIOS and boot to an atomic distro
- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  bootc switch ghcr.io/tapir/silvercachy:latest
  systemctl reboot
  ```
- Accept MOK key enrollment with password `scachy`
- Then rebase to the signed image:
  ```
  bootc switch --enforce-container-sigpolicy ghcr.io/tapir/silvercachy:latest
  systemctl reboot
  ```
- Enable `secureboot` back

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/tapir/silvercachy
```
