import gzip
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from openpyxl import Workbook

from ilmb_sync.chebi import ChebiError, ManifestEntry, api_request, validate_entry
from ilmb_sync.core import ModuleRegistry, WorkbookValidator


class FakeResponse:
    def __init__(self, body, content_type="application/json"):
        self.body = io.BytesIO(body)
        self.headers = {"Content-Type": content_type, "Last-Modified": "Fri, 14 Aug 2026 10:00:00 GMT"}

    def read(self, size=-1):
        return self.body.read(size)

    def __enter__(self):
        return self

    def __exit__(self, *_):
        return False


class ChebiConnectorTests(unittest.TestCase):
    def test_api_rejects_unsafe_endpoint(self):
        with self.assertRaises(ChebiError):
            api_request("https://example.com/not-allowed")
        with self.assertRaises(ChebiError):
            api_request("/public/../admin")

    @patch("urllib.request.urlopen")
    def test_api_response_is_cached_with_lineage(self, urlopen):
        urlopen.return_value = FakeResponse(b'{"chebi_id":"CHEBI:15377"}')
        with tempfile.TemporaryDirectory() as temp:
            result = api_request("/public/example/", params={"id": "CHEBI:15377"}, cache_dir=temp)
            self.assertEqual(result["chebi_id"], "CHEBI:15377")
            cached = list(Path(temp).glob("*.json"))
            self.assertEqual(len(cached), 1)
            record = json.loads(cached[0].read_text())
            self.assertIn("retrieved_at", record)
            self.assertEqual(len(record["sha256"]), 64)

    def test_tsv_manifest_entry_validates_hash_size_and_rows(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            path = root / "status.tsv.gz"
            with gzip.open(path, "wt", encoding="utf-8") as handle:
                handle.write("id\tname\n1\tCHECKED\n2\tUNCHECKED\n")
            import hashlib
            entry = ManifestEntry(
                name="status", relative_url="flat_files/status.tsv.gz", file_name=path.name,
                byte_size=path.stat().st_size, sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                downloaded_at="2026-08-30T00:00:00+00:00", remote_last_modified=None,
                content_type="application/gzip", kind="tsv", required=True,
            )
            result = validate_entry(entry, root)
            self.assertEqual(result.validation_status, "PASS")
            self.assertEqual(result.row_count, 2)


class ChebiWorkbookRegistryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.root = Path(__file__).resolve().parents[1]
        cls.registry = ModuleRegistry(cls.root / "config" / "modules.json")

    def test_chebi_partitions_match_once(self):
        names = [
            "ILMB_ChEBI_01_Entities_Part_01_of_05_Release_2026-08-14.xlsx",
            "ILMB_ChEBI_02_Synonyms_Part_09_of_09_Release_2026-08-14.xlsx",
            "ILMB_ChEBI_08_Sources_Lookups_Release_2026-08-14.xlsx",
        ]
        for name in names:
            with self.subTest(name=name):
                rule = self.registry.match(name)
                self.assertIsNotNone(rule)
                self.assertEqual(rule["system_id"], "REF-CHEBI")

    def test_verified_entities_workbook_shape_is_accepted(self):
        wb = Workbook(); ws = wb.active; ws.title = "Entities"
        ws.append(["chebi_id", "canonical_name", "source_release"])
        ws.append(["CHEBI:15377", "water", "254"])
        out = io.BytesIO(); wb.save(out)
        result = WorkbookValidator(self.registry).validate_bytes(
            "ILMB_ChEBI_01_Entities_Part_01_of_05_Release_2026-08-14.xlsx", out.getvalue()
        )
        self.assertTrue(result.valid)
        self.assertEqual(result.rows[0].source_key, "CHEBI:15377")


if __name__ == "__main__":
    unittest.main()
