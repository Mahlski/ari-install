#!/usr/bin/env fish
# ari (desktop) fresh-install bootstrap. Run on a fresh minimal Arch install:
#   curl -fsSL https://raw.githubusercontent.com/Mahlski/ari-install/main/bootstrap.fish | fish

# --- 1. yay (AUR helper) ---
if not command -q yay
    echo "==> Building yay from AUR..."
    set tmpdir (mktemp -d)
    git clone https://aur.archlinux.org/yay.git $tmpdir/yay
    cd $tmpdir/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf $tmpdir
else
    echo "==> yay already present, skipping."
end

# --- 2. packages ---
# NVIDIA stack + base pacstrap packages are installed by archinstall (see
# archinstall-ari-desktop.json). This list covers everything else from
# Ari/base-configs/ari-base-pkg.md (yay section), minus the laptop-only items.
echo "==> Installing packages..."
set packages \
    aerc alsa-utils arp-scan btop claude-desktop-native dmidecode dunst fastfetch fd file-roller \
    firefox fuzzel fzf gamemode gamescope gimp git-filter-repo github-cli glmark2 gnupg grim \
    gst-plugin-pipewire hardinfo2 heroic-games-launcher-bin hyprcaffeine hypridle hyprland \
    hyprlock hyprpaper hyprpolkitagent hyprshutdown isync kitty less lib32-gamemode \
    lib32-mangohud lib32-pipewire libpulse libreoffice-still libreoffice-still-nl \
    limine lua-language-server mangohud mesa-utils mpv-full-build-git msmtp network-manager-applet notmuch \
    noto-fonts noto-fonts-cjk noto-fonts-emoji nvtop nwg-look obsidian openssh \
    pacman-contrib pass pavucontrol pcmanfm pinentry pipewire pipewire-alsa pipewire-jack \
    pipewire-pulse python-pipx qbittorrent qbz-bin ripgrep rpi-imager rsync shellcheck slurp smartmontools steam syncthing ufw \
    unzip uv vkmark waybar-git webapp-manager wget wireplumber wl-clipboard \
    xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-utils \
    xwayland-satellite zram-generator
yay -S --needed --noconfirm $packages
xdg-user-dirs-update

# Disable fish welcome message globally (universal var)
set -U fish_greeting ""

# --- 3. Claude (desktop + code) ---
echo "==> Installing Claude desktop + Claude Code..."
mkdir -p ~/.local/bin
fish_add_path -g ~/.local/bin
yay -S --needed --noconfirm claude-desktop-native
curl -fsSL https://claude.ai/install.sh | bash

# --- 4. dotfiles auth + clone (separate script — needs a real terminal) ---
# The dotfiles repo is private. Auth uses the GitHub device flow (authorize on
# your phone), which needs an interactive terminal — this bootstrap runs as
# `curl ... | fish`, so stdin is the pipe, not the keyboard. We therefore only
# DOWNLOAD the auth/clone/stow script here; run it next from a real shell.
echo "==> Fetching dotfiles setup script..."
curl -fsSL https://raw.githubusercontent.com/Mahlski/ari-install/main/setup-dotfiles.fish -o ~/setup-dotfiles.fish

echo ""
echo "==> Bootstrap complete (packages + Claude installed)."
echo "==> Next, from THIS terminal (not piped), run:"
echo "      fish ~/setup-dotfiles.fish"
echo "    It authenticates GitHub on your phone, uploads an SSH key, then"
echo "    clones + stows the dotfiles repo over SSH."
