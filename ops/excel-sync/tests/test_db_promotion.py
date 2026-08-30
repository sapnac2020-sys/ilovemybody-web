from pathlib import Path
import unittest


class PromotionImplementationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = (Path(__file__).parents[1] / "src" / "ilmb_sync" / "db.py").read_text(encoding="utf-8")

    def test_promotion_is_set_based_and_preserves_history(self):
        start = self.source.index("    def promote(")
        end = self.source.index("\n    def reconcile(", start)
        method = self.source[start:end]
        self.assertIn("INSERT INTO ilmb_canonical_record_history", method)
        self.assertIn("INSERT INTO ilmb_canonical_record", method)
        self.assertIn("SELECT SHA2(CONCAT_WS(CHAR(31)", method)
        self.assertIn("ON DUPLICATE KEY UPDATE", method)
        self.assertNotIn("for row in cur.fetchall()", method)

    def test_two_person_control_remains_enforced(self):
        self.assertIn('if batch["decision_by"] == approver:', self.source)
        self.assertIn("Two-person control", self.source)

    def test_bulk_operations_have_extended_timeout(self):
        self.assertIn("read_timeout=1800, write_timeout=1800", self.source)


if __name__ == "__main__":
    unittest.main()
