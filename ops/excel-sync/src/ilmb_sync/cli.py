from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from pathlib import Path

from .core import ModuleRegistry, WorkbookValidator, sha256_bytes


ROOT = Path(__file__).resolve().parents[2]


def env(name: str, required: bool = True, default: str | None = None) -> str:
    value = os.getenv(name, default)
    if required and not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value or ""


def get_db():
    from .db import Database
    return Database(host=env("ILMB_DB_HOST"), port=int(env("ILMB_DB_PORT", False, "3306")),
                    name=env("ILMB_DB_NAME"), user=env("ILMB_DB_USER"), password=env("ILMB_DB_PASSWORD"))


def registry() -> ModuleRegistry:
    return ModuleRegistry(env("ILMB_MODULE_CONFIG", False, str(ROOT / "config" / "modules.json")))


def cmd_doctor(_):
    checks = {}
    key = Path(env("ILMB_GOOGLE_KEY_FILE"))
    checks["google_key_readable"] = key.is_file() and os.access(key, os.R_OK)
    checks["drive_folder_configured"] = bool(env("ILMB_DRIVE_FOLDER_ID"))
    if checks["google_key_readable"]:
        from .drive import DriveReader
        files = list(DriveReader(str(key)).list_excel(env("ILMB_DRIVE_FOLDER_ID")))
        checks["drive_access"] = True
        checks["excel_files_visible"] = len(files)
    else:
        checks["drive_access"] = False
    try:
        get_db().ping(); checks["database_access"] = True
    except Exception as exc:
        checks["database_access"] = False; checks["database_error"] = f"{type(exc).__name__}: {exc}"
    print(json.dumps(checks, indent=2, default=str))
    if not all(checks.get(k) for k in ("google_key_readable", "drive_folder_configured", "drive_access", "database_access")):
        raise SystemExit(2)


def cmd_migrate(args):
    paths = [Path(args.sql)] if args.sql else sorted((ROOT / "migrations").glob("*.sql"))
    if not paths:
        raise RuntimeError("No migration files found")
    db = get_db()
    for path in paths:
        db.migrate(path)
        print(f"Applied: {path}")


def cmd_validate(args):
    content = Path(args.file).read_bytes()
    result = WorkbookValidator(registry()).validate_bytes(Path(args.file).name, content)
    print(json.dumps(result.summary(), indent=2, ensure_ascii=False, default=str))
    if not result.valid:
        raise SystemExit(2)


def cmd_scan(args):
    from .drive import DriveReader
    reader = DriveReader(env("ILMB_GOOGLE_KEY_FILE"))
    validator = WorkbookValidator(registry())
    db = None if args.dry_run else get_db()
    max_bytes = int(env("ILMB_MAX_FILE_MB", False, "100")) * 1024 * 1024
    report = []
    for item in reader.list_excel(env("ILMB_DRIVE_FOLDER_ID")):
        if item.size and item.size > max_bytes:
            report.append({"file": item.name, "status": "REJECTED_TOO_LARGE", "bytes": item.size}); continue
        if not registry().match(item.name):
            report.append({"file": item.name, "status": "SKIPPED_UNREGISTERED"}); continue
        content = reader.download(item.id)
        digest = sha256_bytes(content)
        if db and db.has_hash(item.id, digest):
            report.append({"file": item.name, "status": "UNCHANGED"}); continue
        result = validator.validate_bytes(item.name, content)
        entry = result.summary()
        entry["status"] = "VALID_DRY_RUN" if args.dry_run and result.valid else "REJECTED_DRY_RUN" if args.dry_run else "STAGED" if result.valid else "REJECTED_VALIDATION"
        if db:
            entry["batch_id"] = db.stage(item, result)
        report.append(entry)
    print(json.dumps(report, indent=2, ensure_ascii=False, default=str))


def cmd_batches(_):
    print(json.dumps(get_db().list_batches(), indent=2, default=str))


def cmd_approve(args):
    get_db().decide(args.batch_id, args.reviewer, True, args.reason); print("APPROVED", args.batch_id)


def cmd_reject(args):
    get_db().decide(args.batch_id, args.reviewer, False, args.reason); print("REJECTED", args.batch_id)


def cmd_promote(args):
    count = get_db().promote(args.batch_id, args.approver); print(f"PROMOTED {args.batch_id}: {count} rows")


def cmd_reconcile(args):
    result = get_db().reconcile(args.batch_id)
    print(json.dumps(result, indent=2, default=str))
    if not result["reconciled"]:
        raise SystemExit(2)


def parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="ilmb-sync")
    sub = p.add_subparsers(dest="command", required=True)
    sub.add_parser("doctor").set_defaults(func=cmd_doctor)
    m = sub.add_parser("migrate"); m.add_argument("--sql"); m.set_defaults(func=cmd_migrate)
    v = sub.add_parser("validate"); v.add_argument("file"); v.set_defaults(func=cmd_validate)
    s = sub.add_parser("scan"); s.add_argument("--dry-run", action="store_true"); s.set_defaults(func=cmd_scan)
    sub.add_parser("batches").set_defaults(func=cmd_batches)
    a = sub.add_parser("approve"); a.add_argument("batch_id"); a.add_argument("--reviewer", required=True); a.add_argument("--reason"); a.set_defaults(func=cmd_approve)
    r = sub.add_parser("reject"); r.add_argument("batch_id"); r.add_argument("--reviewer", required=True); r.add_argument("--reason", required=True); r.set_defaults(func=cmd_reject)
    pr = sub.add_parser("promote"); pr.add_argument("batch_id"); pr.add_argument("--approver", required=True); pr.set_defaults(func=cmd_promote)
    rc = sub.add_parser("reconcile"); rc.add_argument("batch_id"); rc.set_defaults(func=cmd_reconcile)
    return p


def main() -> None:
    logging.basicConfig(level=os.getenv("ILMB_LOG_LEVEL", "INFO"), format="%(asctime)s %(levelname)s %(message)s")
    try:
        args = parser().parse_args(); args.func(args)
    except KeyboardInterrupt:
        raise SystemExit(130)
    except Exception as exc:
        logging.error("%s: %s", type(exc).__name__, exc)
        if os.getenv("ILMB_LOG_LEVEL", "INFO").upper() == "DEBUG":
            raise
        raise SystemExit(1)


if __name__ == "__main__":
    main()
