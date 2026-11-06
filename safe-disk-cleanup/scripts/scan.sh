#!/usr/bin/env bash
# scan.sh: READ-ONLY disk-space inventory for macOS and Linux.
#
# It only measures and lists. It never deletes, moves, renames, or writes
# anything (not even temp files), and it makes no network calls.
#
# Usage:
#   scan.sh [--min-mb N] [--no-caches] [ROOT ...]
#     ROOT        folders to scan for project artifacts (default: $HOME)
#     --min-mb N  hide rows smaller than N MB (default: 50)
#     --no-caches skip the known user-cache locations section
#     --caches    include it even when ROOT is not the home folder
#   The cache section (which lives under $HOME) runs only when a ROOT is the
#   home folder itself, so scanning one project never measures anything else.
#
# Output: tab-separated rows sorted by size, largest first:
#   size_mb  category  hint  modified  path
# The hint is a pointer for the verify step, not a verdict. Nothing here
# means "safe to delete" on its own.

set -u
export LC_ALL=C

MIN_MB=50
CACHES=auto
ROOTS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --min-mb) MIN_MB="${2:-50}"; shift 2 ;;
    --no-caches) CACHES=0; shift ;;
    --caches) CACHES=1; shift ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) ROOTS+=("$1"); shift ;;
  esac
