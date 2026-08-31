from __future__ import annotations

import argparse
import csv
import gzip
import hashlib
import json
import math
import re
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

from openpyxl import Workbook

RELEASE = "2026-08-14"
EXCEL_CELL_LIMIT = 32767
MOL_CHUNK_SIZE = 30000

MODULES = [
    {
        "code": "03", "name": "Relationships", "source": "relation.tsv.gz",
        "sheet": "Relationships", "parts": 9, "expected": 408817,
    },
    {
        "code": "04", "name": "Chemical_Data", "source": "chemical_data.tsv.gz",
        "sheet": "Chemical_Data", "parts": 5, "expected": 202351,
    },
    {
        "code": "05", "name": "Core_Structures", "source": "structures.tsv.gz",
        "sheet": "Core_Structures", "parts": 5, "expected": 201362,
        "transform": "core_structures",
    },
    {
        "code": "06", "name": "Molfile_Chunks", "source": "structures.tsv.gz",
        "sheet": "Molfile_Chunks", "parts": 42, "expected": 201450,
        "transform": "molfile_chunks",
    },
    {
        "code": "07", "name": "Structure_Registry", "source": "structure_registry.tsv.gz",
        "sheet": "Structure_Registry", "parts": 5, "expected": 215365,
    },
    {
        "code": "09", "name": "WURCS", "source": "wurcs.tsv.gz",
        "sheet": "WURCS", "parts": 1, "expected": 11441,
    },
    {
        "code": "10", "name": "Database_Accessions", "source": "database_accession.tsv.gz",
        "sheet": "Database_Accessions", "parts": 9, "expected": 422748,
    },
    {
        "code": "11", "name": "Secondary_IDs", "source": "secondary_ids.tsv.gz",
        "sheet": "Secondary_IDs", "parts": 1, "expected": 19421,
    },
    {
        "code": "12", "name": "Compound_Origins", "source": "compound_origins.tsv.gz",
        "sheet": "Compound_Origins", "parts": 2, "expected": 81324,
    },
    {
        "code": "13", "name": "Curator_Comments", "source": "comments.tsv.gz",
        "sheet": "Curator_Comments", "parts": 1, "expected": 4414,
    },
]

def snake(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9]+", "_", value.strip()).strip("_").lower()
    return value or "field"

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def source_rows(path: Path) -> tuple[list[str], list[list[str]]]:
    with gzip.open(path, "rt", encoding="utf-8-sig", errors="strict", newline="") as f:
        reader = csv.reader(f, delimiter="\t")
        raw_header = next(reader)
        header = [snake(x) for x in raw_header]
        if len(header) != len(set(header)):
            raise RuntimeError(f"Duplicate normalized headers in {path.name}")
        rows = [row for row in reader if any(cell.strip() for cell in row)]
    return header, rows

def structure_column(header: list[str]) -> int:
    preferred = ("structure", "molfile", "mol_file")
    for name in preferred:
        if name in header:
            return header.index(name)
    raise RuntimeError("structures.tsv.gz has no structure/molfile column")

def transformed(module: dict, header: list[str], rows: list[list[str]]) -> tuple[list[str], list[list[str]]]:
    mode = module.get("transform")
    if mode == "core_structures":
        sidx = structure_column(header)
        out_header = [h for i, h in enumerate(header) if i != sidx]
        return out_header, [[v for i, v in enumerate(row) if i != sidx] for row in rows]
    if mode == "molfile_chunks":
        sidx = structure_column(header)
        id_idx = header.index("id") if "id" in header else None
        compound_idx = header.index("compound_id") if "compound_id" in header else None
        out = []
        for row in rows:
            structure = row[sidx] if sidx < len(row) else ""
            chebi_raw = row[compound_idx] if compound_idx is not None and compound_idx < len(row) else ""
            chebi_id = chebi_raw if str(chebi_raw).upper().startswith("CHEBI:") else f"CHEBI:{chebi_raw}"
            structure_id = row[id_idx] if id_idx is not None and id_idx < len(row) else ""
            pieces = [structure[i:i + MOL_CHUNK_SIZE] for i in range(0, len(structure), MOL_CHUNK_SIZE)] or [""]
            for ordinal, piece in enumerate(pieces, 1):
                out.append([chebi_id, ordinal, structure_id, len(structure), piece])
        return ["chebi_id", "chunk_ordinal", "structure_id", "structure_characters", "chunk_text"], out
    return header, rows

