import io
import json
import tempfile
import unittest
from pathlib import Path

from openpyxl import Workbook

from ilmb_sync.core import ModuleRegistry, WorkbookValidator


def workbook(rows, duplicate_header=False):
    wb = Workbook(); ws = wb.active; ws.title = "02_NUTRIENTS"
    ws.append(["Record_ID", "Name" if not duplicate_header else "Record_ID"])
    for row in rows: ws.append(row)
    out = io.BytesIO(); wb.save(out); return out.getvalue()


class ValidatorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        path = Path(self.temp.name) / "modules.json"
        path.write_text(json.dumps({"modules": [{"pattern": "*Nutrition*.xlsx", "system_id": "SYS-003"}]}))
        self.validator = WorkbookValidator(ModuleRegistry(path))

    def tearDown(self):
        self.temp.cleanup()

    def test_real_rows_stage_and_placeholder_excluded(self):
        result = self.validator.validate_bytes("Nutrition_Food_Medicine.xlsx", workbook([
            ["N-001", "Protein"], ["Example nutrient", "Example"]]))
        self.assertTrue(result.valid)
        self.assertEqual(len(result.rows), 1)
        self.assertEqual(result.rows[0].source_key, "N-001")
        self.assertTrue(any(x.code == "PLACEHOLDER_ROW" for x in result.issues))

    def test_duplicate_keys_are_rejected(self):
        result = self.validator.validate_bytes("Nutrition.xlsx", workbook([
            ["N-001", "Protein"], ["N-001", "Protein"]]))
        self.assertFalse(result.valid)
        self.assertTrue(any(x.code == "DUPLICATE_IDENTICAL_ROW" for x in result.issues))

    def test_repeated_parent_key_gets_composite(self):
        result = self.validator.validate_bytes("Nutrition.xlsx", workbook([
            ["N-001", "Protein"], ["N-001", "Protein revised"]]))
        self.assertTrue(result.valid)
        self.assertEqual(len(result.rows), 2)
        self.assertTrue(any(x.code == "COMPOSITE_SOURCE_KEY" for x in result.issues))

    def test_duplicate_headers_are_rejected(self):
        result = self.validator.validate_bytes("Nutrition.xlsx", workbook([
            ["N-001", "Protein"]], duplicate_header=True))
        self.assertFalse(result.valid)
        self.assertTrue(any(x.code == "DUPLICATE_HEADER" for x in result.issues))

    def test_unregistered_file_is_rejected(self):
        result = self.validator.validate_bytes("Unknown.xlsx", workbook([["X", "Y"]]))
        self.assertFalse(result.valid)
        self.assertEqual(result.issues[0].code, "UNREGISTERED_FILE")


if __name__ == "__main__":
    unittest.main()
