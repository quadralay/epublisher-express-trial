"""Tests for stage_seeded_jobs.py.

Run from the repo root:

    python -m pytest scripts/ -q
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))

import stage_seeded_jobs as ssj  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCE = REPO_ROOT / "latest/local-trial-projects/WebWorks ePublisher AutoMap"
JOB_NAMES = ("Quantum Sync Help", "Quantum Sync Release Notes", "Quantum Sync Site Shell")
PATH_RE = re.compile(rb'<(?:Project|Document) path="([^"]*)"')


def test_default_source_discovers_all_three_jobs():
    jobs = ssj.discover_jobs(SOURCE)

    assert [name for name, _ in jobs] == sorted(JOB_NAMES, key=str.casefold)
    assert all(path.name == f"{name}.waj" for name, path in jobs)


def test_staging_rewrites_relative_destinations_to_product_output(tmp_path):
    reports = ssj.stage_jobs(tmp_path, SOURCE)

    assert [destination.parent.name for destination, _ in reports] == list(JOB_NAMES)
    for name, (destination, rewrites) in zip(JOB_NAMES, reports):
        assert rewrites == [(f"..\\..\\Output\\{name}", str(tmp_path / "Output" / name))]
        assert destination.is_file()
        assert f'Value="{str(tmp_path / "Output" / name)}"'.encode() in destination.read_bytes()


def test_project_and_document_paths_are_byte_identical_after_staging(tmp_path):
    reports = ssj.stage_jobs(tmp_path, SOURCE)

    for (name, source_job), (destination, _) in zip(ssj.discover_jobs(SOURCE), reports):
        assert PATH_RE.findall(source_job.read_bytes()) == PATH_RE.findall(destination.read_bytes()), name


def test_absolute_configuration_value_is_left_alone(tmp_path):
    source = tmp_path / "source"
    job_name = "Absolute Destination"
    source_job = source / "Jobs" / job_name / f"{job_name}.waj"
    absolute = str(tmp_path / "already" / "absolute")
    content = (
        '<?xml version="1.0" encoding="utf-8"?>\r\n'
        f'<Job name="{job_name}" version="1.0">\r\n'
        '  <DeploySettings>\r\n'
        f'    <DeploySetting Name="{job_name}" Action="file">\r\n'
        f'      <Configuration Value="{absolute}" />\r\n'
        '    </DeploySetting>\r\n'
        '  </DeploySettings>\r\n'
        '</Job>'
    ).encode("utf-8-sig")
    source_job.parent.mkdir(parents=True)
    source_job.write_bytes(content)

    reports = ssj.stage_jobs(tmp_path / "product", source)

    assert reports[0][1] == []
    assert reports[0][0].read_bytes() == content


def test_missing_jobs_returns_one_and_prints_error(tmp_path, capsys):
    assert ssj.main([str(tmp_path / "product"), "--source", str(tmp_path / "source")]) == 1

    captured = capsys.readouterr()
    assert captured.err or captured.out


def test_absolute_configuration_value_prints_no_rewrite_and_copies_file(tmp_path, capsys):
    source = tmp_path / "source"
    job_name = "Absolute Destination"
    source_job = source / "Jobs" / job_name / f"{job_name}.waj"
    absolute = str(tmp_path / "already" / "absolute")
    content = (
        '<?xml version="1.0" encoding="utf-8"?>\r\n'
        f'<Job name="{job_name}" version="1.0">\r\n'
        '  <DeploySettings>\r\n'
        f'    <DeploySetting Name="{job_name}" Action="file">\r\n'
        f'      <Configuration Value="{absolute}" />\r\n'
        '    </DeploySetting>\r\n'
        '  </DeploySettings>\r\n'
        '</Job>'
    ).encode("utf-8-sig")
    source_job.parent.mkdir(parents=True)
    source_job.write_bytes(content)
    product = tmp_path / "product"

    assert ssj.main([str(product), "--source", str(source)]) == 0

    captured = capsys.readouterr()
    assert "  (no relative Folder destination to rewrite)" in captured.out
    destination = product / "Jobs" / job_name / source_job.name
    assert destination.is_file()
    assert destination.read_bytes() == content


def test_invalid_utf8_job_returns_one(tmp_path):
    source = tmp_path / "source"
    job_name = "Invalid UTF-8"
    source_job = source / "Jobs" / job_name / f"{job_name}.waj"
    source_job.parent.mkdir(parents=True)
    source_job.write_bytes(b"\xef\xbb\xbf<\xff")

    assert ssj.main([str(tmp_path / "product"), "--source", str(source)]) == 1


def test_only_configuration_value_bytes_change(tmp_path):
    reports = ssj.stage_jobs(tmp_path, SOURCE)

    for (name, source_job), (destination, rewrites) in zip(ssj.discover_jobs(SOURCE), reports):
        source_bytes = source_job.read_bytes()
        staged_bytes = destination.read_bytes()
        for old, new in rewrites:
            staged_bytes = staged_bytes.replace(new.encode(), old.encode(), 1)
        assert staged_bytes == source_bytes, name


def test_dry_run_writes_nothing(tmp_path):
    product = tmp_path / "product"

    assert ssj.main([str(product), "--source", str(SOURCE), "--dry-run"]) == 0
    assert not product.exists()


def test_same_directory_refusal_returns_two():
    source = SOURCE.resolve()

    assert ssj.main([str(source), "--source", str(source)]) == 2