#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors the Fish prompt style: user@host:cwd (git-branch|state) | model ctx%

input=$(cat)

# --- Working directory (fish prompt_pwd style: abbreviate home to ~, shorten middle dirs) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
home_dir="$HOME"
# Abbreviate home prefix to ~
display_cwd="${cwd/#$home_dir/\~}"
# Shorten intermediate path components to first letter (fish prompt_pwd default behaviour)
IFS='/' read -ra parts <<< "$display_cwd"
shortened=""
last_idx=$(( ${#parts[@]} - 1 ))
for i in "${!parts[@]}"; do
    part="${parts[$i]}"
    if [[ $i -eq 0 || $i -eq $last_idx || -z "$part" ]]; then
        shortened="${shortened}${part}/"
    else
        shortened="${shortened}${part:0:1}/"
    fi
done
# Remove trailing slash
display_cwd="${shortened%/}"
# Fix double slash from root
display_cwd="${display_cwd//\/\//\/}"

# --- Git info (mirrors fish_vcs_prompt with showdirtystate + showuntrackedfiles) ---
git_info=""
if git_branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null); then
    git_state=""
    # Staged changes
    if ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
        git_state="${git_state}✚"
    fi
    # Dirty (unstaged modifications)
    if ! git -C "$cwd" diff --quiet 2>/dev/null; then
        git_state="${git_state}*"
    fi
    # Untracked files
    if [[ -n $(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null) ]]; then
        git_state="${git_state}?"
    fi
    if [[ -n "$git_state" ]]; then
        git_info=" (${git_branch}⚡${git_state})"
    else
        git_info=" (${git_branch}✓)"
    fi
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- Context window ---
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_str=""
if [[ -n "$ctx_pct" ]]; then
    ctx_str=$(printf " ctx:%.0f%%" "$ctx_pct")
fi

# --- Assemble ---
user=$(whoami)
host=$(hostname -s)

printf "%s@%s:%s%s" "$user" "$host" "$display_cwd" "$git_info"
if [[ -n "$model" ]]; then
    printf " [%s%s]" "$model" "$ctx_str"
fi
printf "\n"
