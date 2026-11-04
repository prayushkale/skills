---
name: git-branch-commit-pr
description: "Ship uncommitted changes end to end: create (or reuse) a branch, commit, push, and open a pull request with the gh CLI. Use when the user says 'ship this', 'commit and push', 'open a PR', 'branch, commit and PR', or otherwise wants the working tree turned into a PR in one step."
---

# Branch, Commit, Push, PR

Take a dirty working tree to "PR open against the base branch" using `git` and `gh`.

## 1. Preflight

Run these and stop on any failure:

```bash
gh auth status                      # not authenticated -> ask the user to run `gh auth login`
git status --short                  # empty -> say the tree is clean; do not create an empty commit
git rev-parse --abbrev-ref HEAD     # "HEAD" means detached -> stop and ask
ls .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply 2>/dev/null   # anything listed -> merge/rebase in progress, stop
```

Detect the base branch instead of assuming `main`:

```bash
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null \
  || git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
```

Also run `git log --oneline -10` and `git branch --merged "$BASE"`. Report stale merged branches, but never delete them without asking.

## 2. Branch

- On the base branch: create a new branch **before** committing with `git checkout -b <branch>`; the changes carry over.
- Already on a non-base feature branch that fits this work: reuse it.
- Name: `<type>/<id>-<kebab-title>` when an issue or work-item ID is known, else `<type>/<kebab-title>`.
- `<type>` is one of `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. Use lowercase kebab-case, and only hyphens as special characters.

## 3. Stage and scan

Run `git status --short`, then stage explicit paths. Use `git add -A` only when every changed file is clearly part of this work. Before committing, check the staged set:

```bash
git diff --staged --name-only | grep -iE '(^|/)\.env|\.pem$|\.key$|id_rsa|credentials|secrets?\.' 
git diff --staged --name-only | grep -E '(^|/)(node_modules|dist|build|\.next)/'
git diff --staged --numstat | awk '$1 == "-"'    # binary files; also check sizes over ~5 MB
git diff --staged | grep -iE '(api[_-]?key|secret|token|password)\s*[:=]\s*\S{8,}'
```

Any hit means stop, unstage it (`git restore --staged <path>`), and tell the user. Show `git diff --staged --stat` before committing.

## 4. Commit

Format: Conventional Commits, `<type>(<scope-or-id>): <imperative summary>`, summary 72 characters or fewer. Add a body explaining *why* when the change is non-trivial. If `git log` shows the repo uses another convention, match it.

```bash
git commit -m "<subject>" -m "<body>"
```

If a pre-commit hook fails, fix the problem and create a **new** commit. Never use `--no-verify`, and never amend a commit that has already been pushed.

## 5. Push

```bash
git push -u origin <branch>
```

Never force-push. For a fork workflow (the remote is not writable), push to the user's fork and open the PR with `--head <owner>:<branch>`.

## 6. Pull request

If a PR already exists (`gh pr view --json url -q .url`), report its URL instead of creating a duplicate. Otherwise:

```bash
gh pr create --base "$BASE" --head <branch> --title "<subject>" --body "$(cat <<'EOF'
## Summary
<1-3 sentences: what and why>

## Changes
- <key change>

## Test plan
- [x] <check that was actually run>
- [ ] <check not run>

Closes #<issue>   (only if an issue ID is known)
EOF
)"
```

- One commit: use its subject as the title. Several commits: write a title that summarizes them.
- Add `--draft` if the user asks, or if the tests were not run.
- List only checks you really ran in the test plan.

## 7. Report

Give the PR URL, branch, commit SHA, and anything skipped or flagged.

## Rules

- Never delete branches, force-push, or rewrite history without explicit confirmation.
- Never commit secrets, credentials, or `.env` files.
- If the user only asked to commit, stop after step 4. Pushing and opening a PR are outward-facing and need their go-ahead.
- Never use `--no-verify`.

## Examples

```text
feat(auth): add password reset endpoint
fix(#142): handle empty cart on checkout
docs: update install instructions
```

Branches: `feat/142-password-reset`, `fix/handle-empty-cart`.