done
[ ${#ROOTS[@]} -eq 0 ] && ROOTS=("$HOME")
if [ "$CACHES" = auto ]; then
  CACHES=0
  home_real="$(cd "$HOME" && pwd -P)"
  for r in "${ROOTS[@]}"; do
    [ -d "$r" ] && [ "$(cd "$r" && pwd -P)" = "$home_real" ] && CACHES=1
  done
fi

OS="$(uname -s)"

# Unreadable folders (macOS privacy protection, permissions) count as 0 and are skipped.
size_kb() { du -sk "$1" 2>/dev/null | awk '{s=$1+0} END{print s+0}'; }

modified() {
  if [ "$OS" = "Darwin" ]; then
    stat -f '%Sm' -t '%Y-%m-%d' "$1" 2>/dev/null
  else
    stat -c '%y' "$1" 2>/dev/null | cut -c1-10
  fi
}

# Newest file inside a folder (better signal of "still in use" than the folder's own date).
newest_inside() {
  local d="$1" n
  if [ "$OS" = "Darwin" ]; then
    n=$(find "$d" -maxdepth 3 -type f -not -path '*/node_modules/*' -not -path '*/.git/*' \
          -exec stat -f '%Sm' -t '%Y-%m-%d' {} + 2>/dev/null | sort -r | head -1)
  else
    n=$(find "$d" -maxdepth 3 -type f -not -path '*/node_modules/*' -not -path '*/.git/*' \
          -printf '%TY-%Tm-%Td\n' 2>/dev/null | sort -r | head -1)
  fi
  [ -n "$n" ] && echo "$n" || modified "$d"
}

row() { # size_kb category hint path [date]
  local kb="${1:-0}" cat="$2" hint="$3" path="$4" date="${5:-}"
  case "$kb" in ''|*[!0-9]*) kb=0 ;; esac
  [ "$kb" -eq 0 ] && return 0
  [ "$kb" -lt $(( MIN_MB * 1024 )) ] && return 0
  local mb; mb=$(awk -v k="$kb" 'BEGIN{printf "%.1f", k/1024}')
  [ -z "$date" ] && date="$(modified "$path")"
  printf '%s\t%s\t%s\t%s\t%s\n' "$mb" "$cat" "$hint" "$date" "$path"
}

# Folders we never descend into while looking for project artifacts.
# System and app-data areas are reported (if at all) by the cache section only.
PRUNE_NAMES=( .git Library .Trash .cache .local .cargo .rustup .npm .pnpm-store .gradle
              .android .m2 .nvm .pyenv .docker .orbstack snap .var Applications
              "Mobile Documents" "Photos Library.photoslibrary" )

# find(1) arguments for "( -name A -o -name B ... )", built as an array (no eval).
PRUNE=( '(' )
for n in "${PRUNE_NAMES[@]}"; do
  [ ${#PRUNE[@]} -gt 1 ] && PRUNE+=( -o )
  PRUNE+=( -name "$n" )
done
PRUNE+=( ')' )

scan_artifacts() {
  local root="$1"
  find "$root" "${PRUNE[@]}" -prune -o -type d \( \
      -name node_modules -o -name target -o -name .venv -o -name venv -o -name env \
      -o -name .next -o -name .nuxt -o -name .turbo -o -name .parcel-cache \
      -o -name .svelte-kit -o -name .vite -o -name .angular -o -name .expo \
      -o -name DerivedData -o -name dist -o -name build -o -name out \
      -o -name .pytest_cache -o -name .mypy_cache -o -name .ruff_cache -o -name .tox \
      -o -name worktrees -o -name .worktrees \
      \) -print -prune 2>/dev/null |
  while IFS= read -r d; do
    local name parent kb
    name="$(basename "$d")"; parent="$(dirname "$d")"
    case "$name" in
      node_modules)
        row "$(size_kb "$d")" node_modules "rebuildable: npm/pnpm/yarn install" "$d" "$(newest_inside "$parent")" ;;
      target)
        if [ -f "$parent/Cargo.toml" ] || [ -d "$d/debug" ] || [ -d "$d/release" ]; then
          row "$(size_kb "$d")" rust-target "rebuildable Rust build output of $(basename "$parent") (see catalog)" "$d" "$(newest_inside "$parent")"
        fi ;;
      .venv|venv|env)
        if [ -f "$d/pyvenv.cfg" ]; then
          local dep="NO dependency file: verify before deleting"
          for f in pyproject.toml uv.lock requirements.txt poetry.lock Pipfile setup.py; do
            [ -f "$parent/$f" ] && dep="recreatable from $f" && break
          done
          row "$(size_kb "$d")" python-venv "$dep" "$d" "$(newest_inside "$parent")"
        fi ;;
      .next|.nuxt|.turbo|.parcel-cache|.svelte-kit|.vite|.angular|.expo|.pytest_cache|.mypy_cache|.ruff_cache|.tox)
        row "$(size_kb "$d")" build-cache "rebuildable cache" "$d" ;;
      DerivedData)
        row "$(size_kb "$d")" build-cache "rebuildable Xcode build data" "$d" ;;
      dist|build|out)
        # Often rebuildable, but sometimes a deliverable or tracked in git.
        row "$(size_kb "$d")" build-output "verify: may be tracked in git or a deliverable" "$d" ;;
      worktrees|.worktrees)
        for w in "$d"/*; do
          [ -d "$w" ] || continue
          row "$(size_kb "$w")" worktree "verify with git_state.sh: may hold unpushed work" "$w" "$(newest_inside "$w")"
        done ;;
    esac
  done
}

# Git worktrees and submodules carry a .git FILE (not a folder). Catches worktrees
# living outside a "worktrees" folder.
scan_linked_worktrees() {
  local root="$1"
  find "$root" \( -name node_modules -o -name Library -o -name .Trash -o -name worktrees -o -name .worktrees \) -prune \
       -o -name .git -type f -print 2>/dev/null |
  while IFS= read -r g; do
    local w; w="$(dirname "$g")"
    if grep -q 'worktrees/' "$g" 2>/dev/null; then
      row "$(size_kb "$w")" worktree "verify with git_state.sh: may hold unpushed work" "$w" "$(newest_inside "$w")"
    fi
  done
}

# Folders holding many images: rendered or extracted video frames.
scan_frames() {
  local root="$1"
  find "$root" "${PRUNE[@]}" -prune -o -name node_modules -prune -o -type f \( \
       -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.exr' -o -iname '*.tif' -o -iname '*.tiff' \
       \) -print 2>/dev/null |
  sed 's#/[^/]*$##' | sort | uniq -c | awk '$1>=300 {c=$1; $1=""; sub(/^ /,""); print c "\t" $0}' |
  while IFS="$(printf '\t')" read -r count d; do
    row "$(size_kb "$d")" frames "$count images: render/extracted frames? check the source video exists" "$d"
  done
}

# Single large files. Archives, media, installers and models are listed from
# --min-mb up; any other file only from 100 MB (or --min-mb if higher).
scan_large_files() {
  local root="$1"
  local any=$(( MIN_MB > 100 ? MIN_MB : 100 ))
  local known=( \( -iname '*.zip' -o -iname '*.tar' -o -iname '*.gz' -o -iname '*.tgz' -o -iname '*.bz2' \
      -o -iname '*.xz' -o -iname '*.7z' -o -iname '*.rar' -o -iname '*.dmg' -o -iname '*.iso' -o -iname '*.pkg' \
      -o -iname '*.img' -o -iname '*.mp4' -o -iname '*.mov' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.avi' \
      -o -iname '*.wav' -o -iname '*.aif' -o -iname '*.aiff' -o -iname '*.flac' -o -iname '*.mp3' -o -iname '*.m4a' \
      -o -iname '*.glb' -o -iname '*.gltf' -o -iname '*.fbx' -o -iname '*.blend' -o -iname '*.usdz' \
      -o -iname '*.safetensors' -o -iname '*.gguf' -o -iname '*.ckpt' -o -iname '*.pt' -o -iname '*.pth' -o -iname '*.onnx' \) )
  {
    if [ "$MIN_MB" -gt 0 ]; then
      find "$root" "${PRUNE[@]}" -prune -o -name node_modules -prune -o -type f "${known[@]}" -size +"${MIN_MB}M" -print 2>/dev/null
    else
      find "$root" "${PRUNE[@]}" -prune -o -name node_modules -prune -o -type f "${known[@]}" -size +0 -print 2>/dev/null
    fi
    find "$root" "${PRUNE[@]}" -prune -o -name node_modules -prune -o -type f -size +"${any}M" -print 2>/dev/null
  } | awk '!seen[$0]++' |
  while IFS= read -r f; do
    local ext hint cat
    ext="$(printf '%s' "${f##*.}" | tr '[:upper:]' '[:lower:]')"
    case "$ext" in
      zip|tar|gz|tgz|bz2|xz|7z|rar) cat=archive;    hint="verify with compare_archive.py: may hold files found nowhere else" ;;
      dmg|iso|pkg|img)              cat=installer;  hint="installer/disk image: usually re-downloadable" ;;
      mp4|mov|mkv|webm|avi|wav|aif|aiff|flac|mp3|m4a) cat=media; hint="media: may be a raw source or the only copy of a final" ;;
      glb|gltf|fbx|blend|usdz|safetensors|gguf|ckpt|pt|pth|onnx) cat=model; hint="model/3D asset: may be costly to regenerate" ;;
      *)                            cat=large-file; hint="large file: check what it is" ;;
    esac
    row "$(size_kb "$f")" "$cat" "$hint" "$f"
  done
}

# Known per-user cache and tool locations. Existence + size only.
scan_caches() {
  local H="$HOME" p
  local -a paths=(
    "$H/.cache/huggingface|model-cache|re-downloads on next use (can be GBs)"
    "$H/.cache/torch|model-cache|re-downloads on next use"
    "$H/.cache/whisper|model-cache|re-downloads on next use"
    "$H/.cache/uv|package-cache|prefer: uv cache prune"
    "$H/.local/share/uv|toolchain|uv-managed Python installs and tools"
    "$H/.cache/pip|package-cache|prefer: pip cache purge"
    "$H/.cache/pypoetry|package-cache|poetry cache"
    "$H/.npm/_cacache|package-cache|prefer: npm cache clean --force"
    "$H/.pnpm-store|package-cache|prefer: pnpm store prune"
    "$H/Library/pnpm/store|package-cache|prefer: pnpm store prune"
    "$H/.local/share/pnpm/store|package-cache|prefer: pnpm store prune"
    "$H/.yarn/berry/cache|package-cache|prefer: yarn cache clean"
    "$H/Library/Caches/Yarn|package-cache|prefer: yarn cache clean"
    "$H/.bun/install/cache|package-cache|bun install cache (see catalog for the command)"
    "$H/.cargo/registry|package-cache|crate downloads; cargo re-fetches"
    "$H/.cargo/git|package-cache|git deps; cargo re-fetches"
    "$H/.gradle/caches|package-cache|Gradle re-downloads"
    "$H/.m2/repository|package-cache|Maven re-downloads"
    "$H/go/pkg/mod|package-cache|prefer: go clean -modcache"
    "$H/.ollama/models|model-cache|local LLMs: large, slow to re-pull"
    "$H/.android/avd|emulator|Android emulator devices (snapshots are the safest part)"
    "$H/Library/Android/sdk/system-images|toolchain|Android system images"
    "$H/Android/Sdk/system-images|toolchain|Android system images"
    "$H/Library/Developer/Xcode/DerivedData|build-cache|rebuildable Xcode build data"
    "$H/Library/Developer/Xcode/iOS DeviceSupport|toolchain|re-created when a device connects"
    "$H/Library/Developer/CoreSimulator/Devices|emulator|prefer: xcrun simctl delete unavailable"
    "$H/Library/Caches/ms-playwright|browser-cache|Playwright browsers; npx playwright install"
    "$H/.cache/ms-playwright|browser-cache|Playwright browsers; npx playwright install"
    "$H/Library/Containers/com.docker.docker/Data|vm-data|use: docker system df, then docker system prune (ask)"
    "$H/.local/share/docker|vm-data|use: docker system df, then docker system prune (ask)"
    "$H/.Trash|trash|already deleted by you; emptying is permanent"
    "$H/.local/share/Trash|trash|already deleted by you; emptying is permanent"
  )
  for entry in "${paths[@]}"; do
    p="${entry%%|*}"; local rest="${entry#*|}"
    [ -e "$p" ] || continue
    row "$(size_kb "$p")" "${rest%%|*}" "${rest#*|}" "$p"
  done
  # Rust toolchains: more than one is often left over.
  if [ -d "$H/.rustup/toolchains" ]; then
    for t in "$H/.rustup/toolchains"/*; do
      [ -d "$t" ] && row "$(size_kb "$t")" toolchain "rustup toolchain: check rustup show for the default" "$t"
    done
  fi
  # The largest generic cache folders (each app's own cache).
  for base in "$H/Library/Caches" "$H/.cache"; do
    [ -d "$base" ] || continue
    for c in "$base"/*; do
      [ -d "$c" ] || continue
      case "$c" in */huggingface|*/torch|*/whisper|*/uv|*/pip|*/pypoetry|*/ms-playwright|*/Yarn) continue ;; esac
      row "$(size_kb "$c")" app-cache "app cache: usually rebuilt, quit the app first" "$c"
    done
  done
}

{
  for r in "${ROOTS[@]}"; do
    [ -d "$r" ] || { echo "skip: not a folder: $r" >&2; continue; }
    scan_artifacts "$r"
    scan_linked_worktrees "$r"
    scan_frames "$r"
    scan_large_files "$r"
  done
  [ "$CACHES" -eq 1 ] && scan_caches
} | awk -F'\t' '!seen[$5]++' | sort -t "$(printf '\t')" -k1,1gr |
  { printf 'size_mb\tcategory\thint\tmodified\tpath\n'; cat; }
