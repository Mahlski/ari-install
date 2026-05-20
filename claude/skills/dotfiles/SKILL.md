---
name: dotfiles
description: Encodes the GNU stow + git dotfiles workflow for this user. Trigger
  whenever the user mentions "dotfiles", "my dotfiles", the ~/dotfiles repo, or
  the cc-dot function. Also trigger when working with config files tracked by the
  dotfiles repo — files under ~/.config/{hypr,fish,kitty,nvim,waybar,dunst,
  fuzzel,nwg-look,qt5ct,gtk-3.0,gtk-4.0,xsettingsd,environment.d}/,
  ~/.config/systemd/user/, ~/.ssh/config, or selected ~/.claude/ files. Trigger
  when the user wants to commit, stage, or push config changes, asks about their
  Hyprland/Kitty/Fish/Neovim/Waybar config, or syncs config between laptop and
  desktop. Do NOT trigger for generic git questions unrelated to dotfiles.
---

# dotfiles

The dotfiles repo is `~/dotfiles/` — a normal git repo whose contents are
symlinked into `$HOME` by GNU stow.

## How it works

- Repo root and stow directory: `~/dotfiles/`
- stow target: `$HOME` (the stow dir's parent — the default)
- Top-level folders are stow **packages**: `config`, `claude`, `ssh`, `local`.
  Inside each, the tree mirrors the `$HOME`-relative path.
- It is a plain git repo — use plain `git`, run from inside `~/dotfiles/`.

## Command form

In shell suggestions (Fish) and in Claude Code tool calls alike:

```fish
cd ~/dotfiles
git status
git add config/.config/hypr/hyprland.conf
git commit -m "hypr: update keybinds"
git push
```

`git status` shows everything, untracked files included — no hidden state.

## Adding a new file

A file is tracked only if it lives in a package:

```fish
mv ~/.config/foo/bar.conf ~/dotfiles/config/.config/foo/bar.conf
cd ~/dotfiles && stow config
```

## Removing a file

stow has no per-file unstow. To untrack config but keep it as a normal file in
`$HOME`, move it out of the package (overwrites the symlink), then `git rm`:

```fish
mv ~/dotfiles/config/.config/kitty ~/.config/kitty
cd ~/dotfiles && git rm -r config/.config/kitty
git commit -m "kitty: untrack"
```

`mv` first, `git rm` second. `stow -D <package>` unstows a whole package
(repo content kept). A single file inside a folded dir cannot be kept out of
the fold — untrack the whole component or delete it outright.

## Staging rules

Stage by explicit path; review `git diff <path>` before staging. Before staging,
scan for runtime-state files the user wouldn't want committed (table below).

## Files to never stage

Mostly handled by the repo `.gitignore`, but flag if they appear:

| File/Pattern | Why |
|---|---|
| `ssh/.ssh/id_*` | Private keys — absolute never |
| `**/fish_variables` | Fish auto-manages it; machine-specific |
| `**/lazy-lock.json` | Machine-specific nvim lockfile |
| `*.bak`, `*.log` | Transient noise |

## Commit message format

`component: short imperative description` — component matches the config
subdir (`hypr`, `fish`, `kitty`, `nvim`, `waybar`, …). Multi-component:
`config: <description>`.

## Machine-specific config

Laptop (`aribook`) and desktop share this repo with different hardware. Machine-
specific config (hyprland monitors, waybar outputs) uses separate files sourced
by hostname — never flatten into shared files.

## Caveats

- GUI tools (`nwg-look`, `qt5ct`) regenerate `gtk-3.0/`, `gtk-4.0/`,
  `nwg-look/config`, `qt5ct.conf`. An atomic-rename save can replace a symlink
  with a real file — after using them, check `git status` and re-stow if needed.
- ssh follows the symlinked `config`; the real file must be `600`.
- systemd user units are symlinks — `systemctl --user daemon-reload` after edits.

## Setup reference

- Repo + stow dir: `~/dotfiles/`
- Packages: `config`, `claude`, `ssh`, `local`
- Gitignore: repo-root `.gitignore`
- Remote: `git@github.com:Mahlski/dotfiles.git`, SSH, branch `main`
- Deploy on a new machine: `cd ~/dotfiles && stow config claude ssh local`
