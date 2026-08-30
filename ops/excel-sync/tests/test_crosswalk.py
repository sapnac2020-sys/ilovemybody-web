import unittest

from ilmb_sync.core import stable_hash
from ilmb_sync.crosswalk import normalize_crosswalk


def valid_payload():
    return {
        "source_system": "CHEBI",
        "source_entity_type": "chemical",
        "source_id": "CHEBI:17234",
        "predicate": "measures",
        "target_system": "LOINC",
        "target_entity_type": "test",
        "target_id": "2345-7",
        "match_type": "EXACT",
        "status": "APPROVED",
        "evidence_source": "ILMB curator",
        "evidence_version": "2026-08-30",
        "confidence": 1,
    }


class CrosswalkTests(unittest.TestCase):
    def test_exact_approved_mapping_is_computation_eligible(self):
        row = normalize_crosswalk(valid_payload())
        self.assertTrue(row.computation_eligible)
        self.assertEqual(row.source_entity_type, "CHEMICAL")
        self.assertEqual(row.mapping_id, stable_hash("CHEBI", "CHEBI:17234", "MEASURES", "LOINC", "2345-7"))

    def test_candidate_mapping_is_not_computation_eligible(self):
        payload = valid_payload(); payload["match_type"] = "CANDIDATE"
        self.assertFalse(normalize_crosswalk(payload).computation_eligible)

    def test_draft_mapping_is_not_computation_eligible(self):
        payload = valid_payload(); payload["status"] = "DRAFT"
        self.assertFalse(normalize_crosswalk(payload).computation_eligible)

    def test_missing_evidence_version_is_rejected(self):
        payload = valid_payload(); payload["evidence_version"] = ""
        with self.assertRaises(ValueError):
            normalize_crosswalk(payload)

    def test_unknown_predicate_is_rejected(self):
        payload = valid_payload(); payload["predicate"] = "MAYBE_RELATED"
        with self.assertRaises(ValueError):
            normalize_crosswalk(payload)

    def test_invalid_confidence_is_rejected(self):
        payload = valid_payload(); payload["confidence"] = 1.2
        with self.assertRaises(ValueError):
            normalize_crosswalk(payload)

    def test_incorrect_supplied_mapping_id_is_rejected(self):
        payload = valid_payload(); payload["mapping_id"] = "wrong"
        with self.assertRaises(ValueError):
            normalize_crosswalk(payload)


if __name__ == "__main__":
    unittest.main()
