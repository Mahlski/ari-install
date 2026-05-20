---
name: obsidian-mahlski
description: >
  Complete reference for working inside the Mahlski Obsidian vault at ~/Mahlski.
  Trigger when the user asks to create, edit, move, rename, or organize notes;
  says "add a note about X", "update my backlog", "add this to my vault";
  references a note by name or pastes a path under ~/Mahlski; asks to
  read/write anything in the vault; asks to save something for later reading;
  or says "add this to my inbox". Load proactively any time Obsidian or
  vault context is relevant.
---

# Mahlski Vault — Working Reference

Vault root: `~/Mahlski`  
Obsidian settings: `~/Mahlski/.obsidian/`
Active machine: laptop unless stated otherwise. Don't reference desktop-specific 
hardware or paths unless the user specifies desktop.

---

## When to Use This Skill
- Asks to create, edit, move, rename, or organize notes in the vault
- Says "add a note about X", "update my backlog", "add this to my vault"
- References a note by name or pastes a path under ~/Mahlski
- Asks to read/write anything in the Mahlski vault
- Asks to save something for later reading
- Says "add this to my inbox"
- Any time Obsidian or vault context is relevant

---

## Folder Map

| Folder | What lives here |
|---|---|
| `Ari/` | Linux reference — Arch install docs, configs, cheatsheets, workflows |
| `Ari/base-configs/` | Full OS install procedure, package lists, fstab, initramfs |
| `Ari/config/` | Per-app config notes (fish, hypr, dunst, nvidia, etc.) |
| `Ari/config/hypr/` | Hyprland-specific config fragments |
| `Ari/games/` | Gaming notes (blacklists, tweaks) |
| `Ari/limine/` | Bootloader config |
| `Ari/reference/` | Quick-reference sheets (commands, git, nvim) |
| `Ari/workflow/` | Workflow docs (dotfiles cheatsheet, etc.) |
| `Audio/` | Audio stack notes (DAC, amp, streamer, Volumio) |
| `Claude/` | Claude-related notes — cheat sheets, templates, setup state |
| `Claude/code/` | Claude Code–specific templates |
| `Claude/code/config/` | CLAUDE.md drafts and templates |
| `Claude/context/` | Context docs designed to be pasted into Claude chats |
| `Claude/context/projects/` | Per-project context files (linux, audio-stack, wine, etc.) |
| `Claude/docs/` | Longer Claude documentation |
| `Cooking/` | Recipes |
| `Daily-notes/` | Daily scratchpad notes — one file per day |
| `Inbox/` | Read-later queue — articles, summaries, recaps pending review |
| `Inbox/articles/` | Saved articles or long reads |
| `Inbox/summaries/` | CC-generated summaries |
| `Inbox/recaps/` | Session recaps, chat exports |
| `Shopping/` | Shopping lists |

When a note doesn't fit an existing folder, place it in the closest matching topic folder. If there's genuinely no match, put it directly in `Inbox/` — it will be picked up during daily review.

---

## File Naming
- Default: `kebab-case.md` for all new notes
- Root folders use Title Case (`Ari/`, `Claude/`, etc.) — this is structural, not a naming convention to follow for note files
- Daily notes: always `YYYY-MM-DD.md`

---

## Daily Notes

Format: `YYYY-MM-DD.md` in `Daily-notes/`.  
Content: freeform — no required template. Brief, informal entries are normal.  
Today's date is always available via the `currentDate` context.

To create today's note:
```
~/Mahlski/Daily-notes/2026-05-12.md
```

---

## Markdown Conventions

- **No YAML frontmatter** — notes don't use `---` front matter blocks
- **Wikilinks** for internal cross-references: `[[note-name]]` (same folder) or `[[Folder/note-name]]` (cross-folder). Obsidian's `alwaysUpdateLinks: true` is set, so renames auto-update wikilinks.
- Wikilinks are typically grouped at the bottom of notes after a `---` separator, e.g.:  
  `[[claude-code-ob]] · [[git]] · [[Ari/config/SSH]]`
- **No Obsidian tags** (`#tag`) — not used in this vault
- Code blocks use fenced syntax with language tags (`fish`, `bash`, `lua`, `toml`, `conf`, etc.)
- Tables use GFM pipe syntax
- H1 (`#`) for the note title, H2 (`##`) for major sections — no deeper than H3 unless the note is long

---

## Note Types and Their Patterns

**Config notes** (`Ari/config/`, `Ari/base-configs/`)  
Raw commands, config fragments, install sequences. Minimal prose — the content is the reference. Code blocks for anything multi-line.

**Reference notes** (`Ari/reference/`)  
Quick-lookup tables and lists. Keep them scannable.

**Context/focus notes** (`Claude/context/`, `Claude/context/projects/`)  
Structured docs meant to be pasted into Claude sessions. Follow this rough shape:

    # [Title] — [Scope] | Reference
    
    > Paste this on every chat within this project.
    > Last updated: YYYY-MM-DD · Active machine: Laptop
    
    ---
    
    ## Setup State
    [status table]
    
    ## Current Focus / Task Backlog
    - [x] done item
    - [ ] pending item
    
    ## Reference Notes
    [[link]] · [[link]]
    
    ## Goal for This Chat
    [describe your goal here before pasting]

