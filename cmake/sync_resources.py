#!/usr/bin/env python3
# cmake/sync_changed_resources.py
import os, sys, shutil, json, hashlib

# Use timestamp+size by default for speed; set USE_HASH=True to use content hash.
USE_HASH = False
MANIFEST_NAME = ".resource_manifest.json"

def file_key(path):
    st = os.stat(path)
    return (st.st_mtime_ns, st.st_size)

def file_hash(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def collect(src_root):
    out = {}
    for root, _, files in os.walk(src_root):
        for fn in files:
            full = os.path.join(root, fn)
            rel = os.path.relpath(full, src_root).replace(os.sep, "/")
            if USE_HASH:
                out[rel] = file_hash(full)
            else:
                out[rel] = file_key(full)
    return out

def sync(src_root, dst_root):
    src_root = os.path.abspath(src_root)
    dst_root = os.path.abspath(dst_root)
    os.makedirs(dst_root, exist_ok=True)

    manifest_path = os.path.join(dst_root, MANIFEST_NAME)
    prev = {}
    if os.path.exists(manifest_path):
        try:
            with open(manifest_path, "r", encoding="utf-8") as f:
                prev = json.load(f)
        except Exception:
            prev = {}

    src_map = collect(src_root)
    copied = 0
    for rel, key in src_map.items():
        src_file = os.path.join(src_root, rel)
        dst_file = os.path.join(dst_root, rel)
        dst_dir = os.path.dirname(dst_file)
        os.makedirs(dst_dir, exist_ok=True)

        prev_key = prev.get(rel)
        if prev_key == key and os.path.exists(dst_file):
            continue  # unchanged
        shutil.copy2(src_file, dst_file)
        print("Copied:", rel)
        copied += 1

    # remove files that were deleted from source (optional)
    # for rel in list(prev.keys()):
    #     if rel not in src_map:
    #         try: os.remove(os.path.join(dst_root, rel)); print("Removed:", rel)
    #         except: pass

    # write manifest
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(src_map, f, indent=2, ensure_ascii=False)
    return 0 if copied >= 0 else 1

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: sync_changed_resources.py <src_resources_dir> <dest_resources_dir>")
        sys.exit(2)
    sys.exit(sync(sys.argv[1], sys.argv[2]))