def file_name(module: dict, part: int) -> str:
    return (
        f"ILMB_ChEBI_{module['code']}_{module['name']}_Part_{part:02d}_of_"
        f"{module['parts']:02d}_Release_{RELEASE}.xlsx"
    )

def write_book(path: Path, sheet_name: str, header: list[str], rows: Iterable[list[str]]) -> int:
    wb = Workbook(write_only=True)
    ws = wb.create_sheet(sheet_name)
    ws.append(header)
    count = 0
    for row in rows:
        safe = []
        for value in row:
            text = "" if value is None else str(value)
            if len(text) > EXCEL_CELL_LIMIT:
                raise RuntimeError(f"Cell exceeds Excel limit in {path.name}")
            safe.append(text)
        ws.append(safe)
        count += 1
    wb.save(path)
    return count

def partition(rows: list[list[str]], parts: int) -> list[list[list[str]]]:
    size = math.ceil(len(rows) / parts)
    return [rows[i * size:min((i + 1) * size, len(rows))] for i in range(parts)]

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--release-dir", required=True)
    ap.add_argument("--output-dir", required=True)
    args = ap.parse_args()
    release_dir = Path(args.release_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = release_dir / "manifest.json"
    if not manifest_path.is_file():
        raise SystemExit("Missing connector manifest.json")
    source_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if not source_manifest.get("complete"):
        raise SystemExit("ChEBI source manifest is not complete")

    registry = []
    module_totals = {}
    for module in MODULES:
        header, rows = source_rows(release_dir / module["source"])
        out_header, out_rows = transformed(module, header, rows)
        actual = len(out_rows)
        if actual != module["expected"]:
            raise RuntimeError(
                f"{module['name']} row gate failed: expected {module['expected']}, got {actual}"
            )
        chunks = partition(out_rows, module["parts"])
        if len(chunks) != module["parts"] or any(not c for c in chunks):
            raise RuntimeError(f"{module['name']} partition continuity failed")
        total = 0
        for part_no, part_rows in enumerate(chunks, 1):
            target = output_dir / file_name(module, part_no)
            count = write_book(target, module["sheet"], out_header, part_rows)
            total += count
            registry.append({
                "module": module["name"],
                "part_number": part_no,
                "total_parts": module["parts"],
                "file_name": target.name,
                "sheet": module["sheet"],
                "row_count": count,
                "byte_size": target.stat().st_size,
                "sha256": sha256(target),
                "source_file": module["source"],
                "release": RELEASE,
                "status": "REGENERATED_PENDING_INGESTION",
            })
        if total != module["expected"]:
            raise RuntimeError(f"{module['name']} workbook reconciliation failed")
        module_totals[module["name"]] = total

    if len(registry) != 80:
        raise RuntimeError(f"File-count gate failed: expected 80, got {len(registry)}")
    expected_total = sum(m["expected"] for m in MODULES)
    actual_total = sum(module_totals.values())
    if actual_total != expected_total:
        raise RuntimeError(f"Total row gate failed: expected {expected_total}, got {actual_total}")

    final = {
        "schema_version": 1,
        "source": "EMBL-EBI ChEBI official bulk files",
        "release": RELEASE,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_manifest_sha256": sha256(manifest_path),
        "file_count": len(registry),
        "row_count": actual_total,
        "module_totals": module_totals,
        "files": registry,
        "status": "VERIFIED_REGENERATION_PENDING_DATABASE_INGESTION",
    }
    (output_dir / "ILMB_ChEBI_Remaining_80_Manifest.json").write_text(
        json.dumps(final, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    zip_path = output_dir / "ILMB_ChEBI_Remaining_80_Release_2026-08-14.zip"
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as zf:
        for item in registry:
            zf.write(output_dir / item["file_name"], item["file_name"])
        zf.write(output_dir / "ILMB_ChEBI_Remaining_80_Manifest.json",
                 "ILMB_ChEBI_Remaining_80_Manifest.json")
    print(json.dumps({
        "ok": True,
        "file_count": len(registry),
        "row_count": actual_total,
        "zip": str(zip_path),
        "zip_sha256": sha256(zip_path),
        "manifest": str(output_dir / "ILMB_ChEBI_Remaining_80_Manifest.json"),
    }, indent=2))

if __name__ == "__main__":
    main()
