from __future__ import annotations

import argparse
import json
import os
from datetime import datetime
from typing import Any

from .body_need import (
    FormulaInputSpec,
    assess_formula_execution,
    duplicate_candidates,
    export_formula_master_xlsx,
    formula_duplicate_candidates,
    loinc_lookup,
)
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


def _latest_subject_observations(subject_key: str) -> list[dict[str, Any]]:
    return _query(
        """SELECT o.*
             FROM vw_ilmb_subject_parameter_observation o
             JOIN (
               SELECT parameter_id,MAX(observed_on) AS max_observed_on
                 FROM vw_ilmb_subject_parameter_observation
                WHERE subject_key=%s
                GROUP BY parameter_id
             ) latest
               ON latest.parameter_id=o.parameter_id
              AND latest.max_observed_on=o.observed_on
            WHERE o.subject_key=%s
            ORDER BY o.parameter_id,o.result_id DESC""",
        (subject_key, subject_key),
    )


def cmd_subject_observations(args: argparse.Namespace) -> None:
    rows = _latest_subject_observations(args.subject_key)
    print(json.dumps({"subject_key": args.subject_key, "observation_count": len(rows), "observations": rows}, indent=2, default=str))


def _load_override_json(value: str | None) -> dict[str, dict[str, Any]]:
    if not value:
        return {}
    if value.startswith("@"):
        with open(value[1:], "r", encoding="utf-8") as fh:
            payload = json.load(fh)
    else:
        payload = json.loads(value)
    if not isinstance(payload, dict):
        raise RuntimeError("Input override JSON must be an object keyed by formula symbol")
    return payload


def cmd_compute(args: argparse.Namespace) -> None:
    formulas = _query("SELECT * FROM ilmb_formula_master WHERE formula_key=%s", (args.formula_key,))
    if not formulas:
        raise RuntimeError(f"Unknown formula_key: {args.formula_key}")
    formula = formulas[0]
    formula_inputs = _query(
        "SELECT * FROM ilmb_formula_input WHERE formula_id=%s ORDER BY ordinal,formula_input_id",
        (formula["formula_id"],),
    )

    subject_rows = _latest_subject_observations(args.subject_key)
    by_parameter: dict[int, dict[str, Any]] = {}
    for row in subject_rows:
        pid = int(row["parameter_id"])
        by_parameter.setdefault(pid, row)

    observations: dict[str, dict[str, Any]] = {}
    specs: list[FormulaInputSpec] = []
    for row in formula_inputs:
        symbol = str(row["symbol_name"])
        specs.append(FormulaInputSpec(
            symbol=symbol,
            role=str(row["role"]),
            required=bool(row["required_flag"]),
            expected_unit=row.get("expected_ucum_unit"),
        ))
        measured = by_parameter.get(int(row["parameter_id"]))
        if measured:
            observations[symbol] = {
                "value": measured["observed_value"],
                "unit": measured.get("observed_unit"),
                "source": f"subject_test_result:{measured['result_id']}",
                "identifier_system": measured.get("identifier_system"),
                "identifier_code": measured.get("identifier_code"),
                "verified_source": bool(measured.get("verified_source")),
            }

    overrides = _load_override_json(args.input_json)
    for symbol, value in overrides.items():
        if not isinstance(value, dict) or "value" not in value:
            raise RuntimeError(f"Override for {symbol} must be an object containing value")
        observations[symbol] = value

    if formula.get("expression_language") != "ILMB_EXPR_V1":
        result = {
            "status": "BLOCKED_UNVERIFIED_FORMULA",
            "reason": f"Formula language {formula.get('expression_language')} is reference text, not executable ILMB_EXPR_V1",
        }
    else:
        result = assess_formula_execution(
            expression=str(formula["expression_text"]),
            formula_status=str(formula["formula_status"]),
            unit_checked=bool(formula["unit_checked"]),
            input_specs=specs,
            observations=observations,
        )

    output_unit = None
    if formula.get("output_parameter_id"):
        output_params = _query("SELECT canonical_ucum_unit FROM ilmb_parameter_master WHERE parameter_id=%s", (formula["output_parameter_id"],))
        if output_params:
            output_unit = output_params[0].get("canonical_ucum_unit")

    run_id = None
    if args.persist:
        with db().connect() as conn:
            try:
                with conn.cursor() as cur:
                    cur.execute(
                        """INSERT INTO ilmb_body_need_run
                           (subject_key,formula_id,observation_cutoff_at,input_snapshot_json,output_value,output_ucum_unit,
                            execution_status,blocking_reason,provenance_json)
                           VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                        (
                            args.subject_key,
                            formula["formula_id"],
                            datetime.utcnow(),
                            json.dumps(observations, default=str, ensure_ascii=False),
                            result.get("value") if result.get("status") == "COMPUTED" else None,
                            output_unit,
                            result["status"],
                            result.get("reason"),
                            json.dumps(result.get("provenance", {}), default=str, ensure_ascii=False),
                        ),
                    )
                    run_id = cur.lastrowid
                conn.commit()
            except Exception:
                conn.rollback()
                raise

    print(json.dumps({
        "subject_key": args.subject_key,
        "formula_key": args.formula_key,
        "formula_id": formula["formula_id"],
        "result": result,
        "output_ucum_unit": output_unit,
        "persisted": bool(args.persist),
        "body_need_run_id": run_id,
    }, indent=2, default=str))


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
    s = sub.add_parser("subject-observations", help="Resolve a subject's exact LOINC results into canonical ILMB parameters")
    s.add_argument("subject_key")
    s.set_defaults(func=cmd_subject_observations)
    c = sub.add_parser("compute", help="Execute one governed formula for one subject using exact resolved measurements")
    c.add_argument("subject_key")
    c.add_argument("formula_key")
    c.add_argument("--input-json", help="JSON object, or @path, for governed target/constant/context overrides")
    c.add_argument("--persist", action="store_true", help="Persist the governed run in ilmb_body_need_run")
    c.set_defaults(func=cmd_compute)
    return p


def main() -> None:
    args = parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
