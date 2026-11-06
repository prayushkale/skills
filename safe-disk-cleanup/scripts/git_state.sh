#!/usr/bin/env bash
# git_state.sh: READ-ONLY report on whether a git checkout or worktree holds
# work that exists nowhere else. Run it before removing any worktree, clone or
# project folder.
#
# Usage: git_state.sh PATH
#
# It never writes: optional git locks are disabled (no index refresh), it does
# not fetch (no network), and remote URLs are printed with credentials masked.
# "on a remote" reflects the last fetch; offer the user a fetch if it matters.

set -u
export GIT_OPTIONAL_LOCKS=0 LC_ALL=C
P="${1:?usage: git_state.sh PATH}"
g() { git -C "$P" "$@" 2>/dev/null; }

if ! g rev-parse --is-inside-work-tree >/dev/null; then
  echo "path: $P"
  echo "is_git: no (nothing in git can restore this folder)"
  exit 0
fi

mask() { sed -E 's#(https?://)[^@/]+@#\1***@#g'; }

top="$(g rev-parse --show-toplevel)"
gitdir="$(cd "$P" && git rev-parse --absolute-git-dir 2>/dev/null)"
common="$(cd "$P" && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P)"
branch="$(g branch --show-current)"; [ -z "$branch" ] && branch="(detached HEAD)"
head="$(g rev-parse --short HEAD)"

echo "path: $P"
echo "is_git: yes"
echo "toplevel: $top"
if [ "$gitdir" != "$common" ]; then
  echo "kind: linked worktree (main repo: ${common%/.git})"
else
  echo "kind: main checkout"
fi
echo "branch: $branch @ $head ($(g log -1 --format='%cd %s' --date=short | cut -c1-80))"

# Uncommitted work: exists only in this folder.
status="$(g status --porcelain)"
dirty=$(printf '%s' "$status" | grep -c . || true)
untracked=$(printf '%s\n' "$status" | grep -c '^??' || true)
echo "uncommitted_changes: $dirty (untracked: $untracked)"
[ "$dirty" -gt 0 ] && printf '%s\n' "$status" | head -15 | sed 's/^/  /'

# Gitignored files are invisible to "git status" but are lost with the folder
# (.env files, local data, notes). Rebuildable folders are left out.
ignored="$(g status --porcelain --ignored | grep '^!!' | cut -c4- |
  grep -vE '(^|/)(node_modules|\.venv|venv|target|dist|build|\.next|\.turbo|__pycache__|\.pytest_cache|\.cache|\.DS_Store)(/|$)' || true)"
ign_n=$(printf '%s' "$ignored" | grep -c . || true)
echo "ignored_files_not_rebuildable: $ign_n (git cannot restore these)"
[ "$ign_n" -gt 0 ] && printf '%s\n' "$ignored" | head -10 | sed 's/^/  /'
secrets="$(printf '%s\n' "$ignored" | grep -iE '(^|/)(\.env(\..*)?|.*\.pem|.*\.key|id_rsa.*|id_ed25519.*|credentials.*|.*secret.*|.*\.p12)$' || true)"
[ -n "$secrets" ] && echo "secret_looking_files: $(printf '%s' "$secrets" | tr '\n' ' ')(names only; do not print contents)"

# Remotes.
remotes="$(g remote)"
if [ -z "$remotes" ]; then
  echo "remotes: none (history exists only on this disk)"
else
  for r in $remotes; do echo "remote: $r $(g remote get-url "$r" | mask)"; done
fi

# Is HEAD's history somewhere else?
up="$(g rev-parse --abbrev-ref --symbolic-full-name '@{u}')"
if [ -n "$up" ]; then
  echo "upstream: $up | ahead: $(g rev-list --count "$up..HEAD") | behind: $(g rev-list --count "HEAD..$up")"
else
  echo "upstream: none"
fi
on_remote=$(g branch -r --contains HEAD | grep -c . || true)
echo "head_on_a_remote_branch: $([ "$on_remote" -gt 0 ] && echo yes || echo NO)"
not_pushed=$(g rev-list --count HEAD --not --remotes)
echo "commits_not_on_any_remote: ${not_pushed:-unknown}"

# Merged into the default branch?
def=""
for c in "$(g symbolic-ref --short refs/remotes/origin/HEAD)" main master trunk develop; do
  [ -n "$c" ] && g rev-parse --verify -q "$c" >/dev/null && def="$c" && break
done
if [ -n "$def" ]; then
  if g merge-base --is-ancestor HEAD "$def"; then
    echo "merged_into_$def: yes"
  else
    echo "merged_into_$def: NO ($(g rev-list --count "$def..HEAD") commits not in $def)"
  fi
fi

# Stashes live in the main repo, but say so: removing the main repo loses them.
stashes=$(g stash list | grep -c . || true)
[ "$stashes" -gt 0 ] && echo "stashes: $stashes (kept in the main repo)"

# Linked worktree lock, and whether the locking process still runs.
if [ -f "$gitdir/locked" ]; then
  reason="$(cat "$gitdir/locked")"
  echo "locked: yes (${reason:-no reason given})"
  pid="$(printf '%s' "$reason" | grep -oE 'pid[= ]?[0-9]+' | grep -oE '[0-9]+' | head -1)"
  if [ -n "$pid" ]; then
    if ps -p "$pid" >/dev/null 2>&1; then echo "lock_pid_$pid: RUNNING (leave this worktree alone)"; else echo "lock_pid_$pid: not running"; fi
  fi
fi

# A main checkout lists its worktrees: each needs its own check.
if [ "$gitdir" = "$common" ]; then
  n=$(g worktree list | grep -c . || true)
  if [ "$n" -gt 1 ]; then
    echo "worktrees_of_this_repo:"
    g worktree list | sed 's/^/  /'
  fi
fi

# Anything holding files open inside (an editor, a dev server, an agent).
if command -v lsof >/dev/null 2>&1; then
  holders="$(lsof +D "$P" 2>/dev/null | awk 'NR>1 {print $1"("$2")"}' | sort -u | head -5 | tr '\n' ' ')"
  echo "open_by_processes: ${holders:-none}"
fi
