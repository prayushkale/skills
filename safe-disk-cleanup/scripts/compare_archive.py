#!/usr/bin/env python3
"""compare_archive.py: READ-ONLY check of whether an archive is fully contained
in a folder, i.e. whether deleting the archive would lose anything.

Usage:
  python3 -I compare_archive.py ARCHIVE FOLDER [--hash] [--include-generated]

ARCHIVE  .zip, .tar, .tar.gz/.tgz, .tar.bz2 or .tar.xz
FOLDER   the folder you believe holds the same content

By default it compares file names and sizes. --hash also compares the SHA-256
of every same-size pair (slower, but proves the content is identical).
Generated folders (node_modules, .git, build caches, venvs) are skipped unless
--include-generated is given, because they are rebuildable anyway.

Exit code: 0 = everything in the archive exists in the folder,
           1 = the archive holds something the folder does not (keep it),
           2 = error.

It only opens files for reading. It never extracts, writes or deletes.
"""
import hashlib
import os
import re
import sys
import tarfile
import zipfile

GENERATED = re.compile(
    r"(^|/)(\.git|node_modules|__pycache__|\.venv|venv|\.next|\.turbo|\.gradle|"
    r"\.pytest_cache|\.mypy_cache|\.ruff_cache|target|build|dist)/"
)
SECRET = re.compile(
    r"(^|/)(\.env(\.[^/]*)?|[^/]*\.pem|[^/]*\.key|id_rsa[^/]*|id_ed25519[^/]*|"
    r"credentials[^/]*|[^/]*secret[^/]*|[^/]*\.p12|\.npmrc|\.netrc|\.pypirc)$",
    re.IGNORECASE,
)
NOISE = re.compile(r"(^|/)(__MACOSX/|\._[^/]*$|\.DS_Store$)")


def members(path):
    """Yield (name, size, opener) for every regular file in the archive."""
    if zipfile.is_zipfile(path):
        z = zipfile.ZipFile(path)
        for i in z.infolist():
            if not i.is_dir():
                yield i.filename, i.file_size, (lambda i=i: z.open(i))
        return
    if tarfile.is_tarfile(path):
        t = tarfile.open(path)
        for m in t:
            if m.isfile():
                yield m.name, m.size, (lambda m=m: t.extractfile(m))
        return
    raise SystemExit(f"error: not a zip or tar archive: {path}")


def sha256(fileobj):
    h = hashlib.sha256()
    for chunk in iter(lambda: fileobj.read(1 << 20), b""):
        h.update(chunk)
    return h.hexdigest()


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    flags = {a for a in argv if a.startswith("--")}
    if len(args) != 2:
        print(__doc__)
        return 2
    archive, folder = (os.path.expanduser(a) for a in args)
    if not os.path.isfile(archive):
        print(f"error: archive not found: {archive}")
        return 2
    if not os.path.isdir(folder):
        print(f"error: not a folder: {folder}")
        return 2

    items = []
    for name, size, opener in members(archive):
        if NOISE.search(name):
            continue
        items.append((name.lstrip("./"), size, opener))

    # Strip a single shared top-level folder ("Project/...") if there is one.
    tops = {n.split("/", 1)[0] for n, _, _ in items if "/" in n}
    strip = len(tops) == 1 and all("/" in n for n, _, _ in items)
    prefix = next(iter(tops)) + "/" if strip else ""

    same = differ = missing = skipped = hashed_diff = 0
    only_in_archive, differs = [], []
    for name, size, opener in items:
        rel = name[len(prefix):] if prefix and name.startswith(prefix) else name
        if "--include-generated" not in flags and GENERATED.search(rel):
            skipped += 1
            continue
        local = os.path.join(folder, rel)
        if not os.path.isfile(local):
            missing += 1
            only_in_archive.append(rel)
        elif os.path.getsize(local) != size:
            differ += 1
            differs.append(f"{rel} (archive {size} B, folder {os.path.getsize(local)} B)")
        elif "--hash" in flags:
            with opener() as a, open(local, "rb") as b:
                if sha256(a) == sha256(b):
                    same += 1
                else:
                    hashed_diff += 1
                    differs.append(f"{rel} (same size, different content)")
        else:
            same += 1

    print(f"archive: {archive}")
    print(f"folder:  {folder}" + (f"  (archive top folder '{prefix[:-1]}' stripped)" if prefix else ""))
    print(f"compared files: {same + differ + missing + hashed_diff}  (skipped generated: {skipped})")
    print(f"identical{' (sha256)' if '--hash' in flags else ' (name+size)'}: {same}")
    print(f"different in folder: {differ + hashed_diff}")
    print(f"ONLY IN ARCHIVE: {missing}")
    for r in only_in_archive[:40]:
        print(f"  only in archive: {r}")
    if len(only_in_archive) > 40:
        print(f"  ... and {len(only_in_archive) - 40} more")
    for d in differs[:15]:
        print(f"  differs: {d}")
    secrets = [n for n, _, _ in items if SECRET.search(n)]
    if secrets:
        print(f"secret-looking files inside (names only, contents not read): {len(secrets)}")
        for n in secrets[:20]:
            print(f"  secret? {n}")
        print("  note: these may be live credentials. Deleting the archive is fine,"
              " but do not extract, print or upload them.")
    if missing:
        print("verdict: KEEP. The archive holds files the folder does not have.")
        return 1
    if differ or hashed_diff:
        print("verdict: CHECK. Same files, but some differ; the folder may just be newer.")
        return 1
    print("verdict: contained. Every compared file exists in the folder"
          + (" with identical content." if "--hash" in flags else " with the same size."))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
