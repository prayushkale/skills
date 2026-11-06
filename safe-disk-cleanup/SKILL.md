---
name: safe-disk-cleanup
description: Find what is filling a Mac or Linux disk and free space without losing anything. Runs a read-only scan, verifies every candidate (git state, duplicates, symlinks, running processes), explains each item in plain language, and deletes nothing without the user's explicit yes for that specific item. Use whenever the user says their disk or storage is full or almost full, is low on space, asks what is using space, wants to clean up node_modules, build folders, caches, old worktrees, Docker, Xcode or Android data, render frames or old downloads, mentions running mo analyze, ncdu, du, DaisyDisk or CleanMyMac, or asks "what can I delete", even if they never say "cleanup".
---

# Safe disk cleanup

Free real space on a full disk without deleting anything the user would miss. Measure first, verify every candidate, then walk the user through items one at a time. Each item gets a plain explanation of what it is, why it is safe or risky, and how to get it back. Act only on the exact paths they approve.

## Why it works this way

Disk cleanup is one of the few tasks where one wrong command destroys work that exists nowhere else. The dangerous items rarely look dangerous:

- a worktree holding commits that were never pushed,
- a "backup" zip containing files the folder no longer has,
- a folder of "raw assets" that another project reaches through a symlink,
- a gitignored `.env` that `git status` never mentions,
- a cache that a running tool has locked.

Names and sizes don't tell you which is which. Only checking does. So the skill runs on three habits: **measure without touching, verify before recommending, and ask about each item separately**. The extra minutes are cheap next to losing someone's unpushed work.

## Ground rules

These rules are why a user can trust the skill on their own machine. Each one carries a reason, so you can apply it to cases not listed here.

1. **Read-only until a specific yes.** Scanning, measuring and verifying change nothing. A yes covers only the item it was asked about. "Go ahead with everything" still needs one confirmation that shows the exact list of paths, because the user can't approve what they haven't seen.
2. **Act on exactly the paths you showed.** Use no wildcards or variables you haven't expanded and printed, and no "and similar folders". If the target changes, ask again. Write every command you show or run with **absolute, quoted paths**. Mixing `cd` or `git -C` with relative paths is how a correct plan turns into a command that fails or points somewhere else.
3. **No sudo, no `--force`, no killing processes.** Anything needing root is a system change, so hand that command to the user to run themselves. A lock or a running process means something is using the data. Report it and let the user decide.
4. **No network, no installs.** Don't upload, fetch, `curl | sh` or install a "cleaner". The scripts here use only tools already on the machine. If a remote check would help (`git fetch`), ask first.
5. **Never print secrets.** Show the names of secret-looking files (`.env`, keys, credentials), never their contents. Mask tokens embedded in URLs (`https://***@host/...`).
6. **Never touch these** (see `references/safety.md`): keychains, `~/.ssh`, `~/.gnupg`, iCloud/Mobile Documents, Photos and Mail libraries, password-manager data, browser profiles (their caches are fine), app data under Application Support or `~/.config` (only named caches), `.git` folders themselves, and anything outside the user's home.
7. **Stop when something surprises you.** Examples: a folder much bigger than its contents suggest, a symlink, an unknown file type, an item modified minutes ago, a tool reporting an error. Say what you saw and ask. Don't work around it.
8. **Report what actually happened.** If a command failed or freed less than expected, say so plainly. Never claim space was freed without measuring it.

## Workflow

### 1. Measure (read-only)

```bash
df -h ~                      # free space on the user's volume
du -sh ~/* ~/.[!.]* 2>/dev/null | sort -rh | head -25   # biggest folders in home
```

On macOS the user data volume is `/System/Volumes/Data`. Its "Avail" figure is the one that matters. If `mo` (Mole) is **already installed**, `mo analyze --json` gives a machine-wide overview. Don't install it.

Tell the user the starting point in one line: how full the disk is and roughly where the space sits.

### 2. Scan (read-only)

```bash
bash <skill-dir>/scripts/scan.sh ~                  # whole home, rows of 50 MB and up
bash <skill-dir>/scripts/scan.sh --min-mb 1 ~/code  # one smaller tree
```

Scanning a folder other than home measures only that folder. Pass `--caches` to add the home-folder cache section, but only when the user wants a whole-machine look. The scanner lists project build output (node_modules, Rust `target`, Python venvs, framework caches, `dist`/`build`), git worktrees, folders of rendered or extracted frames, large media, archives and model files, and known per-user caches and toolchains. Each row has a **hint**, which points you at what to verify and is not a verdict. A rough breakdown of a full `scan.sh ~` takes a few minutes. If the user named a folder, scan only that, and mention that the real space may be elsewhere if the folder turns out small.

### 3. Verify every candidate before recommending it

This step is the reason the skill exists. Run the checks that fit the category. `references/item-catalog.md` lists them per category, together with the right delete command and the way back.

