from __future__ import annotations

import argparse
import json
import os
from typing import Any

from .body_need import duplicate_candidates, export_formula_master_xlsx, formula_duplicate_candidates, loinc_lookup
from .db import Database


def env(name: str, required: bool = True, default: str | None = None) -> str:
    value = os.getenv(name, default)
    if required and not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value or ""


def db() -> Database:
    return Database(
        host=env("ILMB_DB_HOST"),
        port=int(env("ILMB_DB_PORT", False, "3306")),
        name=env("ILMB_DB_NAME"),
        user=env("ILMB_DB_USER"),
        password=env("ILMB_DB_PASSWORD"),
    )


def _query(sql: str, args: tuple[Any, ...] = ()) -> list[dict[str, Any]]:
    with db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, args)
            return list(cur.fetchall())


def master_rows() -> dict[str, list[dict[str, Any]]]:
    return {
        "parameters": _query("SELECT * FROM ilmb_parameter_master ORDER BY parameter_id"),
        "identifiers": _query("SELECT * FROM ilmb_parameter_identifier ORDER BY parameter_id,identifier_system,identifier_code"),
        "formulas": _query("SELECT * FROM ilmb_formula_master ORDER BY formula_domain,formula_key"),
        "formula_inputs": _query("SELECT * FROM ilmb_formula_input ORDER BY formula_id,ordinal,formula_input_id"),
        "duplicates": _query("SELECT * FROM ilmb_parameter_duplicate_candidate ORDER BY disposition,confidence DESC,duplicate_candidate_id"),
        "formula_duplicates": _query("SELECT * FROM ilmb_formula_duplicate_candidate ORDER BY disposition,confidence DESC,formula_duplicate_candidate_id"),
    }


def cmd_audit(_args: argparse.Namespace) -> None:
    rows = master_rows()
    approved_ids = [x for x in rows["identifiers"] if x.get("verification_status") == "APPROVED"]
    by_system: dict[str, int] = {}
    for row in approved_ids:
        key = str(row["identifier_system"])
        by_system[key] = by_system.get(key, 0) + 1
    parameter_scan = duplicate_candidates(rows["parameters"], rows["identifiers"], rows["formulas"])
    formula_scan = formula_duplicate_candidates(rows["formulas"], rows["formula_inputs"])
    print(json.dumps({
        "parameters": len(rows["parameters"]),
        "identifiers": len(rows["identifiers"]),
        "approved_identifiers": len(approved_ids),
        "approved_identifiers_by_system": by_system,
        "formulas": len(rows["formulas"]),
        "approved_or_verified_formulas": sum(x.get("formula_status") in {"APPROVED", "VERIFIED"} for x in rows["formulas"]),
        "unit_checked_formulas": sum(bool(x.get("unit_checked")) for x in rows["formulas"]),
        "formula_inputs": len(rows["formula_inputs"]),
        "stored_parameter_duplicate_candidates": len(rows["duplicates"]),
        "computed_parameter_duplicate_candidates": len(parameter_scan),
        "stored_formula_duplicate_candidates": len(rows["formula_duplicates"]),
        "computed_formula_duplicate_candidates": len(formula_scan),
    }, indent=2, default=str))


def cmd_dedupe(args: argparse.Namespace) -> None:
    rows = master_rows()
    parameter_candidates = duplicate_candidates(rows["parameters"], rows["identifiers"], rows["formulas"])
    formula_candidates = formula_duplicate_candidates(rows["formulas"], rows["formula_inputs"])
    if args.persist:
        with db().connect() as conn:
            try:
                with conn.cursor() as cur:
                    for c in parameter_candidates:
                        cur.execute(
                            """INSERT INTO ilmb_parameter_duplicate_candidate
                               (left_parameter_id,right_parameter_id,reason_code,confidence,evidence_json)
                               VALUES (%s,%s,%s,%s,%s)
                               ON DUPLICATE KEY UPDATE confidence=VALUES(confidence),evidence_json=VALUES(evidence_json)""",
                            (c["left_parameter_id"], c["right_parameter_id"], c["reason"], c["confidence"], json.dumps(c["evidence"], ensure_ascii=False)),
                        )
                    for c in formula_candidates:
                        cur.execute(
                            """INSERT INTO ilmb_formula_duplicate_candidate
                               (left_formula_id,right_formula_id,reason_code,confidence,evidence_json)
                               VALUES (%s,%s,%s,%s,%s)
                               ON DUPLICATE KEY UPDATE confidence=VALUES(confidence),evidence_json=VALUES(evidence_json)""",
                            (c["left_formula_id"], c["right_formula_id"], c["reason"], c["confidence"], json.dumps(c["evidence"], ensure_ascii=False)),
                        )
                conn.commit()
            except Exception:
                conn.rollback()
                raise
    print(json.dumps({
        "parameter_candidate_count": len(parameter_candidates),
        "formula_candidate_count": len(formula_candidates),
        "persisted": bool(args.persist),
        "parameter_candidates": parameter_candidates,
        "formula_candidates": formula_candidates,
    }, indent=2, default=str))


def cmd_export(args: argparse.Namespace) -> None:
    rows = master_rows()
    if args.recompute_duplicates:
        rows["duplicates"] = duplicate_candidates(rows["parameters"], rows["identifiers"], rows["formulas"])
        rows["formula_duplicates"] = formula_duplicate_candidates(rows["formulas"], rows["formula_inputs"])
    path = export_formula_master_xlsx(
        args.output,
        parameters=rows["parameters"], identifiers=rows["identifiers"], formulas=rows["formulas"],
        formula_inputs=rows["formula_inputs"], duplicates=rows["duplicates"], formula_duplicates=rows["formula_duplicates"],
    )
    print(json.dumps({"output": str(path), "sheets": 7}, indent=2))


def cmd_loinc_lookup(args: argparse.Namespace) -> None:
    result = loinc_lookup(
        args.code,
        username=env("ILMB_LOINC_USERNAME"), password=env("ILMB_LOINC_PASSWORD"),
        base_url=env("ILMB_LOINC_FHIR_BASE", False, "https://fhir.loinc.org"), timeout=args.timeout,
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))


def parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="ilmb-body-need")
    sub = p.add_subparsers(dest="command", required=True)
    sub.add_parser("audit", help="Audit canonical parameters, identifiers, formulas and duplicate signals").set_defaults(func=cmd_audit)
    d = sub.add_parser("dedupe", help="Find duplicate parameter/formula candidates without deleting anything")
    d.add_argument("--persist", action="store_true", help="Write candidate signals to governed review registers")
    d.set_defaults(func=cmd_dedupe)
    e = sub.add_parser("export-excel", help="Export the governed Formula Master workbook")
    e.add_argument("--output", required=True)
    e.add_argument("--recompute-duplicates", action="store_true")
    e.set_defaults(func=cmd_export)
    l = sub.add_parser("loinc-lookup", help="Resolve one LOINC code using the official FHIR terminology service")
    l.add_argument("code")
    l.add_argument("--timeout", type=int, default=30)
    l.set_defaults(func=cmd_loinc_lookup)
    return p


def main() -> None:
    args = parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
