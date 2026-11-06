# Item catalog

Per category: what it is, how to verify it, how to delete it, how to get it back, and the gotchas seen in real cleanups. Read the matching section before writing an item card.

## Contents
1. Project build output: node_modules, Rust target, venvs, framework caches, dist/build
2. Git worktrees and extra checkouts
3. Render frames, raw recordings, generated media and models
4. Archives and duplicate files
5. Git repository size
6. Package-manager caches
7. Model caches (Hugging Face, torch, Ollama, whisper)
8. Toolchains, emulators and SDKs
9. Browser and test-browser caches, app caches
10. Containers and VMs
11. Downloads, installers and Trash
12. Linux system areas (root only, so hand these to the user)

---

## 1. Project build output

**node_modules**
- What: downloaded JavaScript dependencies for a project.
- Verify: `package.json` and a lockfile sit beside it. Check when the project was last edited, since a recently used project means a reinstall soon. A `node_modules` inside a worktree counts as part of that worktree's decision.
- Delete: `rm -rf "<project>/node_modules"`
- Back: `npm install` / `pnpm install` / `yarn` / `bun install` (minutes, needs network).
- Gotchas: copies of the same project (`app-2`, `app-final`) often each carry their own node_modules, which makes them a good place to start. Monorepos can have one per package.

**Rust `target/`**
- What: compiled output and incremental build cache. It's often several GB per project.
- Verify: `Cargo.toml` beside it. Nothing else is needed.
- Delete: `cargo clean` from the project folder (it prints the amount removed).
- Back: the next `cargo build` recompiles everything, which is slow on big projects.

**Python virtualenvs (`.venv`, `venv`, `env` containing `pyvenv.cfg`)**
- What: installed Python packages for one project.
- Verify: **is there a dependency file** (`pyproject.toml`, `uv.lock`, `requirements*.txt`, `poetry.lock`, `Pipfile`)? Without one, deleting loses the record of what was installed, so mark it CHECK and offer `pip freeze > requirements.txt` first. Also check the Python version in `pyvenv.cfg`.
- Delete: `rm -rf "<project>/.venv"`
- Back: `uv sync`, `pip install -r requirements.txt` or `poetry install`.

