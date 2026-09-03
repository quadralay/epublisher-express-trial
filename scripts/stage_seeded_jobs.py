#!/usr/bin/env python3
"""Stage AutoMap seeded jobs and resolve their Folder destinations.

Seeded jobs carry paths relative to their own .waj file. AutoMap 2026.1
uses a Folder deploy Configuration value verbatim, so this script copies the
jobs into a product folder and resolves relative Folder destinations against
each staged job's directory.

Usage (from the repo root)::

    python scripts/stage_seeded_jobs.py <product-folder>
    python scripts/stage_seeded_jobs.py <product-folder> --dry-run
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from typing import List, Optional, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = REPO_ROOT / "latest/local-trial-projects/WebWorks ePublisher AutoMap"

DEPLOY_SETTING_RE = re.compile(
    r'(<DeploySetting\b(?=[^>]*\bAction\s*=\s*"file")[^>]*>)(.*?)(</DeploySetting\s*>)',
    re.DOTALL,
)
CONFIGURATION_RE = re.compile(r'(<Configuration\b[^>]*?\bValue\s*=\s*")([^"]*)(")')


def discover_jobs(source: Path) -> List[Tuple[str, Path]]:
    """Return valid seeded jobs under source/Jobs, in stable name order."""
    jobs_dir = Path(source) / "Jobs"
    if not jobs_dir.is_dir():
        return []
    jobs = []
    for folder in sorted((path for path in jobs_dir.iterdir() if path.is_dir()), key=lambda p: p.name.casefold()):
        job = folder / f"{folder.name}.waj"
        if job.is_file():
            jobs.append((folder.name, job))
    return jobs


def _is_absolute(value: str) -> bool:
    """Recognize native absolute, drive-rooted, and UNC-rooted paths."""
    return os.path.isabs(value) or bool(re.match(r"^(?:[A-Za-z]:[\\/]|[\\/])", value))


def _rewrite_configurations(text: str, job_directory: Path) -> Tuple[str, List[Tuple[str, str]]]:
    rewritten = []

    def rewrite_deploy_setting(match: re.Match[str]) -> str:
        opening, body, closing = match.groups()

        def rewrite_configuration(config_match: re.Match[str]) -> str:
            prefix, old, suffix = config_match.groups()
            if _is_absolute(old):
                return config_match.group(0)
            new = os.path.normpath(os.path.join(str(job_directory), old)).replace("/", "\\")
            rewritten.append((old, new))
            return f"{prefix}{new}{suffix}"

        return opening + CONFIGURATION_RE.sub(rewrite_configuration, body) + closing

    return DEPLOY_SETTING_RE.sub(rewrite_deploy_setting, text), rewritten


def stage_jobs(product_folder: Path, source: Path, *, dry_run: bool = False) -> List[Tuple[Path, List[Tuple[str, str]]]]:
    """Stage discovered jobs and return each destination plus its rewrites."""
    product_folder = Path(product_folder).resolve()
    source = Path(source).resolve()
    source_jobs = (source / "Jobs").resolve()
    destination_jobs = (product_folder / "Jobs").resolve()
    if os.path.normcase(str(source_jobs)) == os.path.normcase(str(destination_jobs)):
        raise ValueError(f"refusing to stage onto source Jobs directory: {source_jobs}")

    jobs = discover_jobs(source)
    if not jobs:
        raise FileNotFoundError(f"no seeded jobs found under {source}")

    reports = []
    for name, source_job in jobs:
        destination = destination_jobs / name / source_job.name
        source_bytes = source_job.read_bytes()
        encoding = "utf-8-sig" if source_bytes.startswith(b"\xef\xbb\xbf") else "utf-8"
        rewritten_text, rewrites = _rewrite_configurations(source_bytes.decode(encoding), destination.parent)
        output = rewritten_text.encode(encoding)
        if not dry_run:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(output)
        reports.append((destination, rewrites))
    return reports


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("product_folder", type=Path, help="target AutoMap product folder")
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE, help=f"repo AutoMap mirror folder (default: {DEFAULT_SOURCE})")
    parser.add_argument("--dry-run", action="store_true", help="show staging changes without writing")
    args = parser.parse_args(argv)

    try:
        reports = stage_jobs(args.product_folder, args.source, dry_run=args.dry_run)
    except (FileNotFoundError, OSError, UnicodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    for destination, rewrites in reports:
        print(destination)
        if not rewrites:
            print("  (no relative Folder destination to rewrite)")
        for old, new in rewrites:
            print(f"{old} -> {new}")
    return 0


if __name__ == "__main__":
    sys.exit(main())