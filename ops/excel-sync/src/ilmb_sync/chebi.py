from __future__ import annotations

import csv
import gzip
import hashlib
import json
import os
import re
import shutil
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, BinaryIO, Iterable


OFFICIAL_DOWNLOAD_BASE = "https://ftp.ebi.ac.uk/pub/databases/chebi"
OFFICIAL_API_BASE = "https://www.ebi.ac.uk/chebi/backend/api"
USER_AGENT = "ILMB-ChEBI-Connector/1.0 (+https://ilovemybody.in)"


@dataclass(frozen=True)
class SourceSpec:
    name: str
    relative_url: str
    kind: str
    minimum_rows: int = 0
    required: bool = True


# Conservative lower bounds catch truncated/error-page downloads without freezing
# ILMB to one exact ChEBI release. Exact release totals are recorded in the manifest.
SOURCE_SPECS = (
    SourceSpec("ontology", "ontology/chebi.obo.gz", "obo", 180_000),
    SourceSpec("chemical_data", "flat_files/chemical_data.tsv.gz", "tsv", 150_000),
    SourceSpec("comments", "flat_files/comments.tsv.gz", "tsv", 3_000),
    SourceSpec("compound_origins", "flat_files/compound_origins.tsv.gz", "tsv", 60_000),
    SourceSpec("compounds", "flat_files/compounds.tsv.gz", "tsv", 180_000),
    SourceSpec("database_accession", "flat_files/database_accession.tsv.gz", "tsv", 350_000),
    SourceSpec("names", "flat_files/names.tsv.gz", "tsv", 350_000),
    SourceSpec("relation", "flat_files/relation.tsv.gz", "tsv", 300_000),
    SourceSpec("relation_type", "flat_files/relation_type.tsv.gz", "tsv", 5),
    SourceSpec("secondary_ids", "flat_files/secondary_ids.tsv.gz", "tsv", 15_000),
    SourceSpec("source", "flat_files/source.tsv.gz", "tsv", 50),
    SourceSpec("status", "flat_files/status.tsv.gz", "tsv", 2),
    SourceSpec("structure_registry", "flat_files/structure_registry.tsv.gz", "tsv", 180_000),
    SourceSpec("structures", "flat_files/structures.tsv.gz", "tsv", 180_000),
    SourceSpec("wurcs", "flat_files/wurcs.tsv.gz", "tsv", 8_000),
    SourceSpec("sdf", "SDF/chebi.sdf.gz", "sdf", 150_000, required=False),
)


@dataclass
class ManifestEntry:
    name: str
    relative_url: str
    file_name: str
    byte_size: int
    sha256: str
    downloaded_at: str
    remote_last_modified: str | None
    content_type: str | None
    kind: str
    required: bool
    row_count: int | None = None
    validation_status: str = "NOT_VALIDATED"
    validation_message: str | None = None


class ChebiError(RuntimeError):
    pass


def _utcnow() -> str:
    return datetime.now(timezone.utc).isoformat()


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _safe_release_label(value: str | None) -> str:
    label = value or datetime.now(timezone.utc).strftime("%Y-%m-%d")
    if not re.fullmatch(r"[A-Za-z0-9._-]{1,80}", label):
        raise ChebiError("Release label may contain only letters, digits, dot, underscore and hyphen")
    return label


def _request(url: str, timeout: int) -> urllib.response.addinfourl:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "*/*"})
    try:
        return urllib.request.urlopen(request, timeout=timeout)
    except urllib.error.HTTPError as exc:
        raise ChebiError(f"ChEBI returned HTTP {exc.code} for {url}") from exc
    except urllib.error.URLError as exc:
        raise ChebiError(f"Could not reach ChEBI for {url}: {exc.reason}") from exc


