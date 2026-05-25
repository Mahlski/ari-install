#!/usr/bin/env fish
# Claude Code + Obsidian MCP setup for Ari desktop
#
# Prerequisites: git, nodejs/npm
#   sudo pacman -S --needed git nodejs npm
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Mahlski/ari-install/main/setup-cc.fish | fish
#   # OR, after cloning:
#   fish ~/ari-install/setup-cc.fish

set -l repo_url https://github.com/Mahlski/ari-install.git
set -l repo_dir ~/ari-install

# --- Dependency checks ---
set -l missing
for dep in git npx
    if not command -q $dep
        set -a missing $dep
    end
end
if test (count $missing) -gt 0
    echo "Error: missing: $missing"
    echo "Install first: sudo pacman -S --needed git nodejs npm"
    exit 1
end

# --- Clone / update repo ---
if test -d $repo_dir/.git
    echo "==> Updating ari-install..."
    git -C $repo_dir pull --ff-only
else if not test -d $repo_dir
    echo "==> Cloning ari-install..."
    git clone $repo_url $repo_dir
    or begin
        echo "Clone failed. Check network/git."
        exit 1
    end
end

# --- Install Claude Code ---
if not command -q claude
    echo "==> Installing Claude Code..."
    set -gx PATH ~/.local/bin $PATH
    mkdir -p ~/.local/bin
    curl -fsSL https://claude.ai/install.sh | bash
    or begin
        echo "Claude Code install failed."
        exit 1
    end
else
    echo "==> Claude Code: already installed"
end

# --- Skills ---
echo "==> Setting up skills..."
mkdir -p ~/.claude/skills

for skill in obsidian-mahlski dotfiles grill-me
    set dst ~/.claude/skills/$skill
    if test -L $dst
        echo "    $skill: symlink (dotfiles-managed) — skip"
    else if test -d $dst
        echo "    $skill: already present — skip"
    else
        cp -r $repo_dir/claude/skills/$skill $dst
        echo "    $skill: installed"
    end
end

# --- Statusline ---
if test -L ~/.claude/statusline-command.sh
    echo "==> Statusline: symlink (dotfiles-managed) — skip"
else if not test -f ~/.claude/statusline-command.sh
    cp $repo_dir/claude/statusline-command.sh ~/.claude/statusline-command.sh
    chmod +x ~/.claude/statusline-command.sh
    echo "==> Statusline: installed"
else
    echo "==> Statusline: already present — skip"
end

# --- Settings ---
if test -L ~/.claude/settings.json
    echo "==> Settings: symlink (dotfiles-managed) — skip"
else
    if test -f ~/.claude/settings.json
        cp ~/.claude/settings.json ~/.claude/settings.json.bak
        echo "==> Backed up settings.json → settings.json.bak"
    end
    cp $repo_dir/settings-template.json ~/.claude/settings.json
    echo "==> Wrote ~/.claude/settings.json"
end

# --- Done ---
echo ""
echo "Setup complete."
echo ""
echo "Manual steps:"
echo "  1. claude auth login          (browser auth)"
echo "  2. claude                     (open Claude Code, verify plugins load)"
echo "  3. Test vault: ask Claude to list top-level folders in your Obsidian vault"
echo ""
echo "Reference guide: ~/Mahlski/Ari/workflow/desktop-cc-setup.md"