| Question | How to check |
|---|---|
| Is there work here that exists nowhere else? | `scripts/git_state.sh PATH` reports uncommitted changes, commits not on any remote, whether it is merged, ignored files git can't restore, locks, and open processes |
| Is this archive really a duplicate? | `python3 -I scripts/compare_archive.py ARCHIVE FOLDER --hash`. Exit 1 means it holds something the folder doesn't, so keep it |
| Are two files identical? | `shasum -a 256 A B` (Linux: `sha256sum`) |
| Is it tracked in git (so restorable) or ignored (so not)? | `git -C DIR ls-files PATH` and `git -C DIR check-ignore -q PATH` |
| Is it still in use? | Newest file inside, `lsof +D PATH`, `pgrep -fl NAME`, and whether it was modified today |
| Does something else point at it? | `find ~ -maxdepth 4 -type l -lname '*NAME*' 2>/dev/null`, plus a quick grep of nearby configs |
| Can it be rebuilt? | A lockfile or manifest beside it (`package.json`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`), a documented build step, or a source file beside the derived file (`.webm` next to frames) |
| Did it cost money or a long time to make? | Generated media, 3D models, ML outputs, recordings. Ask, even if it looks like a leftover |

Record what you found. You'll quote it in the item card.

### 4. Present the inventory

Group candidates into tiers, safest first, and show sizes and the total:

1. **Rebuildable build output:** node_modules, Rust `target`, venvs with a dependency file, framework caches, ignored `dist`/`build`, render frames whose output exists
2. **Worktrees and extra checkouts:** split into merged-and-pushed and holding unique work
3. **Media and generated assets:** frames, raw recordings, drafts, renders, models
4. **Archives and duplicates:** only after comparison
5. **Git compaction:** `git count-objects -vH` first. It often gains little.
6. **User caches and toolchains:** package-manager caches, model caches, emulators, browsers for testing, old toolchains, Trash

Mark each row **safe**, **check** or **risky**, with a short reason. Then ask whether to start walking through them. Let the user skip whole tiers.

### 5. One item at a time: the item card

For each item, show a card like this and ask. Use the host's question or choice tool if it has one (it makes answering a click), otherwise ask in text and wait for the reply. Don't bundle unrelated items into one question. Grouping is fine when the items share one verdict and one reason, like four stale `node_modules` folders. Even then, list every path and let the user pick individually.

When the user asks for a bulk action ("delete all node_modules and zips"), a compact table can replace the cards. It still needs one row per path, with the columns **What it is · Verdict and evidence · How to get it back · Size**. Risky rows are pulled out and recommended as Skip, and you ask for one confirmation of the exact list.

```
### <n>. <short name>: <size>
What it is:        <plain description; what created it and what it's for>
Why it's here:     <the likely reason it stayed: old build, leftover worktree, cache>
Safe or risky:     <SAFE | CHECK | RISKY>, because <evidence from step 3>
If deleted:        <what stops working or must be rebuilt, and how long that takes>
How to get it back:<exact command or "not recoverable: only copy on this disk">
Paths:             <every exact path>
Options:           Delete · Partial (<what>) · Move to Trash · Show me first · Skip
Recommendation:    <one option and one reason>
```

How to fill it in:
- **Plain language.** The user may not know what `target/` or a worktree is. Say it in a sentence, such as "the compiled output Rust keeps to make the next build faster".
- **Name the risk precisely:** "1 commit not on any remote, `feat/x`", not "may contain work".
- **Offer the partial option** when one exists. Typical cases: only `node_modules` inside a worktree, only the snapshots of an emulator, only the older of two versions, only the clips but not the rig.
- **Offer Move to Trash** for anything you're unsure of, so the user can still recover it. The trade-off is that space is freed only once the Trash is emptied.
- **Recommend Skip** when the evidence is unclear, when an item is the only copy of something finished, or when it was used in the last day. A skipped item costs nothing.

### 6. Rescue before delete

When an item is mostly disposable but holds a small unique piece, offer to save the piece first. Examples: an untracked image in a worktree, uncommitted edits, a file found only in the zip. Ways to save it:
- copy the file into the main project,
- commit on the item's own branch, locally, without pushing,
- `git diff > ~/saved-<name>.patch` for uncommitted changes,
- extract only the missing files from an archive, without overwriting anything.

Before committing, check the new files for secrets. Verify the rescue (the file exists, `git log -1` shows the commit) before deleting anything.

### 7. Act, then verify

Run only the approved action, with the safest tool for it:
- **Tool-native first:** `cargo clean`, `git worktree remove`, `uv cache prune`, `pnpm store prune`, `npm cache clean --force`, `docker system prune` (after `docker system df`), `xcrun simctl delete unavailable`, `rustup toolchain uninstall X`.
- **Otherwise `rm -rf`** on the exact quoted paths you showed.
- **Locked worktrees:** confirm the locking PID isn't running, then unlock, then remove. Work from the innermost worktree outward when they're nested.

Afterwards, check three things: the target is gone, its neighbours are intact (for a worktree, the branch still exists), and space was freed. Report the change and keep a running total. `df` can lag a few seconds on APFS, so if free space didn't move, re-check once before worrying.

If a command fails, stop and show the error. Don't retry with stronger flags.

### 8. Final report

```
Freed: <start> → <end> free (<total> recovered)
Deleted: <items, sizes>
Saved first: <rescued files/commits and where they are>
Skipped: <items, sizes, why> (still available if they decide later)
Flagged only: <large things you didn't touch, e.g. browser profile, app data>
Follow-ups: <commands only the user should run (sudo), locked caches to retry later>
```

## Platform notes

- **macOS:** caches live in `~/Library/Caches`, developer data in `~/Library/Developer`, Android SDK in `~/Library/Android`. Some folders show as unreadable without Full Disk Access. Treat those as "unknown size" and don't ask for more permissions just to measure them.
- **Linux:** caches live in `~/.cache`, Trash in `~/.local/share/Trash`, Flatpak data in `~/.var/app` (app data, so report it only). System caches (`/var/cache/apt`, `journalctl --vacuum-*`, `snap` revisions) need root, so give the user the command and let them run it.
- **Windows:** not covered yet. Say so rather than guessing paths.

## Reference files

- `references/item-catalog.md`: per category, what it is, how to verify, the delete command, the way back and typical gotchas. Read the matching section before writing an item card.
- `references/safety.md`: the never-touch list, red flags that mean stop and ask, and the reasoning behind the ground rules. Read it at the start of a session.
- `scripts/scan.sh`, `scripts/git_state.sh`, `scripts/compare_archive.py`: read-only helpers. Run them with no arguments for usage.
