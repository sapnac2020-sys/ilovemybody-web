from __future__ import annotations

import json
import uuid
from pathlib import Path
from typing import Any

import pymysql

from .core import ValidationResult, canonical_json, stable_hash, utcnow


class Database:
    def __init__(self, *, host: str, port: int, name: str, user: str, password: str):
        self.params = dict(host=host, port=port, database=name, user=user, password=password,
                           charset="utf8mb4", autocommit=False, cursorclass=pymysql.cursors.DictCursor,
                           connect_timeout=10, read_timeout=60, write_timeout=60)

    def connect(self):
        return pymysql.connect(**self.params)

    def migrate(self, sql_path: str | Path) -> None:
        sql = Path(sql_path).read_text(encoding="utf-8")
        statements = [x.strip() for x in sql.split(";\n") if x.strip()]
        with self.connect() as conn:
            with conn.cursor() as cur:
                for statement in statements:
                    cur.execute(statement)
            conn.commit()

    def ping(self) -> None:
        with self.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1 AS ok")
                assert cur.fetchone()["ok"] == 1

    def stage(self, drive_file: Any, result: ValidationResult) -> str:
        batch_id = str(uuid.uuid4())
        now = utcnow()
        modified = drive_file.modified_time.replace(tzinfo=None) if drive_file.modified_time else None
        with self.connect() as conn:
            try:
                with conn.cursor() as cur:
                    cur.execute("""INSERT INTO ilmb_sync_file
                      (drive_file_id,file_name,system_id,drive_modified_time,last_seen_hash,last_seen_at,enabled)
                      VALUES (%s,%s,%s,%s,%s,%s,1)
                      ON DUPLICATE KEY UPDATE file_name=VALUES(file_name),system_id=VALUES(system_id),
                      drive_modified_time=VALUES(drive_modified_time),last_seen_hash=VALUES(last_seen_hash),last_seen_at=VALUES(last_seen_at)""",
                      (drive_file.id, drive_file.name, result.system_id, modified, result.content_hash, now))
                    status = "STAGED" if result.valid else "REJECTED_VALIDATION"
                    cur.execute("""INSERT INTO ilmb_sync_batch
                      (batch_id,drive_file_id,file_name,system_id,content_hash,drive_modified_time,status,row_count,error_count,created_at,staged_at)
                      VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                      (batch_id, drive_file.id, drive_file.name, result.system_id, result.content_hash, modified,
                       status, len(result.rows), sum(x.severity == "ERROR" for x in result.issues), now, now if result.valid else None))
                    if result.valid:
                        cur.executemany("""INSERT INTO ilmb_sync_stage_row
                          (batch_id,row_id,system_id,sheet_name,source_row,source_key,row_hash,payload_json)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""", [
                            (batch_id, x.row_id, x.system_id, x.sheet_name, x.source_row, x.source_key, x.row_hash, canonical_json(x.payload)) for x in result.rows
                        ])
                    if result.issues:
                        cur.executemany("""INSERT INTO ilmb_sync_validation_error
                          (batch_id,severity,code,sheet_name,source_row,message,created_at)
                          VALUES (%s,%s,%s,%s,%s,%s,%s)""", [
                            (batch_id, x.severity, x.code, x.sheet_name, x.source_row, x.message, now) for x in result.issues
                        ])
                    self._audit(cur, "sync-worker", "BATCH_STAGED" if result.valid else "BATCH_VALIDATION_REJECTED", batch_id, result.summary())
                conn.commit()
            except Exception:
                conn.rollback()
                raise
        return batch_id

    def has_hash(self, file_id: str, content_hash: str) -> bool:
        with self.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1 FROM ilmb_sync_batch WHERE drive_file_id=%s AND content_hash=%s LIMIT 1", (file_id, content_hash))
                return cur.fetchone() is not None

    def decide(self, batch_id: str, reviewer: str, approved: bool, reason: str | None = None) -> None:
        target = "APPROVED" if approved else "REJECTED"
        with self.connect() as conn:
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT status FROM ilmb_sync_batch WHERE batch_id=%s FOR UPDATE", (batch_id,))
                    row = cur.fetchone()
                    if not row or row["status"] != "STAGED":
                        raise ValueError("Batch must exist and be STAGED")
                    cur.execute("UPDATE ilmb_sync_batch SET status=%s,decided_at=%s,decision_by=%s,decision_reason=%s WHERE batch_id=%s",
                                (target, utcnow(), reviewer, reason, batch_id))
                    self._audit(cur, reviewer, "BATCH_" + target, batch_id, {"reason": reason})
                conn.commit()
            except Exception:
                conn.rollback(); raise

    def promote(self, batch_id: str, approver: str) -> int:
        now = utcnow()
        count = 0
        with self.connect() as conn:
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT status,decision_by FROM ilmb_sync_batch WHERE batch_id=%s FOR UPDATE", (batch_id,))
                    batch = cur.fetchone()
                    if not batch or batch["status"] != "APPROVED":
                        raise ValueError("Batch must be APPROVED")
                    if batch["decision_by"] == approver:
                        raise ValueError("Two-person control: promoter must differ from reviewer")
                    cur.execute("SELECT * FROM ilmb_sync_stage_row WHERE batch_id=%s ORDER BY sheet_name,source_key", (batch_id,))
                    for row in cur.fetchall():
                        cid = stable_hash(row["system_id"], row["sheet_name"], row["source_key"])
                        cur.execute("SELECT version_no FROM ilmb_canonical_record WHERE canonical_id=%s FOR UPDATE", (cid,))
                        old = cur.fetchone()
                        version = (old["version_no"] + 1) if old else 1
                        cur.execute("""INSERT INTO ilmb_canonical_record
                          (canonical_id,system_id,sheet_name,source_key,payload_json,row_hash,source_batch_id,version_no,active,effective_at)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s,1,%s)
                          ON DUPLICATE KEY UPDATE payload_json=VALUES(payload_json),row_hash=VALUES(row_hash),
                          source_batch_id=VALUES(source_batch_id),version_no=VALUES(version_no),active=1,effective_at=VALUES(effective_at)""",
                          (cid,row["system_id"],row["sheet_name"],row["source_key"],row["payload_json"],row["row_hash"],batch_id,version,now))
                        count += 1
                    cur.execute("UPDATE ilmb_sync_batch SET status='PROMOTED',promoted_at=%s WHERE batch_id=%s", (now,batch_id))
                    self._audit(cur, approver, "BATCH_PROMOTED", batch_id, {"row_count": count})
                conn.commit()
            except Exception:
                conn.rollback(); raise
        return count

    def list_batches(self) -> list[dict[str, Any]]:
        with self.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT batch_id,file_name,system_id,status,row_count,error_count,created_at,decision_by FROM ilmb_sync_batch ORDER BY created_at DESC LIMIT 100")
                return list(cur.fetchall())

    @staticmethod
    def _audit(cur, actor: str, event: str, batch_id: str | None, details: dict[str, Any]) -> None:
        cur.execute("INSERT INTO ilmb_sync_audit(event_time,actor,event_type,batch_id,details_json) VALUES (%s,%s,%s,%s,%s)",
                    (utcnow(), actor, event, batch_id, canonical_json(details)))
