"""Tests for sync_variant_stationery.py.

Run from the repo root:

    python -m pytest scripts/ -q

The manifest tests reproduce the real Quantum Sync Stationery manifest, so they
need the base Stationery's gitignored files (Files/, Formats/) on disk.
"""

from __future__ import annotations

import hashlib
import os
import re
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import sync_variant_stationery as svs  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parent.parent
BASE_STATIONERY = (
    REPO_ROOT
    / "latest/local-trial-projects/WebWorks ePublisher AutoMap/Evaluation/Quantum Sync Stationery"
)

ENTRY_RE = re.compile(
    r"<Entry>\s*<Path>([^<]*)</Path>"
    r"(?:\s*<checksum>([^<]*)</checksum>\s*<LastModified>([^<]*)</LastModified>)?"
    r"\s*</Entry>"
)


def parse_manifest(data: bytes) -> list[tuple[str, str | None, str | None]]:
    return [m.groups() for m in ENTRY_RE.finditer(data.decode("utf-8-sig"))]


def write(path: Path, content: str | bytes, mtime_ns: int | None = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(content, str):
        content = content.encode("utf-8")
    path.write_bytes(content)
    if mtime_ns is not None:
        os.utime(path, ns=(mtime_ns, mtime_ns))


def sha1(path: Path) -> str:
    return hashlib.sha1(path.read_bytes()).hexdigest().upper()


class TimestampFormatting(unittest.TestCase):
    def test_whole_seconds_have_no_fraction(self):
        # 2026-03-10T00:08:50Z
        self.assertEqual(svs.format_last_modified(1773101330 * 10**9), "2026-03-10T00:08:50Z")

    def test_fraction_is_seven_digits_with_trailing_zeros_trimmed(self):
        base = 1773101330 * 10**9
        self.assertEqual(svs.format_last_modified(base + 752_203_100), "2026-03-10T00:08:50.7522031Z")
        self.assertEqual(svs.format_last_modified(base + 500_000_000), "2026-03-10T00:08:50.5Z")

    def test_sub_tick_precision_is_truncated(self):
        base = 1773101330 * 10**9
        self.assertEqual(svs.format_last_modified(base + 99), "2026-03-10T00:08:50Z")


class ChromeRule(unittest.TestCase):
    def test_only_the_reverb_assets_and_sass_partials_are_chrome(self):
        for rel in ("Files/toolbar-logo.svg", "Files/footer-logo.svg", "Files/favicon.png",
                    "Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss",
                    "Formats/WebWorks Reverb 2.0/Pages/sass/custom.scss"):
            self.assertTrue(svs.is_chrome(rel), rel)
        for rel in ("Files/pdf-cover.png", "Files/og.png", "Files/footer-logo.png",
                    "Formats/WebWorks Reverb 2.0.base/Pages/sass/_colors.scss",
                    "Formats/WebWorks Reverb 2.0/Transforms/extra.xsl",
                    "Settings/Web Help/settings.json"):
            self.assertFalse(svs.is_chrome(rel), rel)


class ManifestGeneration(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="svs-manifest-"))
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)

    def test_orders_files_before_directories_case_insensitively_and_skips_settings(self):
        st = self.tmp / "My Stationery"
        t = 1773101330 * 10**9
        write(st / "My Stationery.wxsp", "<Project/>", t)
        write(st / "Files/favicon.png", b"png", t)
        write(st / "Formats/Fmt.base/Pages/robots.txt", "r", t)
        write(st / "Formats/Fmt.base/Pages/Search.asp", "s", t)
        write(st / "Formats/Fmt.base/Pages/Page-KnowledgeBase.asp", "k", t)
        write(st / "Formats/Fmt.base/Pages/Page.asp", "p", t)
        write(st / "Formats/Fmt.base/Pages/sass/custom.scss", "c", t)
        write(st / "Formats/Fmt.base/Pages/sass/_colors.scss", "_", t + 752_203_100)
        write(st / "Formats/Fmt.base/format.wwfmt", "f", t)
        write(st / "Settings/Web Help/settings.json", "{}", t)

        data = svs.generate_manifest(st)

        self.assertTrue(data.startswith(b"\xef\xbb\xbf<?xml"))
        self.assertIn(b"\r\n", data)
        self.assertTrue(data.endswith(b"</Manifest>"))
        entries = parse_manifest(data)
        self.assertEqual(
            [p for p, _, _ in entries],
            [
                "Files\\favicon.png",
                "Formats\\Fmt.base",
                "Formats\\Fmt.base\\format.wwfmt",
                "Formats\\Fmt.base\\Pages",
                "Formats\\Fmt.base\\Pages\\Page-KnowledgeBase.asp",
                "Formats\\Fmt.base\\Pages\\Page.asp",
                "Formats\\Fmt.base\\Pages\\robots.txt",
                "Formats\\Fmt.base\\Pages\\Search.asp",
                "Formats\\Fmt.base\\Pages\\sass",
                "Formats\\Fmt.base\\Pages\\sass\\custom.scss",
                "Formats\\Fmt.base\\Pages\\sass\\_colors.scss",
            ],
        )
        by_path = {p: (c, lm) for p, c, lm in entries}
        self.assertEqual(by_path["Formats\\Fmt.base"], (None, None))
        self.assertEqual(
            by_path["Files\\favicon.png"],
            (hashlib.sha1(b"png").hexdigest().upper(), "2026-03-10T00:08:50Z"),
        )
        self.assertEqual(by_path["Formats\\Fmt.base\\Pages\\sass\\_colors.scss"][1], "2026-03-10T00:08:50.7522031Z")

    @unittest.skipUnless((BASE_STATIONERY / "Formats").is_dir(), "base Stationery files not on disk")
    def test_reproduces_the_quantum_sync_stationery_manifest(self):
        expected = parse_manifest((BASE_STATIONERY / "Quantum Sync Stationery.manifest").read_bytes())
        actual = parse_manifest(svs.generate_manifest(BASE_STATIONERY))

        # Paths (order, files vs folders) and checksums must match Designer's manifest exactly.
        # Timestamps are deliberately not compared here: they depend on how the gitignored files
        # reached this machine. Their format is covered by the fixture tests above.
        self.assertEqual([(p, c) for p, c, _ in actual], [(p, c) for p, c, _ in expected])


