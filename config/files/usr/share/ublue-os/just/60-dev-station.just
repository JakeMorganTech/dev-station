# dev-station first-boot recipes
# Run any of these with: ujust <recipe-name>

# Install Homebrew into /home/linuxbrew/.linuxbrew
[group('dev-station')]
install-brew:
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install all Flatpaks from the baked-in app list
[group('dev-station')]
install-flatpaks:
    #!/usr/bin/env bash
    set -euo pipefail
    FLATPAK_LIST="/etc/dev-station/flatpak-apps.txt"
    echo "Installing Flatpaks from ${FLATPAK_LIST}..."
    while IFS= read -r app; do
        [[ -z "$app" || "$app" == \#* ]] && continue
        flatpak install -y flathub "$app" || echo "WARNING: failed to install $app, skipping"
    done < "$FLATPAK_LIST"
    echo "Done."

# Clone dotfiles repo and stow all packages
[group('dev-station')]
setup-dotfiles:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTFILES_DIR="$HOME/dotfiles"
    DOTFILES_REPO="https://github.com/JakeMorganTech/dotfiles.git"
    STOW_PACKAGES=(bashrc fastfetch fish icons kitty scripts starship ue-launcher)
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        echo "Dotfiles already cloned, pulling latest..."
        git -C "$DOTFILES_DIR" pull
    fi
    echo "Stowing packages..."
    for pkg in "${STOW_PACKAGES[@]}"; do
        echo "  stow $pkg"
        stow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
    done
    echo "Done."