**Framework caches** (`.next`, `.nuxt`, `.turbo`, `.parcel-cache`, `.svelte-kit`, `.vite`, `.angular`, `.expo`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`, `.tox`, Xcode `DerivedData`)
- What: build or test caches. The tool rebuilds them on the next run.
- Verify: nothing beyond "not currently building".
- Delete: `rm -rf` on the folder. For Xcode, quit Xcode first.

**`dist/`, `build/`, `out/`**
- What: usually build output, but **not always**. Sometimes it's a committed deliverable (a report PDF, a published bundle), a deploy source, or Gradle/Android build trees with release artifacts.
- Verify: `git -C <project> ls-files <dir> | head`. Tracked files make it CHECK (restorable from git, but someone chose to commit them). Look at what's inside, because a lone PDF or a release `.apk`/`.aab` is a deliverable.
- Delete: `rm -rf` the folder (only the ignored ones by default).
- Back: the project's build command. Tracked files come back with `git checkout -- <dir>`.

## 2. Git worktrees and extra checkouts

- What: extra working folders for the same repository, often made by AI coding agents or task tools (`.worktrees/`, `.claude/worktrees/`, `~/.cursor/worktrees/` and similar). Each carries its own node_modules and build output, so they add up fast.
- Verify with `scripts/git_state.sh <worktree>`:
  - `uncommitted_changes` above 0 means edits that exist only here.
  - `ignored_files_not_rebuildable` covers files like `.env`, local data and notes. git can't restore them.
  - `commits_not_on_any_remote` above 0 means history that exists only on this disk. Removing the worktree keeps the branch, so the commits survive, but say so explicitly.
  - `merged_into_<default>: yes` combined with nothing above means **safe**.
  - `locked: yes` with a running lock PID means an agent or tool is using it, so leave it. With a dead PID it's stale.
  - `open_by_processes` lists an editor, dev server or agent session working in it.
  - Modified in the last few hours suggests a session may still be active, so recommend Skip.
- Delete: `git -C <main-repo> worktree remove <path>` (add `--force` only when the user approved losing the listed uncommitted or ignored files). For locked ones, `git worktree unlock <path>` first. With nested worktrees, start from the innermost.
- Partial: delete only `<worktree>/node_modules` (and other build output). That frees most of the space and keeps every file of work.
- Back: `git worktree add <path> <branch>` recreates it from the branch, but not the uncommitted or ignored files.
- Gotchas: "merged" is only as fresh as the last fetch, so say "as of the last fetch". A worktree folder can also exist without git knowing about it, which is why `git worktree prune` is a separate cleanup that frees no space. A plain clone (not a worktree) gets the same checks.

## 3. Render frames, recordings, generated media and models

**Frames** (hundreds or thousands of PNG/JPG/EXR files in one folder)
- What: either render frames (a video was assembled from them) or extracted frames (pulled from a video for analysis or compositing).
- Verify: does the output video exist (`*.mp4` beside it)? Does the source video exist? Does code read the frames at render time (grep the project for the folder name)? Is there a script that regenerates them? Did a render happen today, which would mean they may still be needed?
- Delete: `rm -rf "<frames dir>"`. Recreate an empty folder if code expects it to exist.
- Back: re-render, or re-extract with ffmpeg. Say plainly if the exact extraction settings aren't recorded anywhere.

**Raw recordings and drafts** (`.mov`/`.mp4` screen recordings, `draft-*`, `v1/v2/scoreA/scoreB` variants)
- Verify: is there an edited or final version beside it? Is it tracked in git, or published somewhere the user can confirm? Variants usually differ in one choice (music, cut), so ask which one they kept.
- Default: **Skip** unless the user confirms the final is published. Raw sources are often the only way to re-edit.

**Generated assets** (3D models, AI-generated images, audio or video, upscales)
- Verify: notes like `CREDITS.md`, cost logs or job IDs, which mean it cost money to make. Check for symlinks from other projects (`find ~ -maxdepth 4 -type l -lname '*<folder>*'`) and superseded versions kept on purpose.
- Default: CHECK. Offer only clearly superseded subsets, and say what regenerating would cost.

**ML model files** (`.safetensors`, `.gguf`, `.ckpt`, `.pth`)
- Verify: is this a training output (unique) or a downloaded checkpoint (re-downloadable)? Look at the folder name and any run logs.

## 4. Archives and duplicate files

- What: zips or tarballs, often "backups" of a folder that still exists.
- Verify: `python3 -I scripts/compare_archive.py <archive> <folder> --hash`.
  - Exit 0, "contained", means every file is present with identical content, so the archive is redundant.
  - Exit 1, "KEEP", lists files found only in the archive. Those are the only copy.
  - "CHECK" means the same files with different content. The folder is usually newer, but say so.
  - "secret-looking files inside" means the archive holds credentials. Deleting is fine, but never extract or print them.
- A folder that changed since the archive was made doesn't make the archive redundant. The archive may be the only snapshot of the old state, so ask whether they want it.
- Split archives (`name.zip.part-aa`, `-ab`): `cat parts... | shasum -a 256` and compare with the whole file.
- Backups of other people's or an employer's code: check the git remotes inside without extracting (`unzip -p a.zip 'Proj/.git/config'`) and mask URL tokens. Local-only repos inside a backup aren't recoverable. Default: Skip.
- Duplicate single files: `shasum -a 256 a b`. Delete only the copy outside the project.
- Delete: `rm "<archive>"`. Offer Move to Trash when unsure.

## 5. Git repository size

- Measure first: `git -C <repo> count-objects -vH` (read-only).
  - Many loose objects (`count`, `size`) means `git gc` helps, and is safe.
  - Already packed (`count: 0`, a couple of packs) means `git gc` gains almost nothing.
  - A huge pack holding few objects means large binaries are committed in history. Only rewriting history (git filter-repo) shrinks that, and it's disruptive. Mention it, don't do it.
- Delete: `git -C <repo> gc` (plain, not `--prune=now`, so recent unreachable objects survive).

## 6. Package-manager caches

| Tool | Location | Prefer | Notes |
|---|---|---|---|
| uv | `~/.cache/uv` | `uv cache prune` (unused only) / `uv cache clean` (all) | Fails if another uv process holds the lock. Don't use `--force`. Report which process holds it. |
| pip | `~/.cache/pip`, `~/Library/Caches/pip` | `pip cache purge` | |
| npm | `~/.npm/_cacache` | `npm cache clean --force` | `--force` is npm's required flag here, not a lock bypass |
| pnpm | `~/Library/pnpm/store`, `~/.local/share/pnpm/store`, `~/.pnpm-store` | `pnpm store prune` | Removes only packages no project references |
| yarn | `~/Library/Caches/Yarn`, `~/.yarn/berry/cache` | `yarn cache clean` | |
| bun | `~/.bun/install/cache` | `bun pm cache rm` | |
| cargo | `~/.cargo/registry`, `~/.cargo/git` | `rm -rf ~/.cargo/registry/src` (extracted sources), or `cargo cache -a` if installed | `registry/cache` holds the downloads |
| Gradle | `~/.gradle/caches` | `rm -rf ~/.gradle/caches` with no Gradle daemon running | Keep `~/.gradle/wrapper` to avoid re-downloading Gradle itself |
| Maven | `~/.m2/repository` | `rm -rf` specific old groups | Offline builds break |
| Go | `~/go/pkg/mod` | `go clean -modcache` | |
| Homebrew | `$(brew --cache)` | `brew cleanup --prune=all` | Also removes old formula versions |

All of these come back automatically on the next install or build, with network.

## 7. Model caches

- Hugging Face `~/.cache/huggingface/hub`: one `models--org--name` folder per model. Newer clients may also keep a shared `blobs/` folder at the hub level, where `<hash>.refs` files name the owning model. `du` each model folder **and** its blobs, because folder sizes alone can under-count by GBs. Delete per model: the model folder plus its blob files. Last-access dates help to pick.
- torch `~/.cache/torch/hub`, whisper `~/.cache/whisper`, and similar: re-download on next use.
- Ollama `~/.ollama/models`: `ollama rm <model>`. Very large and slow to re-pull.
- Always tell the user the re-download size. Several GB on a slow connection is a real cost.

## 8. Toolchains, emulators and SDKs

- **Rust:** `rustup show` shows the default. Look for `rust-toolchain*` files that pin versions in projects. Remove extras with `rustup toolchain uninstall <name>`.
- **Node** (nvm, fnm, volta) and **Python** (pyenv, uv-managed Pythons): list the versions, check which ones projects pin (`.nvmrc`, `.python-version`), and remove the unused ones with the manager's own command.
- **Android emulator** `~/.android/avd/<name>.avd`: `snapshots/` holds quick-boot states. That part is the safest to delete, because the emulator just cold-boots. `userdata-qemu.img*` holds the virtual phone's apps and data, which is lost with the whole AVD. Check that the emulator isn't running (`pgrep -fl qemu`).
- **Android SDK system images** `.../sdk/system-images`: re-downloadable through the SDK manager. Keep any image that an AVD you're keeping uses.
- **Xcode:** `xcrun simctl delete unavailable` removes simulators for runtimes that are gone. `~/Library/Developer/Xcode/iOS DeviceSupport` holds per-device-OS symbols, which come back when the device reconnects. `~/Library/Developer/Xcode/Archives` holds **shipped app builds**, so it's CHECK.

## 9. Browser and app caches

- **Playwright** `ms-playwright/`: one folder per browser revision. Older revisions may still be pinned by a project, and `npx playwright install` restores them. Delete older revisions first.
- **Browser profiles** (Chrome, Firefox and so on): never delete the profile. Their caches are cleared from inside the browser, or with a cleaner the user already has, with the browser closed.
- **App caches** (`~/Library/Caches/<bundle-id>`, `~/.cache/<app>`): usually rebuilt. Quit the app first. Leftover updater downloads (`*.ShipIt`, `*-updater`) are safe once no update is in progress.
- Apple system caches (Spotlight, fonts, CloudKit, Finder): leave them alone. macOS manages them.

## 10. Containers and VMs

- Docker or OrbStack: run `docker system df` first, which shows images, containers, volumes and build cache. `docker system prune` removes stopped containers, dangling images and build cache. **Volumes hold data** (databases), so `--volumes` needs its own explicit yes per volume. If the daemon isn't running, report "not measured".
- VM disk images (UTM, Parallels, VirtualBox, Multipass): each is a whole machine. Treat it as user data.

## 11. Downloads, installers and Trash

- Downloads: sort by size, not age. Old files are often tiny receipts and documents. Check big items against copies in projects (`shasum`). Installers (`.dmg`, `.pkg`, `.iso`) for apps already installed can go.
- Personal-looking folders or files (names, photos, documents): don't open them to find out. Ask the user what they are.
- Trash: emptying is permanent, so ask once with the size. `mo clean` and similar tools may skip it without Full Disk Access.

## 12. Linux system areas (give the command, the user runs it)

- `sudo apt-get clean` (`/var/cache/apt/archives`), `sudo dnf clean all`, `sudo pacman -Sc`
- `sudo journalctl --vacuum-size=200M` (systemd journal)
- `snap list --all`: old disabled revisions can be removed with `sudo snap remove <name> --revision <rev>`
- `flatpak uninstall --unused` (removes unused runtimes; no sudo needed for user installs)
