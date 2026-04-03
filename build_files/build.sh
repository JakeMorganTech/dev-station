#!/bin/bash

set -ouex pipefail

# ── VS Code ───────────────────────────────────────────────────────────────────
# Repo is pre-placed at /etc/yum.repos.d/vscode.repo via COPY in Containerfile.
# Import Microsoft's GPG key so the signed package is accepted.
rpm --import https://packages.microsoft.com/keys/microsoft.asc
dnf5 install -y code

# ── Brave Browser ─────────────────────────────────────────────────────────────
# Repo is pre-placed at /etc/yum.repos.d/brave-browser.repo via COPY in Containerfile.
# Native install required — flatpak/snap variants lack hardware security key support.
#
# /opt is a symlink to /var/opt in ostree images, and /var is a stateful mount
# that is NOT part of the immutable rootfs — files installed there during build
# are lost at deploy time. Work around this by:
#   1. Creating /var/opt/brave.com so RPM can unpack during build
#   2. Moving the installed files to /usr/lib/opt (part of the immutable rootfs)
#   3. Using a systemd-tmpfiles rule to symlink /opt/brave.com at boot
mkdir -p /var/opt/brave.com
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf5 install -y brave-browser
# Relocate to the immutable rootfs
mv /var/opt/brave.com /usr/lib/opt/brave.com
# Ensure the launcher is on PATH
ln -sf /usr/lib/opt/brave.com/brave/brave-browser /usr/bin/brave-browser-stable

# ── Development tools ─────────────────────────────────────────────────────────
# UE5 build system dependencies not present in the Bazzite base image.
# The engine ships its own clang toolchain but clang/lld on the host are also
# useful for non-UE C++ work. SDL2 is required by the UE5 editor at runtime.
dnf5 install -y \
    cmake \
    ninja-build \
    python3 \
    clang \
    lld \
    SDL2 \
    vim \
    fish \
    fastfetch \
    btop \
    nvtop \
    cava \
    cmatrix \
    kitty \
    stow \
    dotnet-runtime-8.0 \
    dotnet-sdk-8.0

# ── Starship ─────────────────────────────────────────────────────────────────
dnf5 -y copr enable atim/starship
dnf5 install -y starship
dnf5 -y copr disable atim/starship

# ── Fonts ─────────────────────────────────────────────────────────────────────
# Cascadia Code and Cascadia Mono Nerd Font variants
dnf5 install -y \
    cascadia-code-nf-fonts \
    cascadia-mono-nf-fonts

# NOTE: Steam, gamemode, and mangohud are already included in the bazzite-nvidia base image.
