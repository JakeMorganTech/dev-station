# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base image: Bazzite desktop variant with NVIDIA open kernel module
# bazzite-nvidia-open ships Steam, gamemode, mangohud, and proper NVIDIA driver setup out of the box.
# Requires Turing (RTX 20xx) or newer GPU — confirmed RTX 4070 (Ada Lovelace)
FROM ghcr.io/ublue-os/bazzite-nvidia-open:stable

LABEL org.opencontainers.image.title="dev-station"
LABEL org.opencontainers.image.description="KDE Plasma game dev workstation — Bazzite NVIDIA"

# Overlay repo and config files onto the rootfs before running build.sh
# This ensures third-party repos (e.g. VS Code) are present when dnf5 runs
COPY config/files/ /

### MODIFICATIONS
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint
