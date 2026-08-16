#!/usr/bin/env python3
# cmake/reconfigure_if_needed.py
import sys, os, hashlib, subprocess, json

def collect_files(root, exts=None):
    out = []
    for dirpath, _, files in os.walk(root):
        for f in files:
            if exts is None or os.path.splitext(f)[1] in exts:
                out.append(os.path.relpath(os.path.join(dirpath, f), root))
    out.sort()
    return out

def hash_list(lst):
    h = hashlib.sha256()
    for item in lst:
        h.update(item.encode("utf-8"))
        h.update(b"\n")
    return h.hexdigest()

def main(src_dir, build_dir, cmake_cmd):
    src_dir = os.path.abspath(src_dir)
    build_dir = os.path.abspath(build_dir)
    manifest_path = os.path.join(build_dir, ".src_manifest.json")
    ensure = lambda p: os.makedirs(p, exist_ok=True)
    ensure(build_dir)

    # Watch C/C++/h/cpp/cxx and CMake files
    src_files = collect_files(os.path.join(src_dir, "src"), exts={".c",".cpp",".cxx",".cc",".h",".hpp"})
    cmake_files = collect_files(src_dir, exts={".cmake",".txt"})  # include top-level CMakeLists.txt and cmake/*.cmake
    watched = {"src": src_files, "cmake": cmake_files}
    current_hash = hash_list(src_files + cmake_files)

    prev = {}
    if os.path.exists(manifest_path):
        try:
            with open(manifest_path, "r", encoding="utf-8") as f:
                prev = json.load(f)
        except Exception:
            prev = {}

    if prev.get("hash") == current_hash:
        # nothing changed
        print("No source/CMake changes detected; skipping reconfigure.")
        return 0

    # run cmake to reconfigure
    print("Source/CMake changes detected; running CMake to reconfigure...")
    try:
        subprocess.check_call(cmake_cmd, shell=False)
    except subprocess.CalledProcessError as e:
        print("CMake reconfigure failed:", e)
        return e.returncode

    # update manifest
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump({"hash": current_hash, "files": watched}, f, indent=2)
    print("Reconfigure complete.")
    return 0

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: reconfigure_if_needed.py <project_root> <build_dir> <cmake_executable> [cmake_args...]")
        sys.exit(2)
    project_root = sys.argv[1]
    build_dir = sys.argv[2]
    cmake_exe = sys.argv[3]
    cmake_args = sys.argv[4:]
    cmd = [cmake_exe, "-S", project_root, "-B", build_dir] + cmake_args
    sys.exit(main(project_root, build_dir, cmd))