def _download(url: str, target: Path, *, timeout: int, force: bool) -> tuple[int, str, str | None, str | None]:
    if target.exists() and not force:
        return target.stat().st_size, _sha256_file(target), None, None
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix(target.suffix + ".part")
    if temporary.exists():
        temporary.unlink()
    digest = hashlib.sha256()
    size = 0
    try:
        with _request(url, timeout) as response, temporary.open("wb") as output:
            content_type = response.headers.get("Content-Type")
            last_modified = response.headers.get("Last-Modified")
            while True:
                chunk = response.read(1024 * 1024)
                if not chunk:
                    break
                output.write(chunk)
                digest.update(chunk)
                size += len(chunk)
        if size == 0:
            raise ChebiError(f"Empty download: {url}")
        temporary.replace(target)
        return size, digest.hexdigest(), last_modified, content_type
    except Exception:
        if temporary.exists():
            temporary.unlink()
        raise


def _count_tsv(path: Path) -> tuple[int, list[str]]:
    with gzip.open(path, "rt", encoding="utf-8-sig", errors="strict", newline="") as handle:
        reader = csv.reader(handle, delimiter="\t")
        try:
            header = next(reader)
        except StopIteration as exc:
            raise ChebiError(f"Empty TSV: {path.name}") from exc
        if len(header) < 2 or len(set(header)) != len(header):
            raise ChebiError(f"Invalid or duplicate TSV headers in {path.name}")
        count = sum(1 for row in reader if any(cell.strip() for cell in row))
    return count, header


def _count_obo(path: Path) -> tuple[int, str | None]:
    terms = 0
    version = None
    with gzip.open(path, "rt", encoding="utf-8", errors="strict") as handle:
        for line in handle:
            if line == "[Term]\n":
                terms += 1
            elif version is None and line.startswith("data-version:"):
                version = line.split(":", 1)[1].strip()
    return terms, version


def _count_sdf(path: Path) -> int:
    records = 0
    with gzip.open(path, "rb") as handle:
        for line in handle:
            if line.rstrip(b"\r\n") == b"$$$$":
                records += 1
    return records


def validate_entry(entry: ManifestEntry, release_dir: Path) -> ManifestEntry:
    path = release_dir / entry.file_name
    try:
        if not path.is_file():
            raise ChebiError("File is missing")
        if path.stat().st_size != entry.byte_size:
            raise ChebiError("Byte size differs from manifest")
        if _sha256_file(path) != entry.sha256:
            raise ChebiError("SHA-256 differs from manifest")
        spec = next(item for item in SOURCE_SPECS if item.name == entry.name)
        if entry.kind == "tsv":
            count, header = _count_tsv(path)
            if count < spec.minimum_rows:
                raise ChebiError(f"Only {count:,} rows; minimum gate is {spec.minimum_rows:,}")
            entry.validation_message = f"TSV readable; {len(header)} columns"
        elif entry.kind == "obo":
            count, version = _count_obo(path)
            if count < spec.minimum_rows:
                raise ChebiError(f"Only {count:,} ontology terms; minimum gate is {spec.minimum_rows:,}")
            entry.validation_message = f"OBO readable; data-version={version or 'not declared'}"
        elif entry.kind == "sdf":
            count = _count_sdf(path)
            if count < spec.minimum_rows:
                raise ChebiError(f"Only {count:,} SDF records; minimum gate is {spec.minimum_rows:,}")
            entry.validation_message = "SDF gzip readable"
        else:
            raise ChebiError(f"Unsupported source kind: {entry.kind}")
        entry.row_count = count
        entry.validation_status = "PASS"
    except Exception as exc:
        entry.validation_status = "FAIL"
        entry.validation_message = str(exc)
    return entry


