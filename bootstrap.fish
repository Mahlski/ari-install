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
    alsa-utils btop claude-desktop-native dunst fastfetch fd file-roller \
    firefox fuzzel fzf gamemode gamescope gimp glmark2 grim \
    gst-plugin-pipewire hardinfo2 heroic-games-launcher-bin hypridle hyprland \
    hyprlock hyprpaper hyprpolkitagent hyprshutdown kitty less lib32-gamemode \
    lib32-mangohud lib32-pipewire libreoffice-still libreoffice-still-nl \
    limine mangohud mesa-utils network-manager-applet nvtop nwg-look obsidian \
    pacman-contrib pavucontrol pcmanfm pipewire pipewire-alsa pipewire-jack \
    pipewire-pulse python-pipx qbz-bin ripgrep rsync slurp steam stow ufw \
    ttf-sourcecodepro-nerd unzip vkmark waybar-git webapp-manager wget wireplumber wl-clipboard \
    xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-utils \
    xwayland-satellite
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

# --- 4. dotfiles (stow from public HTTPS — no SSH key needed) ---
echo "==> Cloning dotfiles over HTTPS..."
git clone https://github.com/Mahlski/dotfiles.git ~/dotfiles

echo "==> Stowing dotfiles..."
cd ~/dotfiles
for line in (stow -n config claude git local 2>&1)
    if string match -qr 'existing target is neither' -- $line
        set target (string replace -r '.*: ' '' -- $line)
        set full ~/$target
        if test -e $full; and not test -L $full
            mv $full $full.bak
            echo "    backed up: $target"
        end
    end
end
stow config claude git local

# ssh: link only .ssh/config (keys live outside the repo); never fold the dir
if test -e ~/.ssh/config; and not test -L ~/.ssh/config
    mv ~/.ssh/config ~/.ssh/config.bak
    echo "    backed up: .ssh/config"
end
stow --no-folding ssh
chmod 600 ~/dotfiles/ssh/.ssh/config

echo "==> Bootstrap complete. Dotfiles at ~/dotfiles (stow)."
echo "==> Open a NEW shell, then run:  fish ~/.local/bin/setup/post-install.fish"
echo ""
echo "    After post-install, from a Hyprland session:"
echo "      fish ~/.local/bin/setup/setup-webapps.fish"
echo ""
echo "    After vault (~/Mahlski) is set up:"
echo "      fish ~/.local/bin/setup/setup-obsidian-mcp.fish"
echo ""
echo "    SSH keys are NOT in the repo. To push changes later, generate a key and"
echo "    switch the remote to SSH:"
echo '      ssh-keygen -t ed25519'
echo "      # add ~/.ssh/id_ed25519.pub to GitHub, then:"
echo "      git -C ~/dotfiles remote set-url origin git@github.com:Mahlski/dotfiles.git"
