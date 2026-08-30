from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .core import canonical_json, stable_hash


ENTITY_TYPES = {"CHEMICAL", "TEST", "FOOD", "NUTRIENT", "MEDICINE", "BODY", "CELL", "PROTEIN", "PATHWAY", "PHENOTYPE"}
MATCH_TYPES = {"EXACT", "BROADER", "NARROWER", "RELATED", "CANDIDATE"}
STATUSES = {"DRAFT", "APPROVED", "REJECTED", "RETIRED"}
PREDICATES = {
    "MEASURES", "HAS_COMPONENT", "HAS_ACTIVE_INGREDIENT", "CONTAINS",
    "METABOLIZED_BY", "ACTS_ON", "LOCATED_IN", "PARTICIPATES_IN",
    "ASSOCIATED_WITH", "SAME_AS",
}
REQUIRED_FIELDS = (
    "source_system", "source_entity_type", "source_id", "predicate",
    "target_system", "target_entity_type", "target_id", "match_type",
    "status", "evidence_source", "evidence_version",
)


@dataclass(frozen=True)
class CrosswalkRow:
    mapping_id: str
    source_system: str
    source_entity_type: str
    source_id: str
    predicate: str
    target_system: str
    target_entity_type: str
    target_id: str
    match_type: str
    status: str
    evidence_source: str
    evidence_version: str
    evidence_locator: str | None
    confidence: float | None
    computation_eligible: bool
    row_hash: str


def _text(payload: dict[str, Any], field: str) -> str:
    return str(payload.get(field, "")).strip()


def normalize_crosswalk(payload: dict[str, Any]) -> CrosswalkRow:
    missing = [field for field in REQUIRED_FIELDS if not _text(payload, field)]
    if missing:
        raise ValueError("Missing required crosswalk fields: " + ", ".join(missing))

    source_type = _text(payload, "source_entity_type").upper()
    target_type = _text(payload, "target_entity_type").upper()
    predicate = _text(payload, "predicate").upper()
    match_type = _text(payload, "match_type").upper()
    status = _text(payload, "status").upper()
    if source_type not in ENTITY_TYPES or target_type not in ENTITY_TYPES:
        raise ValueError(f"Unsupported entity type: {source_type} -> {target_type}")
    if predicate not in PREDICATES:
        raise ValueError(f"Unsupported predicate: {predicate}")
    if match_type not in MATCH_TYPES:
        raise ValueError(f"Unsupported match type: {match_type}")
    if status not in STATUSES:
        raise ValueError(f"Unsupported status: {status}")

    raw_confidence = payload.get("confidence")
    confidence = None if raw_confidence in (None, "") else float(raw_confidence)
    if confidence is not None and not 0 <= confidence <= 1:
        raise ValueError("confidence must be between 0 and 1")

    source_system = _text(payload, "source_system").upper()
    target_system = _text(payload, "target_system").upper()
    source_id = _text(payload, "source_id")
    target_id = _text(payload, "target_id")
    evidence_source = _text(payload, "evidence_source")
    evidence_version = _text(payload, "evidence_version")
    natural = stable_hash(source_system, source_id, predicate, target_system, target_id)
    supplied = _text(payload, "mapping_id")
    if supplied and supplied != natural:
        raise ValueError(f"mapping_id must equal deterministic identity {natural}")

    normalized = {
        "source_system": source_system,
        "source_entity_type": source_type,
        "source_id": source_id,
        "predicate": predicate,
        "target_system": target_system,
        "target_entity_type": target_type,
        "target_id": target_id,
        "match_type": match_type,
        "status": status,
        "evidence_source": evidence_source,
        "evidence_version": evidence_version,
        "evidence_locator": _text(payload, "evidence_locator") or None,
        "confidence": confidence,
    }
    return CrosswalkRow(
        mapping_id=natural,
        computation_eligible=(match_type == "EXACT" and status == "APPROVED"),
        row_hash=stable_hash(canonical_json(normalized)),
        **normalized,
    )