class SyncFixture(unittest.TestCase):
    """A miniature base/variant pair exercising every rule of the sync."""

    MTIME = 1773101330 * 10**9  # 2026-03-10T00:08:50Z

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="svs-sync-"))
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        self.base = self.tmp / "Evaluation" / "Quantum Sync Stationery"
        self.variant = self.tmp / "Evaluation" / "Quantum Sync Midnight Stationery"
        t = self.MTIME
        write(self.base / "Quantum Sync Stationery.wxsp", "<Project>base rules</Project>", t)
        write(self.base / "Quantum Sync Stationery.manifest", "stale", t)
        write(self.base / "Files/toolbar-logo.svg", "<svg>base</svg>", t)
        write(self.base / "Files/favicon.png", b"icon", t)
        write(self.base / "Files/pdf-cover.png", b"cover", t)
        write(self.base / "Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss", "$theme_primary: #0a4d8c;", t)
        write(self.base / "Formats/WebWorks Reverb 2.0/Pages/sass/custom.scss", "// card layout", t)
        write(self.base / "Formats/WebWorks Reverb 2.0/Transforms/extra.xsl", "<xsl/>", t)
        write(self.base / "Formats/WebWorks Reverb 2.0.base/format.wwfmt", "<Format/>", t + 100)
        write(self.base / "Formats/PDF - XSL-FO.base/format.wwfmt", "<Format pdf/>", t)
        write(self.base / "Settings/Web Help/settings.json", "{}", t)
        write(self.base / "Settings/PDF/schema.json", "{}", t)
        # The variant already carries its own chrome, plus stale and unrelated files.
        write(self.variant / "Files/toolbar-logo.svg", "<svg>midnight</svg>", t + 5 * 10**9)
        write(self.variant / "Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss", "$theme_primary: #0e7490;", t)
        write(self.variant / "Formats/WebWorks Reverb 2.0.base/old.xsl", "stale", t)
        write(self.variant / "Output/Web Help/index.html", "built", t)

    def test_sync_mirrors_base_preserves_chrome_and_seeds_missing_chrome(self):
        report = svs.sync(self.base, self.variant)

        wxsp = self.variant / "Quantum Sync Midnight Stationery.wxsp"
        self.assertEqual(wxsp.read_bytes(), (self.base / "Quantum Sync Stationery.wxsp").read_bytes())
        self.assertEqual(os.stat(wxsp).st_mtime_ns, self.MTIME)
        self.assertFalse((self.variant / "Quantum Sync Stationery.wxsp").exists())

        # Non-chrome content is mirrored, mtimes included — the PDF cover is not chrome.
        for rel in (
            "Files/pdf-cover.png",
            "Formats/WebWorks Reverb 2.0/Transforms/extra.xsl",
            "Formats/WebWorks Reverb 2.0.base/format.wwfmt",
            "Formats/PDF - XSL-FO.base/format.wwfmt",
            "Settings/Web Help/settings.json",
            "Settings/PDF/schema.json",
        ):
            self.assertEqual((self.variant / rel).read_bytes(), (self.base / rel).read_bytes(), rel)
            self.assertEqual(os.stat(self.variant / rel).st_mtime_ns, os.stat(self.base / rel).st_mtime_ns, rel)

        # Chrome the variant owns is untouched; chrome it lacks is seeded from the base.
        self.assertEqual((self.variant / "Files/toolbar-logo.svg").read_text(), "<svg>midnight</svg>")
        self.assertEqual(
            (self.variant / "Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss").read_text(),
            "$theme_primary: #0e7490;",
        )
        self.assertEqual((self.variant / "Files/favicon.png").read_bytes(), b"icon")
        self.assertEqual((self.variant / "Formats/WebWorks Reverb 2.0/Pages/sass/custom.scss").read_text(), "// card layout")

        # Stale non-chrome files go; build artifacts outside the Stationery roots stay.
        self.assertFalse((self.variant / "Formats/WebWorks Reverb 2.0.base/old.xsl").exists())
        self.assertTrue((self.variant / "Output/Web Help/index.html").exists())

        # The manifest describes the variant's own files.
        manifest = self.variant / "Quantum Sync Midnight Stationery.manifest"
        entries = {p: (c, lm) for p, c, lm in parse_manifest(manifest.read_bytes())}
        self.assertEqual(entries["Files\\toolbar-logo.svg"][0], sha1(self.variant / "Files/toolbar-logo.svg"))
        self.assertEqual(entries["Files\\toolbar-logo.svg"][1], "2026-03-10T00:08:55Z")
        self.assertNotIn("Formats\\WebWorks Reverb 2.0.base\\old.xsl", entries)
        self.assertNotIn("Settings\\Web Help\\settings.json", entries)
        self.assertNotIn("Quantum Sync Stationery.manifest", manifest.read_text(encoding="utf-8-sig"))

        self.assertEqual(sorted(report.seeded), ["Files/favicon.png", "Formats/WebWorks Reverb 2.0/Pages/sass/custom.scss"])
        self.assertIn("Files/pdf-cover.png", report.mirrored)
        self.assertIn("Formats/WebWorks Reverb 2.0.base/old.xsl", report.removed)
        self.assertEqual(report.chrome_differs, ["Files/toolbar-logo.svg", "Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss"])
        self.assertEqual(report.chrome_only_in_variant, [])

    def test_sync_is_idempotent_and_check_mode_detects_drift_without_writing(self):
        svs.sync(self.base, self.variant)
        clean = svs.sync(self.base, self.variant, check=True)
        self.assertTrue(clean.in_sync, clean.describe_drift())

        write(self.base / "Formats/WebWorks Reverb 2.0.base/format.wwfmt", "<Format v2/>", self.MTIME + 7 * 10**9)
        write(self.base / "Quantum Sync Stationery.wxsp", "<Project>new rules</Project>", self.MTIME + 7 * 10**9)
        (self.base / "Formats/WebWorks Reverb 2.0/Transforms/extra.xsl").unlink()
        manifest_before = (self.variant / "Quantum Sync Midnight Stationery.manifest").read_bytes()

        drift = svs.sync(self.base, self.variant, check=True)

        self.assertFalse(drift.in_sync)
        self.assertIn("Formats/WebWorks Reverb 2.0.base/format.wwfmt", drift.mirrored)
        self.assertIn("Quantum Sync Midnight Stationery.wxsp", drift.mirrored)
        self.assertIn("Formats/WebWorks Reverb 2.0/Transforms/extra.xsl", drift.removed)
        self.assertEqual((self.variant / "Formats/WebWorks Reverb 2.0.base/format.wwfmt").read_text(), "<Format/>")
        self.assertTrue((self.variant / "Formats/WebWorks Reverb 2.0/Transforms/extra.xsl").exists())
        self.assertEqual((self.variant / "Quantum Sync Midnight Stationery.manifest").read_bytes(), manifest_before)

        svs.sync(self.base, self.variant)
        self.assertTrue(svs.sync(self.base, self.variant, check=True).in_sync)

    def test_a_new_base_pdf_cover_flows_into_the_variant(self):
        svs.sync(self.base, self.variant)
        write(self.base / "Files/pdf-cover.png", b"cover v2", self.MTIME + 11 * 10**9)

        drift = svs.sync(self.base, self.variant, check=True)
        self.assertFalse(drift.in_sync)
        self.assertIn("Files/pdf-cover.png", drift.mirrored)

        svs.sync(self.base, self.variant)
        self.assertEqual((self.variant / "Files/pdf-cover.png").read_bytes(), b"cover v2")
        self.assertEqual((self.variant / "Files/toolbar-logo.svg").read_text(), "<svg>midnight</svg>")

    def test_check_mode_flags_a_stale_manifest(self):
        svs.sync(self.base, self.variant)
        write(self.variant / "Files/toolbar-logo.svg", "<svg>edited</svg>", self.MTIME + 9 * 10**9)

        drift = svs.sync(self.base, self.variant, check=True)

        self.assertFalse(drift.in_sync)
        self.assertTrue(drift.manifest_stale)

    def test_cli_exit_codes(self):
        self.assertEqual(svs.main(["--base", str(self.base), "--variant", str(self.variant), "--check"]), 2)
        self.assertEqual(svs.main(["--base", str(self.base), "--variant", str(self.variant)]), 0)
        self.assertEqual(svs.main(["--base", str(self.base), "--variant", str(self.variant), "--check"]), 0)
        self.assertEqual(svs.main(["--base", str(self.tmp / "missing"), "--variant", str(self.variant)]), 1)
        self.assertEqual(svs.main(["--base", str(self.base), "--variant", str(self.base)]), 1)


if __name__ == "__main__":
    unittest.main()