def fetch_release(
    work_dir: str | Path,
    *,
    release_label: str | None = None,
    include_sdf: bool = False,
    force: bool = False,
    timeout: int = 120,
    download_base: str = OFFICIAL_DOWNLOAD_BASE,
) -> Path:
    label = _safe_release_label(release_label)
    root = Path(work_dir).expanduser().resolve()
    release_dir = root / "chebi" / "releases" / label
    release_dir.mkdir(parents=True, exist_ok=True)
    entries: list[ManifestEntry] = []
    selected = [spec for spec in SOURCE_SPECS if include_sdf or spec.name != "sdf"]
    for spec in selected:
        url = download_base.rstrip("/") + "/" + spec.relative_url
        target = release_dir / Path(spec.relative_url).name
        size, digest, modified, content_type = _download(url, target, timeout=timeout, force=force)
        entry = ManifestEntry(
            name=spec.name,
            relative_url=spec.relative_url,
            file_name=target.name,
            byte_size=size,
            sha256=digest,
            downloaded_at=_utcnow(),
            remote_last_modified=modified,
            content_type=content_type,
            kind=spec.kind,
            required=spec.required,
        )
        entries.append(validate_entry(entry, release_dir))
        _write_manifest(release_dir, label, entries, complete=False)
    required_failures = [entry.name for entry in entries if entry.required and entry.validation_status != "PASS"]
    manifest = _write_manifest(release_dir, label, entries, complete=not required_failures)
    if required_failures:
        raise ChebiError("Required ChEBI validation failed: " + ", ".join(required_failures))
    return manifest


def _write_manifest(release_dir: Path, label: str, entries: Iterable[ManifestEntry], *, complete: bool) -> Path:
    manifest_path = release_dir / "manifest.json"
    payload = {
        "schema_version": 1,
        "source": "EMBL-EBI ChEBI",
        "download_base": OFFICIAL_DOWNLOAD_BASE,
        "release_label": label,
        "generated_at": _utcnow(),
        "complete": complete,
        "files": [asdict(entry) for entry in entries],
    }
    temporary = manifest_path.with_suffix(".json.part")
    temporary.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    temporary.replace(manifest_path)
    return manifest_path


def validate_manifest(path: str | Path) -> dict[str, Any]:
    manifest_path = Path(path).expanduser().resolve()
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    release_dir = manifest_path.parent
    entries = [validate_entry(ManifestEntry(**item), release_dir) for item in payload.get("files", [])]
    present = {entry.name for entry in entries}
    required = {spec.name for spec in SOURCE_SPECS if spec.required}
    missing = sorted(required - present)
    failures = [entry.name for entry in entries if entry.required and entry.validation_status != "PASS"]
    payload["files"] = [asdict(entry) for entry in entries]
    payload["missing_required_sources"] = missing
    payload["complete"] = not missing and not failures
    payload["validated_at"] = _utcnow()
    return payload


def api_request(
    endpoint: str,
    *,
    params: dict[str, str] | None = None,
    api_base: str = OFFICIAL_API_BASE,
    timeout: int = 30,
    cache_dir: str | Path | None = None,
) -> dict[str, Any] | list[Any]:
    if not endpoint.startswith("/") or endpoint.startswith("//") or ".." in endpoint.split("/"):
        raise ChebiError("API endpoint must be an absolute safe path such as /public/.../")
    query = urllib.parse.urlencode(params or {})
    url = api_base.rstrip("/") + endpoint + (("?" + query) if query else "")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read()
    except urllib.error.HTTPError as exc:
        detail = exc.read(1000).decode("utf-8", errors="replace")
        raise ChebiError(f"ChEBI API HTTP {exc.code}: {detail}") from exc
    except urllib.error.URLError as exc:
        raise ChebiError(f"Could not reach ChEBI API: {exc.reason}") from exc
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise ChebiError("ChEBI API did not return valid JSON") from exc
    if cache_dir:
        cache = Path(cache_dir).expanduser().resolve()
        cache.mkdir(parents=True, exist_ok=True)
        key = hashlib.sha256(url.encode("utf-8")).hexdigest()
        record = {"url": url, "retrieved_at": _utcnow(), "sha256": hashlib.sha256(raw).hexdigest(), "response": payload}
        (cache / f"{key}.json").write_text(json.dumps(record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return payload

