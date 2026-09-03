#!/usr/bin/env python3
"""Regenerate the variant Stationery from Quantum Sync Stationery.

The variant Stationery (Quantum Sync Midnight Stationery) is Quantum Sync
Stationery with different chrome and nothing else. This script keeps that true:

* **Variant-owned chrome** — the toolbar logo, footer logo and favicon under
  ``Files/`` (the assets Reverb's toolbar, footer and browser tab show) and the
  partials under ``Formats/WebWorks Reverb 2.0/Pages/sass/`` (they compile into
  the shell-owned root ``css/``) — is the variant's design source. It is tracked
  in git and never overwritten here. A chrome file the variant lacks is seeded
  from the base so a new variant starts as a copy of the base.
* **Everything else** under ``Files/``, ``Formats/`` and ``Settings/`` — the PDF
  cover and Open Graph image included — is
  mirrored from the base byte-for-byte (modification times included), the
  base's ``.wxsp`` is copied to ``<variant>.wxsp``, and files the base no
  longer has are removed. Build folders such as ``Output/`` are left alone.
* ``<variant>.manifest`` is regenerated the way Designer writes it: every file
  under ``Files\\`` and ``Formats\\`` with its SHA-1 and last-modified time,
  files before sub-folders, sorted case-insensitively.

Usage (from the repo root)::

    python scripts/sync_variant_stationery.py            # regenerate
    python scripts/sync_variant_stationery.py --check    # verify, no writes

Exit codes: 0 in sync (or synced), 1 usage/precondition error, 2 ``--check``
found drift.

See docs/agents/extraction-layout.md and docs/adr/0003-variant-stationery-scripted-overlay.md.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from xml.sax.saxutils import escape

REPO_ROOT = Path(__file__).resolve().parent.parent
EVALUATION_DIR = REPO_ROOT / "latest/local-trial-projects/WebWorks ePublisher AutoMap/Evaluation"
DEFAULT_BASE = EVALUATION_DIR / "Quantum Sync Stationery"
DEFAULT_VARIANT = EVALUATION_DIR / "Quantum Sync Midnight Stationery"

#: Folders of a Stationery that make up its content. Anything else in the
#: folder (Output/, Logs/, Reports/) is a build artifact and is ignored.
STATIONERY_ROOTS = ("Files", "Formats", "Settings")

#: Folders the manifest covers. Designer leaves Settings/ and the .wxsp out.
MANIFEST_ROOTS = ("Files", "Formats")

#: The files the variant owns (forward-slash paths relative to the Stationery
#: folder): the assets Reverb's toolbar, footer and browser tab show...
CHROME_FILES = frozenset({"Files/toolbar-logo.svg", "Files/footer-logo.svg", "Files/favicon.png"})

#: ...and every partial under the Reverb sass override folder.
CHROME_DIRS = (PurePosixPath("Formats/WebWorks Reverb 2.0/Pages/sass"),)

TICKS_PER_SECOND = 10_000_000

#: How many paths a report lists per category before eliding the rest.
LIST_LIMIT = 20


def is_chrome(rel: str) -> bool:
    """True when ``rel`` (forward-slash relative path) is variant-owned chrome."""
    path = PurePosixPath(rel)
    return rel in CHROME_FILES or any(path.is_relative_to(chrome_dir) for chrome_dir in CHROME_DIRS)


def format_last_modified(mtime_ns: int) -> str:
    """Format a file time the way .NET's XmlConvert writes a UTC DateTime.

    Seven fractional digits (100-nanosecond ticks) with trailing zeros trimmed,
    and no fraction at all for whole seconds — e.g. ``2026-08-20T23:20:55.7522031Z``
    or ``2026-03-10T00:08:50Z``.
    """
    ticks = mtime_ns // 100
    whole, frac = divmod(ticks, TICKS_PER_SECOND)
    stamp = datetime.fromtimestamp(whole, timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
    if frac:
        stamp += "." + f"{frac:07d}".rstrip("0")
    return stamp + "Z"


def _sorted_names(names: list[str]) -> list[str]:
    return sorted(names, key=str.upper)


def _manifest_entries(directory: Path, rel_prefix: str) -> list[str]:
    """Entries for one directory: its files, then each sub-folder recursively."""
    lines: list[str] = []
    with os.scandir(directory) as it:
        children = list(it)
    files = _sorted_names([c.name for c in children if c.is_file()])
    dirs = _sorted_names([c.name for c in children if c.is_dir()])
    for name in files:
        path = directory / name
        stat = path.stat()
        checksum = hashlib.sha1(path.read_bytes()).hexdigest().upper()
        lines.append(
            "  <Entry>\r\n"
            f"    <Path>{escape(rel_prefix + name)}</Path>\r\n"
            f"    <checksum>{checksum}</checksum>\r\n"
            f"    <LastModified>{format_last_modified(stat.st_mtime_ns)}</LastModified>\r\n"
            "  </Entry>\r\n"
        )
    for name in dirs:
        lines.append("  <Entry>\r\n" f"    <Path>{escape(rel_prefix + name)}</Path>\r\n" "  </Entry>\r\n")
        lines.extend(_manifest_entries(directory / name, rel_prefix + name + "\\"))
    return lines


def generate_manifest(stationery_dir: Path) -> bytes:
    """Build the ``.manifest`` bytes for a Stationery folder (BOM, CRLF, no trailing newline)."""
    lines = ['\ufeff<?xml version="1.0" encoding="utf-8"?>\r\n', '<Manifest version="1.0">\r\n']
    for root in MANIFEST_ROOTS:
        root_dir = Path(stationery_dir) / root
        if root_dir.is_dir():
            lines.extend(_manifest_entries(root_dir, root + "\\"))
    lines.append("</Manifest>")
    return "".join(lines).encode("utf-8")


def _stationery_files(stationery_dir: Path) -> dict[str, Path]:
    """Map forward-slash relative path -> absolute path for every file under the Stationery roots."""
    found: dict[str, Path] = {}
    for root in STATIONERY_ROOTS:
        root_dir = stationery_dir / root
        if not root_dir.is_dir():
            continue
        for path in sorted(root_dir.rglob("*")):
            if path.is_file():
                found[path.relative_to(stationery_dir).as_posix()] = path
    return found


def _same_file(a: Path, b: Path) -> bool:
    if not (a.is_file() and b.is_file()):
        return False
    sa, sb = a.stat(), b.stat()
    if sa.st_size != sb.st_size or sa.st_mtime_ns != sb.st_mtime_ns:
        return False
    return a.read_bytes() == b.read_bytes()


def _copy(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def _prune_empty_dirs(stationery_dir: Path) -> None:
    for root in STATIONERY_ROOTS:
        root_dir = stationery_dir / root
        if not root_dir.is_dir():
            continue
        for path in sorted((p for p in root_dir.rglob("*") if p.is_dir()), reverse=True):
            if not any(path.iterdir()):
                path.rmdir()


@dataclass
class SyncReport:
    base: Path
    variant: Path
    check: bool
    mirrored: list[str] = field(default_factory=list)
    removed: list[str] = field(default_factory=list)
    seeded: list[str] = field(default_factory=list)
    chrome_differs: list[str] = field(default_factory=list)
    chrome_only_in_variant: list[str] = field(default_factory=list)
    manifest_stale: bool = False

    @property
    def in_sync(self) -> bool:
        return not (self.mirrored or self.removed or self.seeded or self.manifest_stale)

    def describe_drift(self) -> str:
        verb = "would be" if self.check else "were"
        lines: list[str] = []
        for label, items in (
            (f"mirrored from the base ({verb} copied)", self.mirrored),
            (f"stale in the variant ({verb} removed)", self.removed),
            (f"chrome missing in the variant ({verb} seeded from the base)", self.seeded),
        ):
            if items:
                lines.append(f"{len(items)} file(s) {label}:")
                lines.extend(f"  {item}" for item in items[:LIST_LIMIT])
                if len(items) > LIST_LIMIT:
                    lines.append(f"  ... and {len(items) - LIST_LIMIT} more")
        if self.manifest_stale:
            lines.append(f"{self.variant.name}.manifest {verb} regenerated")
        return "\n".join(lines) if lines else "Nothing to do."

    def describe_chrome(self) -> str:
        lines = [f"Variant-owned chrome that differs from {self.base.name}:"]
        if self.chrome_differs:
            lines.extend(f"  {item}" for item in self.chrome_differs)
        else:
            lines.append("  (none)")
        if self.chrome_only_in_variant:
            lines.append("Chrome only the variant has:")
            lines.extend(f"  {item}" for item in self.chrome_only_in_variant)
        return "\n".join(lines)


def sync(base: Path, variant: Path, *, check: bool = False) -> SyncReport:
    """Mirror ``base`` into ``variant`` (or, with ``check``, report what would change)."""
    base, variant = Path(base).resolve(), Path(variant).resolve()
    base_wxsp = base / f"{base.name}.wxsp"
    if not base_wxsp.is_file():
        raise FileNotFoundError(f"Base Stationery not found: {base_wxsp}")
    if base == variant:
        raise ValueError("Base and variant Stationery must be different folders")

    report = SyncReport(base=base, variant=variant, check=check)
    base_files = _stationery_files(base)
    variant_files = _stationery_files(variant)

    def plan_copy(bucket: list[str], label: str, src: Path, dst: Path) -> None:
        bucket.append(label)
        if not check:
            _copy(src, dst)

    # The .wxsp is tracked in git (a checkout rewrites its mtime) and the manifest
    # does not list it, so it is compared by content alone.
    variant_wxsp = variant / f"{variant.name}.wxsp"
    if not (variant_wxsp.is_file() and variant_wxsp.read_bytes() == base_wxsp.read_bytes()):
        plan_copy(report.mirrored, variant_wxsp.name, base_wxsp, variant_wxsp)

    for rel, src in base_files.items():
        dst = variant / rel
        if is_chrome(rel):
            if rel not in variant_files:
                plan_copy(report.seeded, rel, src, dst)
        elif not _same_file(src, dst):
            plan_copy(report.mirrored, rel, src, dst)

    for rel, path in variant_files.items():
        if rel not in base_files and not is_chrome(rel):
            report.removed.append(rel)
            if not check:
                path.unlink()
    if not check and report.removed:
        _prune_empty_dirs(variant)

    for rel in sorted(rel for rel in variant_files if is_chrome(rel)):
        if rel not in base_files:
            report.chrome_only_in_variant.append(rel)
        elif base_files[rel].read_bytes() != variant_files[rel].read_bytes():
            report.chrome_differs.append(rel)

    manifest_path = variant / f"{variant.name}.manifest"
    existing = manifest_path.read_bytes() if manifest_path.is_file() else b""
    fresh = generate_manifest(variant)
    report.manifest_stale = existing != fresh
    if report.manifest_stale and not check:
        manifest_path.write_bytes(fresh)
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0], formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--base", type=Path, default=DEFAULT_BASE, help=f"base Stationery folder (default: {DEFAULT_BASE})")
    parser.add_argument("--variant", type=Path, default=DEFAULT_VARIANT, help=f"variant Stationery folder (default: {DEFAULT_VARIANT})")
    parser.add_argument("--check", action="store_true", help="report drift without writing; exit 2 if anything would change")
    args = parser.parse_args(argv)

    try:
        report = sync(args.base, args.variant, check=args.check)
    except (FileNotFoundError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"Base:    {report.base}")
    print(f"Variant: {report.variant}")
    print(report.describe_drift())
    print(report.describe_chrome())
    if args.check and not report.in_sync:
        print("Out of sync. Run without --check to regenerate the variant.")
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
