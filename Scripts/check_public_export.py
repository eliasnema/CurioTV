#!/usr/bin/env python3
"""Check public files, or exact staged blobs with --staged, without printing secrets.

This is a focused export guard, not a general-purpose secret scanner.
"""
import argparse
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
IGNORED = {".git", ".build", ".swiftpm", "DerivedData", "__pycache__"}
PRIVATE_PARTS = {"bridge", "playbacklab", "verification", "node_modules", "bridge-state", "work", "xcuserdata"}
PRIVATE_SUFFIXES = {".pem", ".key", ".p8", ".p12", ".mobileprovision", ".provisionprofile", ".log", ".xcuserstate"}
TEXT_SUFFIXES = {".swift", ".py", ".md", ".json", ".xml", ".plist", ".pbxproj", ".xcscheme", ".yml", ".yaml"}
PATTERNS = {
    "personal absolute path": re.compile(rb"/" + rb"(?:Users|home)/[A-Za-z0-9_.-]+/"),
    "machine temporary path": re.compile(rb"/" + rb"(?:private/)?var/folders/"),
    "private key": re.compile(rb"-----BEGIN (?:[A-Z]+ )?PRIVATE KEY-----"),
    "Google access token": re.compile(rb"ya29\." + rb"[A-Za-z0-9_-]{24,}"),
    "Google refresh token": re.compile(rb"1//" + rb"[A-Za-z0-9_-]{32,}"),
    "GitHub token": re.compile(rb"(?:gh[pousr]_" + rb"[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})"),
}
SWIFT_RUNTIME_MARKERS = (b"YouTubeModel", b"YouTubeConnectionView", b"PlaybackLab", b"AVPlayer", b"NSBonjourServices")


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def candidates(staged):
    if staged:
        for entry in git("ls-files", "--stage", "-z").split(b"\0"):
            if not entry:
                continue
            metadata, raw_path = entry.split(b"\t", 1)
            mode, oid, stage = metadata.split()
            path = raw_path.decode("utf-8")
            if mode not in (b"100644", b"100755") or stage != b"0":
                yield path, None
            else:
                yield path, git("cat-file", "blob", oid.decode("ascii"))
    else:
        for path in sorted(ROOT.rglob("*")):
            relative = path.relative_to(ROOT)
            if any(part in IGNORED for part in relative.parts):
                continue
            if path.is_symlink():
                yield str(relative), None
            elif path.is_file():
                yield str(relative), path.read_bytes()


def issues(path, data):
    item = Path(path)
    parts = {part.lower() for part in item.parts}
    if parts & PRIVATE_PARTS or any(part.endswith(".xcresult") for part in parts):
        yield "private runtime, state, or evidence path"
    if item.suffix.lower() in PRIVATE_SUFFIXES or item.name.startswith(".env") or item.name == ".DS_Store":
        yield "private configuration or generated artifact"
    if path.startswith("CurioTV/Features/YouTube/") or item.name in {"HardwarePlaybackUITests.swift", "PlaybackLabUITests.swift", "package-lock.json", "package.json"}:
        yield "experimental integration file"
    if data is None:
        yield "symlink, submodule, or unmerged entry"
        return
    if item.suffix.lower() not in TEXT_SUFFIXES and b"\0" in data:
        return
    for label, pattern in PATTERNS.items():
        if pattern.search(data):
            yield label
    if item.suffix == ".swift" and any(marker in data for marker in SWIFT_RUNTIME_MARKERS):
        yield "experimental playback/account runtime reference"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--staged", action="store_true", help="Inspect the Git index instead of the working tree")
    args = parser.parse_args()
    count, failures = 0, []
    for path, data in candidates(args.staged):
        count += 1
        failures.extend(f"{path}: {issue}" for issue in issues(path, data))
    if count == 0:
        failures.append("No public files found")
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"Checked {count} public files: {'FAIL' if failures else 'PASS'}")
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
