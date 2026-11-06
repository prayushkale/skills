# Safety

Read this at the start of a cleanup. The rules exist because every one of them guards against a loss that has actually happened.

## The contract with the user

- Nothing changes until they say yes **to that item**. Scans and checks are read-only by construction. The bundled scripts contain no delete commands and write nothing, not even temp files.
- They always see **exact paths** before deciding. They also hear what each item is, why it's safe or risky, and how to get it back.
- "Skip" is always an option, and it's the default recommendation whenever the evidence is unclear.
- No sudo, no installs, no network, no uploads. The skill uses tools already on the machine and only reads data.
- Secrets are named, never shown.

If the user asks you to break one of these ("just delete it all", "use sudo", "force it"), explain the risk in one sentence and offer the safe equivalent: one confirmation with the full list, a command for them to run themselves, or waiting until the lock is free. Their machine, their call, but they decide with the facts in front of them.

## Never touch

| Area | Why |
|---|---|
| `~/Library/Keychains`, password-manager data | credentials; not recoverable |
| `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config/gcloud`, `~/.kube`, `~/.docker/config.json` | keys and cloud credentials |
| iCloud Drive / `~/Library/Mobile Documents`, Dropbox/OneDrive/Google Drive folders | deleting there deletes everywhere it syncs |
| Photos library, Mail, Messages, Notes data | personal data with no second copy |
| Browser profiles (bookmarks, passwords, history) | only their *cache* folders are fair game |
| `~/Library/Application Support/*`, `~/.config/*`, `~/.local/share/*` app data | app state and documents; flag the size, don't delete |
| `.git` folders | the repository itself |
| `/System`, `/usr`, `/bin`, `/etc`, `/var`, `/Library` (system), `/opt` | system files; root-owned for a reason |
| Anything outside the user's home | not theirs to clean in this session |

Large items in these areas belong in the **flagged only** list of the final report, with a pointer to the app's own cleanup option.

## Red flags: stop and ask

- `git_state.sh` reports any uncommitted changes, ignored-but-unique files, commits not on a remote, or a running lock PID.
- `compare_archive.py` says KEEP or CHECK, or lists secret-looking files.
- The item was modified within the last day, or a process holds files inside it (`lsof +D`).
- A symlink anywhere points into it, or it is itself a symlink. Never `rm -rf` through a symlink you haven't resolved.
- Its contents don't match its name: a "cache" holding documents, or a "tmp" holding a database.
- It looks personal: people's names, photos, IDs, financial documents. Don't open it to find out.
- It looks like an employer's or client's code or data.
- A command errors, or frees much less space than expected.
- You're about to delete more than about 5 GB in one action. Re-show the list.

## Command hygiene

- Quote every path: `rm -rf "/exact/path"`. Never build a delete target from an unset or unchecked variable. `rm -rf "$DIR/"*` with an empty `$DIR` is a classic disaster.
- No globs in delete commands unless you printed the expansion and the user saw it.
- One target, or a short explicit list, per command, so a failure is easy to read.
- Prefer the tool's own cleanup command (cargo, uv, pnpm, docker, rustup, xcrun). They know what's safe to drop.
- Don't use `--force` to get past a lock, and don't kill processes holding files. Report it and let the user close the tool.
- Mask credentials in anything you print: `sed -E 's#(https?://)[^@/]+@#\1***@#g'`.
- Afterwards, verify the target is gone, its neighbours are intact, and space was freed. Report the real numbers.

## Move to Trash instead of deleting

For uncertain items, offer a recoverable delete:
- macOS: `mv "/exact/path" ~/.Trash/`, or the `trash` command if it's already installed. The user can restore it in Finder.
- Linux: `gio trash "/exact/path"` (GNOME/most desktops).

The space comes back only when the Trash is emptied, so say that. It's the right choice when the user hesitates.

## Being honest about recoverability

Use one of these phrases, and only when it's true:
- "Rebuilds automatically" (caches, build output)
- "Reinstall with `<command>`" (dependencies, toolchains), plus the time or download it costs
- "Restorable from git with `<command>`" (tracked files, pushed branches)
- "Recoverable from Trash until it's emptied"
- "**Not recoverable**: this is the only copy on this disk"

If you aren't sure which applies, say you aren't sure. That's itself a reason to recommend Skip.
