#!/usr/bin/env fish
# Dotfiles auth + clone + stow. Run from a REAL terminal (NOT piped):
#   fish ~/setup-dotfiles.fish
#
# The dotfiles repo (Mahlski/dotfiles) is private. Instead of a PAT, this
# authenticates GitHub via the device flow — a one-time code you enter on your
# phone at https://github.com/login/device — then uploads this machine's SSH key
# so the repo clones and pushes over SSH. No token is kept as a git credential.
#
# Why a separate script (not part of bootstrap): the device flow reads the code
# interactively, which a `curl ... | fish` pipe cannot provide. Must run in a tty.

set KEY ~/.ssh/id_ed25519

# --- 1. SSH keypair ---
echo "==> Checking SSH keypair..."
if not test -f $KEY
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "    Generating ed25519 keypair (Enter for no passphrase)..."
    ssh-keygen -t ed25519 -C (uname -n) -f $KEY
else
    echo "    $KEY exists (skipping keygen)"
end

# --- 2. trust github.com host key (skip first-connect prompt) ---
if not grep -q '^github.com ' ~/.ssh/known_hosts 2>/dev/null
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
    echo "    Added github.com to known_hosts"
end

# --- 3. GitHub device-flow auth (phone) ---
# Request admin:public_key so the same login can upload the key (one phone auth).
# No keyring needed: gh falls back to a plaintext token in ~/.config/gh/hosts.yml
# when no credential store is present (automatic on minimal Arch).
if gh auth status --hostname github.com >/dev/null 2>&1
    echo "==> gh already authenticated, skipping login."
else
    echo "==> Authenticating GitHub (device flow)."
    echo "    A one-time code will be shown. On your phone, open"
    echo "    https://github.com/login/device and enter it."
    gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key --scopes admin:public_key
end

# --- 4. upload this machine's public key ---
echo "==> Uploading SSH key to GitHub..."
gh ssh-key add $KEY.pub --title (uname -n); or echo "    (key may already be on the account — continuing)"

# Optional: the gh token is account-scoped and not needed for git once the remote
# is SSH. To drop it (re-login later for other gh use), uncomment:
#   gh auth logout --hostname github.com

# --- 5. clone dotfiles over SSH ---
echo "==> Cloning dotfiles over SSH..."
git clone git@github.com:Mahlski/dotfiles.git ~/dotfiles

# core.hooksPath is repo-local config — a fresh clone never has it, so the
# commit-guard (.githooks/pre-commit, normalizes settings.json) must be
# re-activated on every machine:
git -C ~/dotfiles config core.hooksPath .githooks

# --- 6. stow ---
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

echo ""
echo "==> Dotfiles deployed at ~/dotfiles (stow). Remote is SSH."
echo "==> Open a NEW shell, then run:  fish ~/.local/bin/setup/post-install.fish"
echo ""
echo "    After post-install, from a Hyprland session:"
echo "      fish ~/.local/bin/setup/setup-webapps.fish"
echo ""
echo "    After vault (~/Mahlski) is set up:"
echo "      fish ~/.local/bin/setup/setup-obsidian-mcp.fish"
