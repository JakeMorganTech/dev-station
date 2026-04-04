# dev-station first-boot recipes
# Run any of these with: ujust <recipe-name>

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
