# Add Homebrew to PATH if installed.
# Homebrew lives in the user's home directory and is set up post-install via:
#   ujust install-brew
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