**Daily notes** (`Daily-notes/`)  
Informal scratchpad. No structure required.

**Backlog / cheat sheet notes** (`Claude/`)  
Mixed format — prose, tables, checklists. Update in place rather than creating new versions.

---

## Inbox Workflow

### Routing — decide by the ask, not the source

The user's request determines the target folder, not the input type. A web article can become either an article note or a summary note depending on what was asked for:

| User's ask | Target | What gets saved |
|---|---|---|
| "Save this article" / "add to inbox" / "read later" | `Inbox/articles/` | Full article note (article template) |
| "Summarize this" / "give me the gist" / "summary of X" / "TL;DR this" | `Inbox/summaries/` | Summary note (summary template) |
| "Save and summarize" | both | Full article in `articles/`, summary in `summaries/` linking back via `[[…]]` |
| Session recap, chat export | `Inbox/recaps/` | As-is |
| Multi-source synthesis (after several articles processed) | `Inbox/summaries/` | Synthesis template |
| Truly unclear | `Inbox/` root | — |

If the verb "summarize" (or a synonym) appears in the request, the destination is `Inbox/summaries/` — even if the input is a single article URL.

### Research and webfetch guidance

When researching a topic or summarizing an article, fetched sources must be:
- **Reputable** — primary sources, established publications, official docs, peer-reviewed work. Avoid content farms, SEO blogspam, AI-generated aggregators.
- **Relevant** — directly about the article or topic being summarized. Don't pull in tangential pages just because they came up in search.

If reputable sources are thin, say so in the note rather than padding with low-quality ones.

### Article template

    # [Title]
    
    **Source:** [URL or publication]
    **Saved:** YYYY-MM-DD
    **Note:** [optional — e.g. "discuss with Dario"]
    
    ## Key Points
    - [bullet]
    - [bullet]
    - [bullet]

### Single-source summary template

For `Inbox/summaries/` when summarizing one article or document.

    # [Subject] — Summary
    
    **Source:** [URL or [[article-note]]]
    **Date:** YYYY-MM-DD
    
    ## BLUF
    [one sentence — bottom line]
    
    ## Key Points
    - [bullet]
    - [bullet]
    
    ## Open Questions
    - [optional]

Filename: `[subject]-summary.md` (e.g. `rag-architectures-summary.md`). If a companion article note exists in `Inbox/articles/`, link to it from the `**Source:**` line.

### Professional doc template

    # [Document Title]
    
    **Source:** [filename or origin]
    **Saved:** YYYY-MM-DD
    **Note:** [optional]
    
    ## BLUF
    [one sentence — bottom line]
    
    ## Key Points
    - [bullet]
    
    ## Action Items
    - [ ] [if any]

### Multiple sources — same subject
Each article gets its own note in `Inbox/articles/` using a shared prefix:
`[subject]-[source].md` — e.g. `rag-architectures-anthropic.md`

After all sources are processed, request a synthesis note → saved to `Inbox/summaries/`:

    # [Subject] — Multi-source Synthesis
    
    **Sources:** [[article-1]] · [[article-2]] · [[article-3]]
    **Date:** YYYY-MM-DD
    
    ## BLUF
    [one sentence bottom line across all sources]
    
    ## Where Sources Agree
    - [bullet]
    
    ## Where Sources Diverge
    - [bullet — attribute to source]
    
    ## Open Questions
    - [bullet]

### Session recaps
No fixed template yet — format varies by session type. Store in `Inbox/recaps/` as-is.

---

## Editing Guidelines

- **Edit in place** — don't create duplicates or versioned copies. Notes are living docs.
- **Preserve formatting style** — match the existing heading levels, list style, and code block language tags in the file you're editing.
- **Wikilinks are case-sensitive** in Obsidian's resolver — use the exact note name, including capitalisation.
- When moving a note: update any wikilinks pointing to it (Obsidian's `alwaysUpdateLinks` helps, but verify cross-folder links manually).
- When adding a backlog item: append to the relevant checklist with `- [ ] item` syntax.
- When checking off a backlog item: change `- [ ]` to `- [x]`.

---

## Graduation Rule
When a workflow or config note in `Claude/` becomes stable and reference-worthy, 
move it to the appropriate `Ari/` subfolder:
- Stable workflows → `Ari/workflow/`
- App config notes → `Ari/config/`
- Command references → `Ari/reference/`

---

## Creating Notes

1. Determine the right folder from the map above.
2. Name the file following the folder's existing pattern.
3. Start with an H1 title.
4. No frontmatter.
5. Add a wikilink footer only if there are related notes worth cross-referencing.

Example — new config note for an app called "rclone" in Ari/config/:

    ~/Mahlski/Ari/config/rclone.md

    # rclone
    
    [content]
